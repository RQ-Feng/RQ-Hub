local MainGame = workspace.Game

local Stats = MainGame.Stats
local Tickets = MainGame.Effects.Tickets
local Spawns = MainGame.Map.Parts.Spawns

local Zoom = LocalPlayer.PlayerScripts.Camera.FOVAdjusters.Zoom
local onDetector = {}

local function GetPlayerByChar(char)
    if not char:IsA('Model') then return warn('[GetPlayerByChar] Expect model,got',char.ClassName or typeof(char)) end
    return Players:FindFirstChild(char.Name)
end

--------------------------------------------------功能专属
local function PlayerDownedDetector(plr)
    if plr == LocalPlayer or table.find(onDetector,plr) then return end
    local Character = plr.Character
    local DownedEsp--esp
    local DownedName,CarriedName = '倒地玩家','倒地玩家(被抬起)'
    local onDownedEvent,onCarriedEvent --events
    warn('detecting',plr.Name)

    local function onCharacterAdded(Character)
        local function onDowned()
            local downed = Character:GetAttribute('Downed')
            if downed then
                warn(Character.Name,'downed!')
                DownedEsp = AddESP({
                    Name = DownedName,
                    inst = Character,
                    Color = Color3.new(0, 1, 0),
                    value = OrionLib.Flags['DownedPlayerEsp']
                })
                warn(Character.Name,'got esp!')
            elseif DownedEsp then 
                DownedEsp:Destroy() 
                warn(Character.Name,'destroyed esp!')
            end
        end

        local function onCarried()
            local carried = Character:GetAttribute('Carried')
            if not DownedEsp then return end
            if carried then
                warn(Character.Name,'carried!')
                DownedEsp.CurrentSettings.Name = CarriedName
                warn(Character.Name,'changed esp!')
            else
                DownedEsp.CurrentSettings.Name = DownedName
                warn(Character.Name,'changed esp back!')
            end
        end

        if not OrionLib.Flags['DownedPlayerEsp'].Value then return end
        onDowned(); onCarried()
        onDownedEvent = AddConnection(Character:GetAttributeChangedSignal('Downed'),onDowned,OrionLib.Flags['DownedPlayerEsp'])
        onCarriedEvent = AddConnection(Character:GetAttributeChangedSignal('Carried'),onCarried,OrionLib.Flags['DownedPlayerEsp'])
    end

    if Character and not table.find(onDetector,plr) then onCharacterAdded(Character) end

    AddConnection(plr.CharacterAdded,onCharacterAdded,OrionLib.Flags['DownedPlayerEsp'])
end

Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
local TimerPrefix = '当前%s时间剩余: %d 秒'
local State = Stats:GetAttribute('RoundStarted') and '回合' or Stats:GetAttribute('Voting') and '投票阶段' or '中场休息'
local Timer = Tab:AddLabel(TimerPrefix:format(State,Stats:GetAttribute('Timer')))
AddConnection(Stats:GetAttributeChangedSignal('Timer'),function()
    local CurrentTime = Stats:GetAttribute('Timer')
    local State = Stats:GetAttribute('RoundStarted') and '回合' or Stats:GetAttribute('Voting') and '投票阶段' or '中场休息'
    if type(CurrentTime) ~= 'number' then Timer:Set('回合时间未知'); return end
     
    Timer:Set(TimerPrefix:format(State,Stats:GetAttribute('Timer')))
end)
Tab:AddSlider({
    Name = "缩放",
    Save = true,
    Min = 0,
    Max = 1.4,
    Default = 1,
    Increment = 0.1,
    Flag = 'AutoZoom',
    Callback = function(value) Zoom.Value = value end
})
Tab:AddToggle({
    Name = "特殊回合提醒",
    Default = true,
    Flag = "SpecialRoundNotify",
    Callback = function(Value)
        if not Value then return end
        if Stats:GetAttribute('SpecialRound') then
            OrionLib:MakeNotification({
                Name = '特殊回合',
                Content = ('特殊回合为: %s'):format(Stats:GetAttribute('SpecialRound')),
                Image = 'rbxassetid://7733658504',
                Time = 5
            })
        end

        AddConnection(Stats:GetAttributeChangedSignal('SpecialRound'),function() -- 其他
            OrionLib:MakeNotification({
                Name = '特殊回合',
                Content = ('特殊回合为: %s'):format(Stats:GetAttribute('SpecialRound')),
                Image = 'rbxassetid://7733658504',
                Time = 5
            })
        end,OrionLib.Flags['SpecialRoundNotify'])
    end
})
Esp:AddToggle({
    Name = "实体透视",
    Default = true,
    Flag = "EntitiesEsp",
    Callback = function(Value)
        if not Value then return end

        for _,char in pairs(MainGame.Players:GetChildren()) do
            if GetPlayerByChar(char) then continue end
            AddESP({
                inst = char,
                Color = Color3.new(1, 0, 0),
                value = OrionLib.Flags['EntitiesEsp'],
                Type = 'Highlight'
            })
            if char:FindFirstChild('Hitbox') then char.Hitbox.Transparency = 0 end
        end 

        AddConnection(MainGame.Players.ChildAdded,function(char) -- 其他
            if GetPlayerByChar(char) or not OrionLib.Flags['EntitiesEsp'].Value then return end --GetPlayerFromCharacter has some problems bruh
            AddESP({
                inst = char,
                Color = Color3.new(1, 0, 0),
                value = OrionLib.Flags['EntitiesEsp'],
                Type = 'Highlight'
            })
            if char:WaitForChild('Hitbox',1) then char.Hitbox.Transparency = 0 end
        end,OrionLib.Flags['EntitiesEsp'])
    end
})
Esp:AddToggle({
    Name = "活动货币透视",
    Default = true,
    Flag = "VisualEsp",
    Callback = function(Value)
        if not Value then return end

        for _,visual in pairs(Tickets:GetChildren()) do 
            if visual.Name == 'Visual' then AddESP({
                Name = '活动货币',
                Color = Color3.new(1, 1, 0),
                inst = visual,
                value = OrionLib.Flags['VisualEsp']
            }) end 
        end

        AddConnection(Tickets.ChildAdded,function(inst) -- 其他
            if inst.Name ~= 'Visual' then return end
            if OrionLib.Flags['VisualEsp'].Value then AddESP({
                Name = '活动货币',
                Color = Color3.new(1, 1, 0),
                inst = inst,
                value = OrionLib.Flags['VisualEsp']
            }) end
        end,OrionLib.Flags['VisualEsp'])
    end
})
Esp:AddToggle({
    Name = "倒地玩家透视",
    Default = true,
    Flag = "DownedPlayerEsp",
    Callback = function(Value)
        if not Value then onDetector = {}; return end
        for _,plr in pairs(Players:GetPlayers()) do PlayerDownedDetector(plr) end
    end
})

AddConnection(Zoom.Changed,function() Zoom.Value = OrionLib.Flags['AutoZoom'].Value end)

AddConnection(Players.PlayerAdded,function(plr)
    if OrionLib.Flags['DownedPlayerEsp'] then PlayerDownedDetector(plr) end
end)

task.spawn(function()
    repeat task.wait() until not OrionLib:IsRunning()
    Zoom.Value = 1
    ESPLibrary:Clear()
end)