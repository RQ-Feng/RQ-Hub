local RemotesFolder = ReplicatedStorage.RemotesFolder
local GameData = ReplicatedStorage.GameData
local LatestRoom = GameData.LatestRoom

local MainUI = LocalPlayer.PlayerGui.MainUI
AddConnection(LocalPlayer.PlayerGui.ChildAdded,function(ui)
    if ui.Name ~= 'MainUI' then return end
    MainUI = ui
end)

local Main_Game = MainUI.Initiator.Main_Game
local RemoteListener = Main_Game.RemoteListener
local RemoteModules = RemoteListener.Modules

local IsBypassingAC = false

local Floors = {
    ['Garden'] = 'Outdoors',
    ['Ripple'] = {
        ['Daily_Default'] = 'Daily Runs'
    }
} 
local function CurrentRoom()
    return workspace.CurrentRooms[LatestRoom.Value]
end

local function CurrentDoor()
    return CurrentRoom():WaitForChild('Door')
end

local function CurrentFloor()
    local floor,floorSpecific = GameData.Floor.Value,GameData.FloorSpecific.Value
    return typeof(Floors[floor]) == 'table' and Floors[floor][floorSpecific] or Floors[floor] or floor
end

local function SetClipFunction(char,value)
    local CanCollide = value or false

    local Collision = char:FindFirstChild('Collision')
    if Collision then
        Collision.CollisionGroup = "PlayerCrouching"
        Collision.CollisionCrouch.CollisionGroup = "PlayerCrouching"
        char.Collision.CanCollide = CanCollide
        char.Collision.CollisionCrouch.CanCollide = CanCollide
    end
    char.CollisionPart.CollisionGroup = "PlayerCrouching"
    if char:FindFirstChild('_CollisionPart') then char._CollisionPart.CanCollide = CanCollide end
end

local function PromptIsChecked(prompt) return prompt.MaxActivationDistance > 10 end

local AntiItems = {}
local RealEvents,RealRemoteModules = {},{}

local function FakeEvent(value,Name)
    local RealEventName = '_'..Name
    local cacheRealEvent = RemotesFolder:FindFirstChild(RealEventName)
    local cacheEvent = RemotesFolder:FindFirstChild(Name)
    if not cacheEvent then return end

    local RealEvent = cacheRealEvent or cacheEvent
    local FakeEvent = cacheRealEvent and cacheEvent or cacheEvent:Clone()

    RealEvent.Name = value and RealEventName or Name

    if value then
        table.insert(RealEvents,RealEvent)
        FakeEvent.Parent = RemotesFolder        
    else 
        table.remove(RealEvents,table.find(RealEvents,RealEvent))
        FakeEvent:Destroy()
    end
end

local function FakeRemoteModule(value,Name)
    local RealModuleName = '_'..Name
    local cacheRealModule = RemoteModules:FindFirstChild(RealModuleName)
    local cacheModule = RemoteModules:FindFirstChild(Name)
    if not cacheModule then return end

    local RealRemoteModule = cacheRealModule or cacheModule
    local FakeRemoteModule = cacheRealModule and cacheModule or Instance.new('ModuleScript')

    RealRemoteModule.Name = value and RealModuleName or Name

    if value then
        table.insert(RealRemoteModules,RealRemoteModule)
        FakeRemoteModule.Parent = RemoteModules        
    else 
        table.remove(RealRemoteModules,table.find(RealRemoteModules,RealRemoteModule))
        FakeRemoteModule:Destroy()
    end
end

local function HideObject(Object,flag)
    if not Object then return end
    flag = flag or {Value = true}
    task.spawn(function()
        local cacheObject = Object
        local OriginalParent = cacheObject.Parent
        cacheObject.Parent = nil
        repeat task.wait() until not flag.Value or not OrionLib:IsRunning()
        cacheObject.Parent = OriginalParent
    end)
end

local function AntiClientEntity(value,Name)
    if typeof(Name) ~= 'string' then return end
    FakeRemoteModule(value,Name)
    FakeEvent(value,Name)
    if value then table.insert(AntiItems,Name)   
    else table.remove(AntiItems,table.find(AntiItems,Name)) end
end

local GameItems = {
    ['KeyObtain'] = '钥匙',
    ['ElectricalKeyObtain'] = '电气室钥匙',
    ['FuseObtain'] = '保险丝',
    ['LiveBreakerPolePickup'] = '开关',
    ['LeverForGate'] = '拉杆',
    ['VineGuillotine'] = '拉杆',
    ['LibraryHintPaper'] = '纸',
    ['LiveHintBook'] = '书本',
    ['TimerLever'] = '时间拉杆',
    ['GoldPile'] = '金币',
    ['StardustPickup'] = '星尘',
    ['LadderModel'] = '梯子'
}

local ItemsName = {
    ['Lighter'] = '打火机',
    ['Lockpick'] = '撬锁器',
    ['Vitamins'] = '维他命',
    ['Smoothie'] = '奶昔',
    ['Bandage'] = '绷带',
    ['Candle'] = '蜡烛',
    ['Flashlight'] = '手电筒',
    ['SkeletonKey'] = '骷髅钥匙',
    ['Crucifix'] = '十字架',
    ['Straplight'] = '头灯',
    ['LotusHolder'] = '花瓣',
    ['LotusPetalPickup'] = '花瓣',
    ['BandagePack'] = '绷带包',
    ['Compass'] = '指南针',
    ['Shakelight'] = '软糖',
    ['Glowsticks'] = '光棒',
    ['Bread'] = '面包',
    ['StarBottle'] = '星光瓶',
    ['LaserPointer'] = '激光笔',
    ['Cheese'] = '芝士',
    ['Lantern'] = '灯笼',
    ['BatteryPack'] = '电池包',
    ['AlarmClock'] = '闹钟',
    ['StarVial'] = '小星光瓶',
    ['AloeVera'] = '芦荟',
    ['TipJar'] = '小费罐',
    ['GweenSoda'] = 'Gween苏打水',
    ['Donut'] = '甜甜圈',
    ['Shears'] = '剪刀',
    ['GoldGun'] = '金枪',
    ['StarJug'] = '星光桶',
    ['RiftSmoothie'] = '蓝光奶昔',

    ['LiveBreakerPolePickup'] = '开关',
    ['LibraryHintPaper'] = '纸',
    ['LiveHintBook'] = '书本'
}

