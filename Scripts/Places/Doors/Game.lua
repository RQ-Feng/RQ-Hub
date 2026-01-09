ESPLibrary.GlobalConfig['Rainbow'] = true
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

local Floors = {
    ['Garden'] = 'Outdoors',
    ['Ripple'] = {
        ['CringlesWorkshop'] = 'Cringle\'s Workshop',
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

local function PromptIsChecked(prompt) return prompt.MaxActivationDistance < 10 end

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

    local RealEvent = cacheRealModule or cacheModule
    local FakeEvent = cacheRealModule and cacheModule or cacheModule:Clone()

    RealEvent.Name = value and RealModuleName or Name

    if value then
        table.insert(RealRemoteModules,RealEvent)
        FakeEvent.Parent = RemoteModules        
    else 
        table.remove(RealRemoteModules,table.find(RealRemoteModules,RealEvent))
        FakeEvent:Destroy()
    end
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
    ['FuseObtain'] = '保险丝',
    ['LeverForGate'] = '拉杆',
    ['LiveHintBook'] = '书本'
}

local Items = {
    ['Lighter'] = '打火机',
    ['Lockpick'] = '撬锁器',
    ['Vitamins'] = '维他命',
    ['Smoothie'] = '奶昔',
    ['Bandage'] = '绷带',
    ['Candle'] = '蜡烛',
    ['Flashlight'] = '手电筒',
    ['SkeletonKey'] = '骷髅钥匙',
    ['Crucifix'] = '十字架',
    ['LiveHintBook'] = '书本',
    ['LiveBreakerPolePickup'] = '开关'
}

local localEntities = {

}

local Entities = {
    ['RushMoving'] = 'Rush',
    ['AmbushMoving'] = 'Ambush',
    ['Eyes'] = 'Eyes',
    ['GloombatSwarm'] = 'Gloombats',
    ['BackdoorRush'] = 'Rush',
    ['BackdoorLookman'] = 'Lookman',
    ['A60'] = 'A60',
    ['A120'] = 'A120',
    ['Mobble'] = 'Sally',
    ['SallyMoving'] = 'Sally',
    ['JeffTheKiller'] = 'Jeff',
    ['MonumentEntity'] = 'Monument',
    ['Dread'] = 'Dread',
    ['OnlyLocalization'] = {
        ['FigureRig'] = 'Figure'
        --['HaltMoving'] = 'Halt'
    }
}

local Prompts = {
    'ModulePrompt',
    'UnlockPrompt',
    'LootPrompt',
    'ActivateEventPrompt'
}

local function EspItem(ItemName,DisplayTable,Value)
    local thr = coroutine.create(function()
        for _,item in pairs(workspace:GetDescendants()) do
            if item.Name == ItemName and item:IsA('Model') and not Players:GetPlayerFromCharacter(item.Parent) and item.Parent.Name ~= 'SallyMoving' then 
                AddESP({inst = item,Name = DisplayTable[ItemName] or GameItems[ItemName],value = Value}) 
            end
        end
        AddConnection(workspace.DescendantAdded,function(descendant)
            if descendant.Name == ItemName and descendant:IsA('Model') and not Players:GetPlayerFromCharacter(descendant.Parent) and descendant.Parent.Name ~= 'SallyMoving' then 
                AddESP({inst = descendant,Name = DisplayTable[ItemName] or GameItems[ItemName],value = Value}) 
            end
        end,Value)
    end)
    coroutine.resume(thr)
end

Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Feature = Window:MakeTab({
    Name = "功能",
    Icon = "rbxassetid://4483345998"
})
Floor = Window:MakeTab({
    Name = "楼层",
    Icon = "rbxassetid://4483345998"
})
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
Anti = Window:MakeTab({
    Name = "防",
    Icon = "rbxassetid://4483345998"
})
Tab:AddSection({Name = "速度"})
local SpeedWays = {"SpeedBoost", "SpeedBoostBehind"}
local function CheckSpeed(way)
    Character:SetAttribute(way,OrionLib.Flags['Speed'].Value)
    local event = AddConnection(Character:GetAttributeChangedSignal(way),function()
        Character:SetAttribute(way,OrionLib.Flags['Speed'].Value)
    end,OrionLib.Flags['EnableSpeed'])
    repeat task.wait() until OrionLib.Flags['SpeedWay'].Value ~= way or not OrionLib.Flags['EnableSpeed'].Value or not OrionLib:IsRunning()
    if event then event:Disconnect() end
    Character:SetAttribute(way,0)
end
Tab:AddDropdown({
    Name = "加速方式",
    Flag = 'SpeedWay',
    Default = "SpeedBoost",
    Options = SpeedWays,
    Callback = CheckSpeed
})
Tab:AddToggle({
    Name = "启动加速",
    Default = false,
    Flag = 'EnableSpeed',
    Callback = function(Value)
        if not Value then return end
        CheckSpeed(OrionLib.Flags['SpeedWay'].Value)
    end
})
Tab:AddSlider({
    Name = "速度",
    Min = 0,
    Max = 50,
    Default = 0,
    Increment = 1,
    Flag = 'Speed',
    Callback = function(spd)
        if not OrionLib.Flags['EnableSpeed'].Value then return end
        Character:SetAttribute(OrionLib.Flags['SpeedWay'].Value, spd)
    end
})
Tab:AddSection({Name = "其他"})
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
Tab:AddToggle({
    Name = "轻松交互",
    Flag = 'BetterPrompt',
    Default = true,
    Callback = function(Value)
        for _,prompt in pairs(workspace:GetDescendants()) do 
            if not prompt:IsA('ProximityPrompt') then continue end
            SetPrompt(prompt,(not Value and PromptIsChecked(prompt)) and prompt.MaxActivationDistance / 2 or prompt.MaxActivationDistance * 2)
        end; if not Value then return end
        AddConnection(workspace.DescendantAdded,function(prompt)
            if not prompt:IsA('ProximityPrompt') then return end
            SetPrompt(prompt,prompt.MaxActivationDistance * 2)
        end,OrionLib.Flags['BetterPrompt'])
    end
})
Tab:AddToggle({
    Name = "自动交互",
    Flag = 'AutoPrompt',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        AddConnection(game:GetService('ProximityPromptService').PromptShown,function(prompt)
            if not table.find(Prompts,prompt.Name) then return end
            while prompt and prompt:FindFirstAncestorOfClass('Model') and not prompt:FindFirstAncestorOfClass('Model'):FindFirstChild('LootHolder') do 
                fireproximityprompt(prompt); task.wait() 
            end
        end,OrionLib.Flags['AutoPrompt'])
    end
})
Tab:AddToggle({
    Name = "实体提示",
    Flag = 'EntityNotify',
    Default = false,
    Callback = function(Value)
        AddConnection(workspace.DescendantAdded,function(descendant)
            if table.find(Entities,descendant.Name) and descendant:IsA('Model') then
                Notify({
                    Title = "实体提示",
                    Text = Entities[descendant.Name].." 已出现！",
                    Duration = 5
                })
            end
        end,OrionLib.Flags['EntityNotify'])
    end
})
-- Tab:AddToggle({ -- 高亮
--     Name = "高亮(低质量)",
--     Flag = 'FullBrightLite',
--     Default = true,
--     Callback = function(Value)
--         if not Value then return end
--         FullBrightLite(OrionLib.Flags['FullBrightLite'])
--     end
-- })
Feature:AddSection({Name = "绕过"})
Feature:AddSlider({
    Name = "绕过速率",
    Min = 0.2,
    Max = 0.3,
    Default = 0.23,
    Increment = 0.01,
    Flag = 'BypassSpeedACRate'
})
Feature:AddToggle({
    Name = "速度绕过",
    Default = false,
    Flag = 'BypassSpeedAC',
    Callback = function(Value)
        if not Value then return end
        local CollisionPart = Character:FindFirstChild('CollisionPart')
        local CloneCollisionPart

        local function clone(char)
            CloneCollisionPart = char:FindFirstChild('CollisionPart'):Clone()
            CloneCollisionPart.Parent = char
            CloneCollisionPart.CanCollide = false
            CloneCollisionPart.Name = '_CollisionPart'
            return CloneCollisionPart
        end
        
        CloneCollisionPart = Character:FindFirstChild('_CollisionPart') or clone(Character)

        local function BypassSpeedAC()
            while OrionLib.Flags['BypassSpeedAC'].Value and OrionLib:IsRunning() do
                if CloneCollisionPart then CloneCollisionPart.Massless = not CloneCollisionPart.Massless end
                task.wait(OrionLib.Flags['BypassSpeedACRate'].Value) 
            end
        end; BypassSpeedAC()

        AddConnection(LocalPlayer.CharacterAdded,clone,OrionLib.Flags['BypassSpeedAC'])
        AddConnection(CollisionPart:GetPropertyChangedSignal('Anchored'),function()
            OrionLib.Flags['BypassSpeedAC']:Set(false)
            OrionLib:MakeNotification({
                Name = "速度绕过",
                Content = "检测到滞后,已自动关闭.",
                Time = 2
            })
        end,OrionLib.Flags['BypassSpeedAC'])

        repeat task.wait() until not OrionLib.Flags['BypassSpeedAC'].Value or not OrionLib:IsRunning()

        CloneCollisionPart:Destroy()
    end
})
Feature:AddSection({Name = "玩家"})
Feature:AddToggle({
    Name = "God mode",
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
    Flag = 'SilentCrouch',
    Default = false,
    Callback = function(Value)
        if not Value then RemotesFolder.Crouch:FireServer(false); return end
        RemotesFolder.Crouch:FireServer(true)
        AddConnection(Character:GetAttributeChangedSignal('Crouching'), function(Crouch)
            if Crouch then return end
            RemotesFolder.Crouch:FireServer(true)
        end, OrionLib.Flags['SilentCrouch'])
    end
})
Feature:AddToggle({
    Name = "更小碰撞箱",
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
    Flag = 'CanSlide',
    Default = false,
    Callback = function(Value)
        Character:SetAttribute("CanSlide", Value)
        if not Value then return end
        AddConnection(Character:GetAttributeChangedSignal('CanSlide'),function() Character:SetAttribute("CanSlide", Value) end,OrionLib.Flags['CanSlide'])
    end
})
Feature:AddSection({Name = "其他"})
Feature:AddToggle({
    Name = "远处开门",
    Flag = 'OpenDoorFarer',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        task.spawn(function()
            repeat CurrentRoom().Door.ClientOpen:FireServer() task.wait() until not OrionLib.Flags['OpenDoorFarer'].Value or not OrionLib:IsRunning()
        end)
    end
})
-- Feature:AddDropdown({
-- 	Name = "Dropdown",
--     Flag = 'Dropdown',
-- 	Default = "1",
-- 	Options = {"1", "2"},
-- 	Callback = function(Value)
-- 		print(Value)
-- 	end    
-- })
Esp:AddToggle({
    Name = "真门透视",
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
    Default = false,
    Flag = 'DupeDoorEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('KeyObtain',GameItems,OrionLib.Flags['KeyEsp'])
    end
})
Esp:AddToggle({
    Name = "钥匙透视",
    Default = false,
    Flag = 'KeyEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('KeyObtain',GameItems,OrionLib.Flags['KeyEsp'])
    end
})
Esp:AddToggle({
    Name = "保险丝透视",
    Default = false,
    Flag = 'FuseEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('FuseObtain',GameItems,OrionLib.Flags['FuseEsp'])
    end
})
Esp:AddToggle({
    Name = "拉杆透视",
    Default = false,
    Flag = 'LeverEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('LeverForGate',GameItems,OrionLib.Flags['LeverEsp'])
    end
})

Esp:AddToggle({
    Name = "物品透视",
    Default = false,
    Flag = 'ItemsEsp',
    Callback = function(Value)
        if not Value then return end
        for item,name in pairs(Items) do EspItem(item,Items,OrionLib.Flags['ItemsEsp']) end
    end
})

Esp:AddToggle({
    Name = "实体透视",
    Default = false,
    Flag = 'EntitiesEsp',
    Callback = function(Value)
        if not Value then return end
        for name,_ in pairs(Entities) do
            task.spawn(function()
                for _,monster in pairs(workspace:GetDescendants()) do
                    if monster.Name == name and item:IsA('Model') and not Players:GetPlayerFromCharacter(item.Parent) and item.Parent.Name ~= 'SallyMoving' then 
                        local Mode = monster.Name == 'Eyes' and 'SphereAdornment' or 'CylinderAdornment'
                        AddESP({inst = item,Name = Entities[name],value = OrionLib.Flags['EntitiesEsp'],Type = Mode}) 
                    end
                end
                AddConnection(workspace.DescendantAdded,function(descendant)
                    if descendant.Name == name and descendant:IsA('Model') and not Players:GetPlayerFromCharacter(descendant.Parent) and descendant.Parent.Name ~= 'SallyMoving' then 
                        local Mode = monster.Name == 'Eyes' and 'SphereAdornment' or 'CylinderAdornment'
                        AddESP({inst = item,Name = Entities[name],value = OrionLib.Flags['EntitiesEsp'],Type = Mode}) 
                    end
                end,OrionLib.Flags['EntitiesEsp'])
            end)
        end
    end
})
Floor:AddLabel('您当前位于 '..CurrentFloor()..' 楼层.')
Anti:AddToggle({
    Name = "防相机抖动",
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'CamShake') end
})
Anti:AddToggle({
    Name = "防跳杀",
    Default = false,
    Callback = function(Value) 
        FakeRemoteModule(Value,'jumpscares')
        FakeEvent(Value,'SpiderJumpscare')
    end
})
Anti:AddToggle({
    Name = "防过场",
    Default = false,
    Callback = function(Value) 
        FakeRemoteModule(Value,'Cutscenes')
        FakeEvent(Value,'Cutscene')
    end
})
Anti:AddSection({Name = "防实体"})
Anti:AddToggle({
    Name = "防A90",
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'A90') end
})
Anti:AddToggle({
    Name = "防Screech",
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'Screech') end
})
Anti:AddToggle({
    Name = "防Halt",
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'ShadeResult') end
})
Anti:AddToggle({
    Name = "防Eyes/Lookman",
    Flag = 'Anti_Eyes_Lookman',
    Default = false,
    Callback = function(Value) 
        if not Value then return end
        local MotorReplication = RemotesFolder.MotorReplication
        for i = 1,10 do MotorReplication:FireServer(-1000) end
        MotorReplication.Parent = nil
        repeat task.wait() until not OrionLib.Flags['Anti_Eyes_Lookman'].Value or not OrionLib:IsRunning()
        MotorReplication.Parent = RemotesFolder
    end
})
RemotesFolder.MotorReplication:FireServer(-750)
Anti:AddToggle({
    Name = "防Dread",
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'Dread') end
})
Anti:AddToggle({
    Name = "防Surge",
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'SurgeRemote') end
})
Anti:AddToggle({
    Name = "防Dread",
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'Dread') end
})
AddConnection(LatestRoom.Changed,function(value)
    if OrionLib.Flags['RealDoorEsp'].Value then --RealDoorEsp
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