local GetEspItemBoxes = {
    ['KeyObtain'] = function(item)
        local hitbox = item:WaitForChild('Hitbox',3)
        if hitbox then return hitbox:WaitForChild('KeyHitbox',3) end
    end
}

local Entities = {
    ['RushMoving'] = 'Rush',
    ['AmbushMoving'] = 'Ambush',
    ['Eyes'] = 'Eyes',
    ['GloombatSwarm'] = 'Gloombats',
    ['BackdoorRush'] = 'Blitz',
    ['BackdoorLookman'] = 'Lookman',
    ['A60'] = 'A60',
    ['A120'] = 'A120',
    ['Mobble'] = 'Sally',
    ['SallyMoving'] = 'Sally',
    ['JeffTheKiller'] = 'Jeff',
    ['MonumentEntity'] = 'Monument',
    ['Dread'] = 'Dread',
    ['Bramble'] = 'Bramble',
    ['OnlyLocalization'] = {
        ['FigureRig'] = 'Figure'
        --['HaltMoving'] = 'Halt'
    }
}

local InteractPrompts = {
    'ModulePrompt',
    'UnlockPrompt',
    'LootPrompt',
    'FusesPrompt',
    'LeverPrompt',
    'ActivateEventPrompt'
}

local Interact_Blacklist = {
    'Padlock',
    'JeffShop_Hotel',
    'ElevatorBreaker'
}

local function CheckEspItem(config)
    local inst = config['inst']
    if not inst then return false end 
    local instName = config['instName'] or inst.Name
    local Color = config['Color'] or Color3.new(1,1,1)
    local DisplayTable = config['DisplayTable'] or GameItems
    local Flag = config['Flag'] or true
    local EspType = config['EspType']

    if inst.Name ~= instName or not inst:IsA('Model') then return false end -- Check inst
    if Players:GetPlayerFromCharacter(inst.Parent) or inst.Parent.Name == 'SallyMoving' then return false end -- Check parent
    
    AddESP({
        inst = GetEspItemBoxes[instName] and GetEspItemBoxes[instName](inst) or inst,
        Name = DisplayTable[instName] or inst.Name,
        Type = EspType,
        Color = Color,
        value = Flag
    }); return true
end

local EspMethods = {
    ['KeyObtain'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'KeyObtain',DisplayTable = GameItems,Flag = OrionLib.Flags['KeyEsp']})
    end,
    ['FuseObtain'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'FuseObtain',DisplayTable = GameItems,Flag = OrionLib.Flags['FuseEsp']})
    end,
    ['LeverForGate'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'LeverForGate',DisplayTable = GameItems,Flag = OrionLib.Flags['LeverEsp']})
    end,
    ['VineGuillotine'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'VineGuillotine',DisplayTable = GameItems,Flag = OrionLib.Flags['LeverEsp']})
    end,
    ['TimerLever'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'TimerLever',DisplayTable = GameItems,Flag = OrionLib.Flags['LeverEsp']})
    end,
    ['ElectricalKeyObtain'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'ElectricalKeyObtain',DisplayTable = GameItems,Flag = OrionLib.Flags['KeyEsp']})
    end,
    ['LiveHintBook'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'LiveHintBook',DisplayTable = GameItems,Flag = OrionLib.Flags['LiveHintBookEsp']})
    end,
    ['FigureRig'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'FigureRig',Color = Color3.new(1,0,0),DisplayTable = Entities['OnlyLocalization'],Flag = OrionLib.Flags['EntitiesEsp']})
    end,
    ['StardustPickup'] = function(ItemInst)
        CheckEspItem({inst = ItemInst,instName = 'StardustPickup',DisplayTable = GameItems,Flag = OrionLib.Flags['CurrencyEsp']})
    end,
    ['GoldPile'] = function(ItemInst)
        AddESP({
            inst = ItemInst,
            Name = tostring(ItemInst:GetAttribute('GoldValue'))..GameItems['GoldPile'],
            Type = 'Highlight',
            Color = Color3.new(1, 1, 0),
            value = OrionLib.Flags['CurrencyEsp']
        })
    end,
}

local function CheckAllEspItems(ItemInst)
    local itemName = ItemInst.Name
    if EspMethods[itemName] then return EspMethods[itemName](ItemInst) end

    if ItemsName[itemName] then
        return CheckEspItem({
            inst = ItemInst,instName = itemName,DisplayTable = ItemsName,EspType = 'Highlight',Flag = OrionLib.Flags['ItemsEsp']
        })
    end

    if not IsBypassingAC and ItemInst.Name == 'LadderModel' then
        local ladderEsp = CheckEspItem({inst = ItemInst,instName = 'LadderModel',DisplayTable = GameItems,Flag = OrionLib.Flags['BypassACFromLadder']}) 
        task.spawn(function() repeat task.wait() until IsBypassingAC; if ladderEsp then ladderEsp:Destroy() end end)
    end
    
end
--Feature Function/others
local function GetPadlockCode(paper)
    local UI = paper:FindFirstChild("UI")
    if not UI then return "_____" end

    local code = {}

    for _, PaperHintImage in pairs(UI:GetChildren()) do
        if not PaperHintImage:IsA("ImageLabel") then continue end
        local hintNum = tonumber(PaperHintImage.Name)
        if not hintNum then continue end
        local index = PaperHintImage.ImageRectOffset.X .. PaperHintImage.ImageRectOffset.Y
        code[index] = {hintNum,'_'}
    end

    for _, HintImage in pairs(LocalPlayer.PlayerGui.PermUI.Hints:GetChildren()) do
        if HintImage.Name ~= "Icon" then continue end
        local index = HintImage.ImageRectOffset.X .. HintImage.ImageRectOffset.Y
        if code[index] then code[index][2] = HintImage.TextLabel.Text end
    end

    local normalizedCode = {}
    for _ImageId,hintTable in pairs(code) do
        normalizedCode[hintTable[1]] = hintTable[2]
    end

    return table.concat(normalizedCode)
end

local function GoldPileEsp(GoldPile)
    if GoldPile.Name ~= 'GoldPile' or not GoldPile:IsA('Model') then return end
    AddESP({
        inst = GoldPile,
        Name = tostring(GoldPile:GetAttribute('GoldValue'))..GameItems['GoldPile'],
        Type = 'Highlight',
        value = OrionLib.Flags['CurrencyEsp']
    })
end

Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Feature = Window:MakeTab({
    Name = "功能",
    Icon = "rbxassetid://4483345998"
})
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
Floor = Window:MakeTab({
    Name = "楼层",
    Icon = "rbxassetid://4483345998"
})
Anti = Window:MakeTab({
    Name = "防",
    Icon = "rbxassetid://4483345998"
})
Tab:AddSection({Name = "速度"})
local SpeedWays = {"SpeedBoost", "SpeedBoostBehind"}
local function CheckSpeed(Value)
    if not Value then return end
    local currentSpeedWay = OrionLib.Flags['SpeedWay'].Value

    local function detectSpeed()
        if OrionLib.Flags['Speed'].Value > 6 and (not OrionLib.Flags['BypassSpeedAC'] or not OrionLib.Flags['BypassSpeedAC'].Value) then
            repeat task.wait() until OrionLib.Flags['BypassSpeedAC'] and not Character:FindFirstChild('CollisionPart').Anchored
            OrionLib.Flags['BypassSpeedAC']:Set(true)
            OrionLib:MakeNotification({Name = "速度",Content = "已自动启动速度绕过.",Time = 3})
        end
    end; detectSpeed()

    Character:SetAttribute(currentSpeedWay,OrionLib.Flags['Speed'].Value)
    local event = AddConnection(Character:GetAttributeChangedSignal(currentSpeedWay),function()
        detectSpeed()
        Character:SetAttribute(currentSpeedWay,OrionLib.Flags['Speed'].Value)
    end,OrionLib.Flags['EnableSpeed'])
    repeat task.wait() until OrionLib.Flags['SpeedWay'].Value ~= currentSpeedWay or not OrionLib.Flags['EnableSpeed'].Value or not OrionLib:IsRunning()
    if event then event:Disconnect() end
    Character:SetAttribute(currentSpeedWay,0)
end
Tab:AddDropdown({
    Name = "加速方式",
    Save = true,
    Flag = 'SpeedWay',
    Default = "SpeedBoost",
    Options = SpeedWays,
    Callback = CheckSpeed
})
Tab:AddToggle({
    Name = "启动加速",
    Save = true,
    Default = false,
    Flag = 'EnableSpeed',
    Callback = CheckSpeed
})
Tab:AddSlider({
    Name = "速度",
    Save = true,
    Min = 0,
    Max = 100,
    Default = 0,
    Increment = 1,
    Flag = 'Speed',
    Callback = function(spd)
        if not OrionLib.Flags['EnableSpeed'].Value then return end
        Character:SetAttribute(OrionLib.Flags['SpeedWay'].Value, spd)
    end
})
Tab:AddSection({Name = "交互"}) --game:GetService("ReplicatedStorage").RemotesFolder.EBF
Tab:AddToggle({
    Name = "轻松交互",
    Save = true,
    Flag = 'BetterPrompt',
    Default = true,
    Callback = function(Value)
        for _,prompt in pairs(workspace:GetDescendants()) do 
            if not prompt:IsA('ProximityPrompt') then continue end
            SetPrompt(prompt,(not Value and PromptIsChecked(prompt)) and 
            prompt.MaxActivationDistance / 2 or not PromptIsChecked(prompt) and (InteractPrompts[prompt.Name] or prompt.MaxActivationDistance * 2))
        end; if not Value then return end
        AddConnection(workspace.DescendantAdded,function(prompt)
            if not prompt:IsA('ProximityPrompt') then return end
            SetPrompt(prompt,not PromptIsChecked(prompt) and (InteractPrompts[prompt.Name] or prompt.MaxActivationDistance * 2))
        end,OrionLib.Flags['BetterPrompt'])
    end
})
Tab:AddToggle({
    Name = "自动交互",
    Save = true,
    Flag = 'AutoPrompt',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        AddConnection(game:GetService('ProximityPromptService').PromptShown,function(prompt)
            if not table.find(InteractPrompts,prompt.Name) or prompt:GetAttribute('Interactions'..LocalPlayer.Name) then return end
            local ModelParent = prompt:FindFirstAncestorOfClass('Model')
            
            local HasBlackedPrompt; for _,BlackObjectName in pairs(Interact_Blacklist) do
                if ModelParent:FindFirstAncestor(BlackObjectName) then HasBlackedPrompt = true end
            end; if HasBlackedPrompt then return end

            while prompt and ModelParent and OrionLib:IsRunning() and OrionLib.Flags['AutoPrompt'].Value do     
                if prompt and prompt:GetAttribute('Interactions'..LocalPlayer.Name) then break end
                fireproximityprompt(prompt); task.wait() 
            end
        end,OrionLib.Flags['AutoPrompt'])
    end
})
Tab:AddSection({Name = "其他"})
Tab:AddToggle({
    Name = "实体提示",
    Save = true,
    Flag = 'EntityNotify',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        for _,entity in pairs(workspace:GetChildren()) do
            if Entities[entity.Name] and entity:IsA('Model') then
                OrionLib:MakeNotification({
                    Name = "实体提示",
                    Content = (Entities[entity.Name] or entity.Name) .. " 已出现！",
                    Time = 5
                })
            end
        end
    end
})
Tab:AddToggle({
    Name = "高亮",
    Flag = 'FullBright',
    Save = true,
    Default = false,
    Callback = FullBright
})
Tab:AddButton({
    Name = "紫砂",
    ClickTwice = true,
    Callback = function()
        local UnderwaterClient = Character:GetAttribute('UnderwaterClient')
        if ExecutorChecker['replicatesignal'] then replicatesignal(LocalPlayer.Kill) else 
            RemotesFolder.Underwater:FireServer(not UnderwaterClient) end
        local NotifyContent = ExecutorChecker['replicatesignal'] and "已成功紫砂." or (not UnderwaterClient and "紫砂中..." or '已停止紫砂.')
        OrionLib:MakeNotification({
            Name = "紫砂",
            Content = NotifyContent,
            Time = 5
        })
    end
})
Tab:AddButton({
    Name = "返回大厅",
    ClickTwice = true,
    Callback = function()
        RemotesFolder.Lobby:FireServer()
        OrionLib:MakeNotification({
            Name = "返回大厅",
            Content = '返回中...',
            Time = 5
        })
    end
})
Tab:AddButton({
    Name = "重开",
    ClickTwice = true,
    Callback = function()
        RemotesFolder.PlayAgain:FireServer()
        OrionLib:MakeNotification({
            Name = "重开",
            Content = '重开中...',
            Time = 5
        })
    end
})
Feature:AddSection({Name = "绕过"})
Feature:AddSlider({
    Name = "绕过速率",
    Save = true,
    Min = 0.18,
    Max = 0.3,
    Default = 0.23,
    Increment = 0.01,
    Flag = 'BypassSpeedACRate'
})
Feature:AddToggle({
    Name = "速度绕过",
    Save = true,
    Default = false,
    Flag = 'BypassSpeedAC',
    Callback = function(Value)
        if not Value then return end

        local CollisionPart = Character:FindFirstChild('CollisionPart')
        local CloneCollisionPart,AntiAnchorLagNotify

        local function CloneBypassPart(char)
            CloneCollisionPart = char:FindFirstChild('CollisionPart'):Clone()
            CloneCollisionPart.Parent = char
            CloneCollisionPart.CanCollide = false
            CloneCollisionPart.Anchored = false
            CloneCollisionPart.Name = '_CollisionPart'
            return CloneCollisionPart
        end
        
        CloneCollisionPart = Character:FindFirstChild('_CollisionPart') or CloneBypassPart(Character)

        local function NotifyWhenAnchor(content)
            if AntiAnchorLagNotify then OrionLib:CloseNotification(AntiAnchorLagNotify) end
            AntiAnchorLagNotify = OrionLib:MakeNotification({
                Name = "速度绕过",
                Content = content,
                Time = 2
            })
        end

        local function BypassSpeedAC()
            task.spawn(function()
                while OrionLib.Flags['BypassSpeedAC'].Value and OrionLib:IsRunning() do
                    if IsBypassingAC then 
                        OrionLib.Flags['BypassSpeedAC']:Set(false)
                        OrionLib:MakeNotification({
                            Name = "速度绕过",
                            Content = '已绕过反作弊,自动关闭.',
                            Time = 5
                        }); break
                    end
                    if CollisionPart.Anchored then 
                        NotifyWhenAnchor("检测到被锚定,等待中...")
                        if CloneCollisionPart then CloneCollisionPart.Massless = true end
                        if OrionLib.Flags['ClipByACBind'].Holding then repeat task.wait() until not OrionLib.Flags['ClipByACBind'].Holding end
                        repeat task.wait() until not CollisionPart.Anchored or not OrionLib:IsRunning()
                        if not OrionLib:IsRunning() then return end
                        task.wait(0.5)
                        NotifyWhenAnchor("已自动重启.")
                    end
                    if CloneCollisionPart then CloneCollisionPart.Massless = not CloneCollisionPart.Massless end
                    task.wait(OrionLib.Flags['BypassSpeedACRate'].Value) 
                end
            end)
        end; BypassSpeedAC()

        AddConnection(LocalPlayer.CharacterAdded,CloneBypassPart,OrionLib.Flags['BypassSpeedAC'])

        task.spawn(function()
            repeat task.wait() until not OrionLib.Flags['BypassSpeedAC'].Value or not OrionLib:IsRunning()
            if CloneCollisionPart then CloneCollisionPart:Destroy() end
        end)
    end
})
Feature:AddBind({
	Name = "使用反作弊穿墙",
	Default = Enum.KeyCode.V,
    Flag = 'ClipByACBind',
	Hold = true,
    Callback = function(Value)
        if not Value then return end
        if IsBypassingAC then OrionLib:MakeNotification({
            Name = "使用反作弊穿墙",
            Content = '你已绕过反作弊,无需使用.',
            Time = 5
        }); return end
        repeat task.wait()
            if not Character then break end
            Character:PivotTo(Character:GetPivot() * CFrame.new(0, 0, 1000))
        until not OrionLib.Flags['ClipByACBind'].Holding or not OrionLib:IsRunning()
    end
})
Feature:AddToggle({
    Name = "绕过反作弊(需要梯子)",
    Save = true,
    Default = false,
    Flag = 'BypassACFromLadder',
    Callback = function(Value)
        if not Value then return end
        local ClimbLadder = RemotesFolder:FindFirstChild('ClimbLadder')
        if not ClimbLadder then return end
        local WaitingForClimbingNotify
        if not Character:GetAttribute('Climbing') then
            WaitingForClimbingNotify = OrionLib:MakeNotification({
                Name = "绕过反作弊",
                Content = "请先爬上梯子.",
                Time = 30
            }); IsBypassingAC = false
            for _, item in pairs(workspace.CurrentRooms:GetDescendants()) do
                if item.Name ~= 'LadderModel' then continue end
                local ladderEsp = AddESP({
                    inst = item,
                    Name = '梯子',
                    value = OrionLib.Flags['BypassACFromLadder']
                }) 
                task.spawn(function() repeat task.wait() until IsBypassingAC; if ladderEsp then ladderEsp:Destroy() end end)
            end
            repeat task.wait() until Character:GetAttribute('Climbing') or not OrionLib.Flags['BypassACFromLadder'].Value or not OrionLib:IsRunning()
            if WaitingForClimbingNotify then OrionLib:CloseNotification(WaitingForClimbingNotify) end
            if not OrionLib.Flags['BypassACFromLadder'].Value or not OrionLib:IsRunning() then return end
        end
        IsBypassingAC = true
        HideObject(ClimbLadder,OrionLib.Flags['BypassACFromLadder'])
        Character:SetAttribute('Climbing',false)
        OrionLib:MakeNotification({
            Name = "绕过反作弊",
            Content = "已成功绕过,过场将会导致绕过失效.",
            Time = 5
        })
        AddConnection(RemotesFolder:FindFirstChild("UseEnemyModule").OnClientEvent,function(...)
            local info = {...}
            if (info[1] == 'Glitch' and info[3]) or info[1] == 'Seek' then return end
            OrionLib:MakeNotification({
                Name = "绕过反作弊",
                Content = "检测到触发过场,已自动关闭.",
                Time = 5
            })
            OrionLib.Flags['BypassACFromLadder']:Set(false)
        end,OrionLib.Flags['BypassACFromLadder'])
        repeat task.wait() until not OrionLib.Flags['BypassACFromLadder'].Value or not OrionLib:IsRunning()
        IsBypassingAC = false
    end
})
Feature:AddSection({Name = "玩家"})
Feature:AddToggle({
    Name = "God mode",
    Save = true,
    Default = false,
    Flag = 'Godmode',
    Callback = function(Value)
        if not Value then return end
        local OriginalSilentCrouch,OriginalHipHeight = OrionLib.Flags['SilentCrouch'].Value,Humanoid.HipHeight
        Humanoid.HipHeight = 0.001

        SetClipFunction(Character)
        AddConnection(Humanoid:GetPropertyChangedSignal("HipHeight"),function() Humanoid.HipHeight = 0.001 end,OrionLib.Flags['Godmode'])
        AddConnection(Character.Collision:GetPropertyChangedSignal("CanCollide"),function() SetClipFunction(Character) end,OrionLib.Flags['Godmode'])
        AddConnection(Character.Collision.CollisionCrouch:GetPropertyChangedSignal("CanCollide"),function() SetClipFunction(Character) end,OrionLib.Flags['Godmode'])

        OrionLib.Flags['SilentCrouch']:Set(true)

        while OrionLib.Flags['Godmode'].Value and OrionLib:IsRunning() do task.wait()
            if not OrionLib.Flags['SilentCrouch'].Value then 
                OrionLib:MakeNotification({
                    Name = "Godmode",
                    Content = "请不要手动关闭静步.",
                    Time = 2
                })
                OrionLib.Flags['SilentCrouch']:Set(true)
            end
        end 

        OrionLib.Flags['SilentCrouch']:Set(OriginalSilentCrouch)
        Humanoid.HipHeight = OriginalHipHeight
    end
})
Feature:AddToggle({
    Name = "静步",
    Save = true,
    Flag = 'SilentCrouch',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        task.spawn(function()
            repeat RemotesFolder.Crouch:FireServer(true); task.wait() until not OrionLib.Flags['SilentCrouch'].Value or not OrionLib:IsRunning()
            RemotesFolder.Crouch:FireServer(false)
        end)
    end
})
Feature:AddToggle({
    Name = "更小碰撞箱",
    Save = true,
    Flag = 'SmallHitbox',
    Default = false,
    Callback = function(Value)
        SetClipFunction(Character)
        AddConnection(LocalPlayer.CharacterAdded,SetClipFunction,OrionLib.Flags['SmallHitbox'])
        AddConnection(Character.Collision:GetPropertyChangedSignal("CanCollide"),function() SetClipFunction(Character) end,OrionLib.Flags['SmallHitbox'])
        AddConnection(Character.Collision.CollisionCrouch:GetPropertyChangedSignal("CanCollide"),function() SetClipFunction(Character) end,OrionLib.Flags['SmallHitbox'])
        repeat task.wait() until not OrionLib.Flags['SmallHitbox'].Value or not OrionLib:IsRunning()
        SetClipFunction(Character,true)
    end
})
Feature:AddToggle({
    Name = "开启跳跃",
    Save = true,
    Flag = 'CanJump',
    Default = false,
    Callback = function(Value)
        Character:SetAttribute("CanJump", Value)
        if not Value then return end
        AddConnection(Character:GetAttributeChangedSignal('CanJump'),function() Character:SetAttribute("CanJump", Value) end,OrionLib.Flags['CanJump'])
    end
})
Feature:AddToggle({
    Name = "开启滑铲",
    Save = true,
    Flag = 'CanSlide',
    Default = false,
    Callback = function(Value)
        Character:SetAttribute("CanSlide", Value)
        if not Value then return end
        AddConnection(Character:GetAttributeChangedSignal('CanSlide'),function() Character:SetAttribute("CanSlide", Value) end,OrionLib.Flags['CanSlide'])
    end
})
Feature:AddSection({Name = "提醒"})
local OxygenNotify,WaitToCloseTask,CheckOxygenEvent
Feature:AddToggle({
    Name = "氧气提醒",
    Save = true,
    Default = false,
    Flag = 'OxygenNotify',
    Callback = function(Value)
        if not Value then 
            if OxygenNotify then OxygenNotify:Close() end
            if WaitToCloseTask then task.cancel(WaitToCloseTask) end
            if CheckOxygenEvent then CheckOxygenEvent:Disconnect() end
            return
        end

        local function SetCloseTask(char)
            WaitToCloseTask = task.spawn(function()
                task.wait(3)
                if (char and OxygenNotify) and char:GetAttribute('Oxygen') and math.floor(char:GetAttribute('Oxygen')) == 100 then OxygenNotify:Close() end
            end)
        end

        OxygenNotify = Notify({
            Text = '剩余氧气',
            Content = Character:GetAttribute('Oxygen')
        }); SetCloseTask(Character)

        local function CheckOxygen(char)
            if CheckOxygenEvent then CheckOxygenEvent:Disconnect() end
            CheckOxygenEvent = AddConnection(char:GetAttributeChangedSignal('Oxygen'),function()
                local currentOxygen = char:GetAttribute('Oxygen') and math.floor(char:GetAttribute('Oxygen'))

                if not OxygenNotify then OxygenNotify = Notify({
                    Text = '剩余氧气',
                    Content = currentOxygen
                }) end
    
                if currentOxygen == 100 then SetCloseTask(char)
                elseif WaitToCloseTask then task.cancel(WaitToCloseTask) end
    
                if OxygenNotify then OxygenNotify:Set({Text = '剩余氧气',Content = currentOxygen}) end
            end,OrionLib.Flags['OxygenNotify'])
        end

        CheckOxygen(Character)
        AddConnection(LocalPlayer.CharacterAdded,CheckOxygen)
    end
})
Feature:AddSection({Name = "其他"})
Feature:AddToggle({
    Name = "远处开门",
    Save = true,
    Flag = 'OpenDoorFarer',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        task.spawn(function()
            repeat CurrentRoom().Door.ClientOpen:FireServer(); task.wait() until not OrionLib.Flags['OpenDoorFarer'].Value or not OrionLib:IsRunning()
        end)
    end
})
Esp:AddToggle({
    Name = "真门透视",
    Save = true,
    Default = false,
    Flag = 'RealDoorEsp',
    Callback = function(Value)
        if not Value then return end
        local currentRoomValue = LatestRoom.Value
        local RealDoorEsp = AddESP({
            inst = CurrentDoor():WaitForChild('Door'),
            Name = '真门',
            value = OrionLib.Flags['RealDoorEsp'],
            Color = Color3.new(0,1,0)
        }); task.spawn(function()
            repeat task.wait() until LatestRoom.Value ~= currentRoomValue
            if RealDoorEsp then RealDoorEsp:Destroy() end
        end)
    end
})
Esp:AddToggle({
    Name = "Dupe门透视",
    Save = true,
    Default = false,
    Flag = 'DupeDoorEsp',
    Callback = function(Value)
        if not Value then return end
        local currentRoomValue = LatestRoom.Value
        local SideRoomDupe = CurrentRoom():FindFirstChild('SideroomDupe')
        if not SideRoomDupe then return end
        local DupeDoorEsp = AddESP({
            inst = SideRoomDupe:WaitForChild('Start'),
            Name = 'Dupe门',
            value = OrionLib.Flags['DupeDoorEsp'],
            Color = Color3.new(1,0,0)
        }); task.spawn(function()
            repeat task.wait() until LatestRoom.Value ~= currentRoomValue
            if DupeDoorEsp then DupeDoorEsp:Destroy() end
        end)
    end
})
Esp:AddToggle({
    Name = "钥匙透视",
    Save = true,
    Default = false,
    Flag = 'KeyEsp',
    Callback = function(Value)
        if not Value then return end
        for _, item in pairs(CurrentRoom():GetDescendants()) do
            CheckEspItem({inst = item,instName = 'KeyObtain',DisplayTable = GameItems,Flag = OrionLib.Flags['KeyEsp']})
            CheckEspItem({inst = item,instName = 'ElectricalKeyObtain',DisplayTable = GameItems,Flag = OrionLib.Flags['KeyEsp']})
        end
    end
})
Esp:AddToggle({
    Name = "保险丝透视",
    Save = true,
    Default = false,
    Flag = 'FuseEsp',
    Callback = function(Value)
        if not Value then return end
        for _, item in pairs(CurrentRoom():GetDescendants()) do
            CheckEspItem({inst = item,instName = 'FuseObtain',DisplayTable = GameItems,Flag = OrionLib.Flags['FuseEsp']})
        end
    end
})
Esp:AddToggle({
    Name = "拉杆透视",
    Save = true,
    Default = false,
    Flag = 'LeverEsp',
    Callback = function(Value)
        if not Value then return end
        for _, item in pairs(workspace.CurrentRooms:GetDescendants()) do
            CheckEspItem({inst = item,instName = 'LeverForGate',DisplayTable = GameItems,Flag = OrionLib.Flags['LeverEsp']})
            CheckEspItem({inst = item,instName = 'VineGuillotine',DisplayTable = GameItems,Flag = OrionLib.Flags['LeverEsp']})
            CheckEspItem({inst = item,instName = 'TimerLever',DisplayTable = GameItems,Flag = OrionLib.Flags['LeverEsp']})
        end
    end
})
Esp:AddToggle({
    Name = "书本透视",
    Save = true,
    Default = false,
    Flag = 'LiveHintBookEsp',
    Callback = function(Value)
        if not Value then return end
        for _, item in pairs(CurrentRoom():GetDescendants()) do
            CheckEspItem({inst = item,instName = 'LiveHintBook',DisplayTable = GameItems,Flag = OrionLib.Flags['LiveHintBookEsp']})
        end
    end
})
Esp:AddToggle({
    Name = "货币透视",
    Save = true,
    Default = false,
    Flag = 'CurrencyEsp',
    Callback = function(Value)
        if not Value then return end
        for _, item in pairs(workspace.CurrentRooms:GetDescendants()) do
            CheckEspItem({inst = item,instName = 'StardustPickup',DisplayTable = GameItems,Flag = OrionLib.Flags['CurrencyEsp']})
            GoldPileEsp(item)
        end
    end
})
Esp:AddToggle({
    Name = "物品透视",
    Save = true,
    Default = false,
    Flag = 'ItemsEsp',
    Callback = function(Value)
        if not Value then return end
        task.spawn(function()
            for _, inst in pairs(workspace.CurrentRooms:GetDescendants()) do
                local itemName = inst.Name
                if inst:IsA('Model') and ItemsName[itemName] then
                    return CheckEspItem({
                        inst = inst,instName = itemName,DisplayTable = ItemsName,EspType = 'Highlight',Flag = OrionLib.Flags['ItemsEsp']
                    })
                end
            end
        end)
        task.spawn(function()
            for _, inst in pairs(workspace.Drops:GetDescendants()) do
                local itemName = inst.Name
                if inst:IsA('Model') and ItemsName[itemName] then
                    return CheckEspItem({
                        inst = inst,instName = itemName,DisplayTable = ItemsName,EspType = 'Highlight',Flag = OrionLib.Flags['ItemsEsp']
                    })
                end
            end
        end)
    end
})
Esp:AddToggle({
    Name = "实体透视",
    Save = true,
    Default = false,
    Flag = 'EntitiesEsp',
    Callback = function(Value)
        if not Value then return end
        for _, entity in pairs(workspace:GetChildren()) do
            if not Entities[entity.Name] then continue end
            CheckEspItem({inst = entity,instName = Entities[entity.Name],Color = Color3.new(1,0,0),DisplayTable = Entities,Flag = OrionLib.Flags['EntitiesEsp']})
        end; local FigureSetup = CurrentRoom():FindFirstChild('FigureSetup')
        if not FigureSetup then return end
        CheckEspItem({
            inst = FigureSetup:WaitForChild('FigureRig',5),
            instName = 'FigureRig',
            Color = Color3.new(1,0,0),
            DisplayTable = Entities['OnlyLocalization']
            ,Flag = OrionLib.Flags['EntitiesEsp']
        })
    end
})
local function CheckFloor(floorName)
    if not floorName then return warn('[CheckFloor] Got nil floor name.') end
    local isCorrectFloor = CurrentFloor() == floorName
    return isCorrectFloor
end
Floor:AddSection({Name = "楼层信息"})
Floor:AddLabel('您当前位于 '..CurrentFloor()..' 楼层.')
Floor:AddLabel('秘密楼层(无法直接加入): '..(GameData.SecretFloor.Value and '是' or '否'))
local LatestRoomLabel = Floor:AddLabel('目前最前面为 '.. LatestRoom.Value ..' 号门.')
AddConnection(LatestRoom.Changed,function() LatestRoomLabel:Set('目前最前面为 '.. LatestRoom.Value ..' 号门.') end)
Floor:AddSection({Name = "酒店"})
Floor:AddSlider({
    Name = "开锁距离",
    Save = true,
    Min = 10,
    Max = 250,
    Default = 40,
    Increment = 1,
    Flag = 'AutoLibraryUnlockDistance'
})
Floor:AddToggle({
    Name = "自动图书馆开锁",
    Save = true,
    Default = false,
    Flag = 'AutoLibraryUnlock',
    Callback = function(Value)
        if not Value or not CheckFloor('Hotel') then return end
        if LatestRoom.Value > 50 then 
            OrionLib:MakeNotification({
                Name = "自动图书馆开锁",
                Content = '你已通过图书馆.',
                Time = 5
            }); OrionLib.Flags['AutoLibraryUnlock']:Set(false)
            return
        end
        local Room; repeat 
            Room = workspace.CurrentRooms:FindFirstChild("50"); task.wait() 
        until Room or not OrionLib.Flags['AutoLibraryUnlock'].Value or not OrionLib:IsRunning()
        if not OrionLib.Flags['AutoLibraryUnlock'].Value then return end

        task.spawn(function()
            local TriedToSolve = false
            local CodeNotify
            local PadlockPosition = CurrentDoor():WaitForChild('Padlock').PrimaryPart.Position
            repeat task.wait()
                local paper = Character:FindFirstChild("LibraryHintPaper")
                if not paper then continue end
                local code = GetPadlockCode(paper)
                if tonumber(code) and LocalPlayer:DistanceFromCharacter(PadlockPosition) <= OrionLib.Flags['AutoLibraryUnlockDistance'].Value then
                    RemotesFolder.PL:FireServer(code)
                    TriedToSolve = true
                end
                if TriedToSolve and not tonumber(code) then break end
                if CodeNotify then task.spawn(function() OrionLib:CloseNotification(CodeNotify) end) end
                CodeNotify = OrionLib:MakeNotification({
                    Name = "图书馆提示纸",
                    Content = '代码为 '..code..(TriedToSolve and ',已尝试解锁' or '').. '.',
                    Time = 3
                })
                repeat task.wait() until not Character:FindFirstChild("LibraryHintPaper")
            until LatestRoom.Value ~= 50 or not OrionLib.Flags['AutoLibraryUnlock'].Value or not OrionLib:IsRunning()
            OrionLib:MakeNotification({
                Name = "自动图书馆开锁",
                Content = '已成功开锁.',
                Time = 5
            }); OrionLib.Flags['AutoLibraryUnlock']:Set(false)
        end)
    end
})
Floor:AddToggle({
    Name = "自动电箱",
    Save = true,
    Default = false,
    Flag = 'AutoBreaker',
    Callback = function(Value)
        if not Value or not CheckFloor('Hotel') then return end
        repeat RemotesFolder.EBF:FireServer(); task.wait() until not OrionLib.Flags['AutoBreaker'].Value or not OrionLib:IsRunning()
    end
})
local AutoRoomsScript
Floor:AddSection({Name = "Rooms"})
Floor:AddToggle({
    Name = "自动通关(会导致部分游戏功能失效)",
    Save = true,
    Default = false,
    Flag = 'AutoRooms',
    Callback = function(Value)
        if not Value or not CheckFloor('Rooms') then return end
        if not AutoRoomsScript then
            local notity = OrionLib:MakeNotification({
                Name = "Rooms自动通关",
                Content = '加载文件中...',
                Time = 60
            }); local loadSuc
            repeat loadSuc,AutoRoomsScript = pcall(function() return game:HttpGet(baseUrl..'Extra/Doors/doors%20auto%20rooms.lua') end)
                if not loadSuc then OrionLib:MakeNotification({
                    Name = "Rooms自动通关",
                    Content = '加载失败,重新加载中...',
                    Time = 3
                }); warn('[AutoRooms] 加载文件失败,返回错误:',tostring(AutoRoomsScript))
                AutoRoomsScript = nil; task.wait(1) end
            until loadSuc or not OrionLib.Flags['AutoRooms'].Value or not OrionLib:IsRunning()
            if notity then OrionLib:CloseNotification(notity) end
        end
        local enabledNotity = OrionLib:MakeNotification({
            Name = "Rooms自动通关",
            Content = '已启动(无法自动关闭).',
            Time = 5
        })
        loadstring(AutoRoomsScript)()
        task.spawn(function()
            repeat task.wait() until not OrionLib.Flags['AutoRooms'].Value or not OrionLib:IsRunning()
            if enabledNotity then OrionLib:CloseNotification(enabledNotity) end
            if StopAutoRooms then StopAutoRooms() end
        end)
    end
})
Floor:AddSection({Name = "Daily Run"})
Floor:AddToggle({
    Name = "自动检测通关门",
    Save = true,
    Default = false,
    Flag = 'AutoDailyRunDoor',
    Callback = function(Value)
        if not Value or not CheckFloor('Daily Runs') then return end
        if not CurrentRoom():FindFirstChild('RippleExitDoor') then return end
        local Statisticed = false
        local Event = RemotesFolder.Statistics.OnClientEvent:Once(function() Statisticed = true end)
        task.spawn(function()
            repeat task.wait()
                CurrentRoom().RippleExitDoor.Hidden.CFrame = HumanoidRootPart.CFrame
            until Statisticed or not OrionLib.Flags['AutoDailyRunDoor'] or not OrionLib:IsRunning()
            if Event then Event:Disconnect() end
        end)
    end
})
Anti:AddToggle({
    Name = "防相机抖动",
    Flag = 'AntiCameraShake',
    Save = true,
    Default = false,
    Callback = function(Value) 
        AntiClientEntity(Value,'CamShake') -- Yeah weird function name 
        HideObject(RemotesFolder:FindFirstChild('CamShakeRelative'),OrionLib.Flags['AntiCameraShake'])
    end
})
Anti:AddToggle({
    Name = "防跳杀",
    Flag = 'AntiJumpscare',
    Save = true,
    Default = false,
    Callback = function(Value) 
        FakeEvent(Value,'Jumpscare')
        FakeEvent(Value,'SpiderJumpscare')
        if not Value then return end
        HideObject(RemoteListener:FindFirstChild('Jumpscares'),OrionLib.Flags['AntiJumpscare'])
    end
})
Anti:AddToggle({
    Name = "防过场",
    Flag = 'AntiCutscene',
    Save = true,
    Default = false,
    Callback = function(Value) 
        FakeEvent(Value,'Cutscene')
        HideObject(RemoteListener:FindFirstChild('Cutscenes'),OrionLib.Flags['AntiCutscene'])
    end
})
Anti:AddSection({Name = "防实体"})
Anti:AddToggle({
    Name = "防A90",
    Flag = 'AntiA90',
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'A90') end
})
Anti:AddToggle({
    Name = "防Screech",
    Flag = 'AntiScreech',
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'Screech') end
})
Anti:AddToggle({
    Name = "防Halt",
    Flag = 'AntiHalt',
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'ShadeResult') end
})
Anti:AddToggle({
    Name = "防Eyes/Lookman",
    Save = true,
    Flag = 'Anti_Eyes_Lookman',
    Default = false,
    Callback = function(Value) 
        if not Value then return end
        local MotorReplication,FakeMotorReplication
        local Enable = {}

        local function Start()
            if Enable['Value'] then return end
            repeat task.wait() until Character:GetAttribute('Alive') or not OrionLib:IsRunning()
            if not OrionLib.Flags['Anti_Eyes_Lookman'] or not OrionLib:IsRunning() then return end
            MotorReplication = RemotesFolder:FindFirstChild('MotorReplication')
            FakeMotorReplication = Instance.new('UnreliableRemoteEvent',RemotesFolder)
            FakeMotorReplication.Name = 'MotorReplication'
            for i = 1,10 do MotorReplication:FireServer(-1000) end
            Enable['Value'] = true
            HideObject(MotorReplication,Enable)
        end

        local function Stop()
            if FakeMotorReplication then FakeMotorReplication:Destroy() end
            Enable['Value'] = false
            task.wait()
            for i = 1,10 do MotorReplication:FireServer(0) end
        end

        AddConnection(RemotesFolder.PlayerDied.OnClientEvent,function(char,plr)
            if plr.Name == LocalPlayer.Name then Stop() end
        end,OrionLib.Flags['Anti_Eyes_Lookman'])

        AddConnection(LocalPlayer.CharacterAdded,function(char)
            local suc,movement; repeat
                suc,movement = pcall(function()
                    return game:GetService("Players").LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.Movement
                end); task.wait()
            until suc; task.wait(1)
            Start()
        end,OrionLib.Flags['Anti_Eyes_Lookman'])

        task.spawn(function()
            Start()
            repeat task.wait() until not OrionLib.Flags['Anti_Eyes_Lookman'].Value or not OrionLib:IsRunning()
            Stop()
        end)
    end
})
Anti:AddToggle({
    Name = "防Dread",
    Flag = 'AntiDread',
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'Dread') end
})
Anti:AddToggle({
    Name = "防Surge",
    Flag = 'AntiSurge',
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'SurgeRemote') end
})

AddConnection(workspace.ChildAdded,function(entity) -- Entity
    if not Entities[entity.Name] or not entity:IsA('Model') then return end
    if OrionLib.Flags['EntityNotify'].Value then
        OrionLib:MakeNotification({
            Name = "实体提示",
            Content = (Entities[entity.Name] or entity.Name) .. " 已出现！",
            Time = 5
        })
    end
    if OrionLib.Flags['EntitiesEsp'].Value then
        CheckEspItem({inst = entity,instName = entity.Name,Color = Color3.new(1,0,0),DisplayTable = Entities,Flag = OrionLib.Flags['EntitiesEsp']})
    end
end)

AddConnection(workspace.CurrentRooms.DescendantAdded,function(inst) -- Esp
    local itemName = inst.Name
    if not EspMethods[itemName] and not GameItems[itemName] and not ItemsName[itemName] then return end
    CheckAllEspItems(inst)
end)

AddConnection(workspace.Drops.ChildAdded,function(DropItem) -- Check drop item
    for item, name in pairs(ItemsName) do 
        CheckEspItem({inst = DropItem,instName = item,DisplayTable = ItemsName,EspType = 'Highlight',Flag = OrionLib.Flags['ItemsEsp']})
    end
end)

AddConnection(LatestRoom.Changed,function(value)
    if OrionLib.Flags['RealDoorEsp'].Value then
        local RealDoorEsp = AddESP({
            inst = CurrentDoor():WaitForChild('Door'),
            Name = '真门',
            value = OrionLib.Flags['RealDoorEsp'],
            Color = Color3.new(0,1,0)
        }); task.spawn(function()
            repeat task.wait() until LatestRoom.Value ~= value
            if RealDoorEsp then RealDoorEsp:Destroy() end
        end)
    end
    if OrionLib.Flags['DupeDoorEsp'].Value then
        task.spawn(function()
            local SideRoomDupe = CurrentRoom():WaitForChild('SideroomDupe',2)
            if not SideRoomDupe then return end
            local DupeDoorEsp = AddESP({
                inst = SideRoomDupe:WaitForChild('Start',2),
                Name = 'Dupe门',
                value = OrionLib.Flags['DupeDoorEsp'],
                Color = Color3.new(1,0,0)
            }); task.spawn(function()
                repeat task.wait() until LatestRoom.Value ~= value
                if DupeDoorEsp then DupeDoorEsp:Destroy() end
            end)
        end)
    end
    if OrionLib.Flags['AutoDailyRunDoor'].Value then
        task.spawn(function()
            local RippleExitDoor = workspace.CurrentRooms[value]:WaitForChild('RippleExitDoor',2)
            if not RippleExitDoor then return end
            local Hidden = RippleExitDoor:WaitForChild('Hidden',2)
            if not Hidden then return end

            local Statisticed = false
            local Event = RemotesFolder.Statistics.OnClientEvent:Once(function() Statisticed = true end)
            
            repeat task.wait(); Hidden.CFrame = HumanoidRootPart.CFrame until Statisticed or not OrionLib.Flags['AutoDailyRunDoor'] or not OrionLib:IsRunning()
            if Event then Event:Disconnect() end
        end)
    end
end)

task.spawn(function()
    repeat task.wait() until not OrionLib:IsRunning()
    local NeedclearTables = {
        RealEvents,
        RealRemoteModules,
        AntiItems
    }
    for _,NeedclearTable in pairs(NeedclearTables) do
        for _, RealObjectName in pairs(RealEvents) do
            local _ = AntiItems and AntiClientEntity(false,RealObjectName)
            or RealEvents and FakeEvent(false,RealObjectName)
            or RealRemoteModules and FakeRemoteModule(false,RealObjectName)

            RealObjectName.Name = string.sub(RealObjectName.Name,2)
            table.remove(NeedclearTable,table.find(NeedclearTable,RealObjectName))
        end
    end
    for _,prompt in pairs(workspace:GetDescendants()) do 
        if not prompt:IsA('ProximityPrompt') or not PromptIsChecked(prompt) then continue end
        SetPrompt(prompt,prompt.MaxActivationDistance / 2 )
    end
end)