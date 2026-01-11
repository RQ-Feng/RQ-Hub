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
    ['ElectricalKeyObtain'] = '电气室钥匙',
    ['FuseObtain'] = '保险丝',
    ['LiveBreakerPolePickup'] = '开关',
    ['LeverForGate'] = '拉杆',
    ['LibraryHintPaper'] = '纸',
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

local InteractPrompts = {
    'ModulePrompt',
    'UnlockPrompt',
    'LootPrompt',
    'ActivateEventPrompt'
}

local Interact_Blacklist = {
    'Padlock',
    'JeffShop_Hotel',
    'ElevatorBreaker'
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
--Feature Function
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
    Callback = function(Value)
        if not Value then return end
        CheckSpeed(OrionLib.Flags['SpeedWay'].Value)
    end
})
Tab:AddSlider({
    Name = "速度",
    Save = true,
    Min = 0,
    Max = 75,
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
            prompt.MaxActivationDistance / 2 or InteractPrompts[prompt.Name] or prompt.MaxActivationDistance * 2)
        end; if not Value then return end
        AddConnection(workspace.DescendantAdded,function(prompt)
            if not prompt:IsA('ProximityPrompt') then return end
            SetPrompt(prompt,InteractPrompts[prompt.Name] or prompt.MaxActivationDistance * 2)
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
            if not table.find(InteractPrompts,prompt.Name) then return end
            local ModelParent = prompt:FindFirstAncestorOfClass('Model')
            while prompt and ModelParent and not table.find(Interact_Blacklist,ModelParent.Name) and not ModelParent:FindFirstChild('LootHolder') 
            and OrionLib:IsRunning() and OrionLib.Flags['AutoPrompt'].Value do 
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
-- Tab:AddToggle({
--     Name = "高亮",
--     Flag = '',
--     Default = true,
--     Callback = function(Value)
--         if not Value then return end
--     end
-- })
Feature:AddSection({Name = "绕过"})
Feature:AddSlider({
    Name = "绕过速率",
    Save = true,
    Min = 0.2,
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
        local CloneCollisionPart

        local function clone(char)
            CloneCollisionPart = char:FindFirstChild('CollisionPart'):Clone()
            CloneCollisionPart.Parent = char
            CloneCollisionPart.CanCollide = false
            CloneCollisionPart.Anchored = false
            CloneCollisionPart.Name = '_CollisionPart'
            return CloneCollisionPart
        end
        
        CloneCollisionPart = Character:FindFirstChild('_CollisionPart') or clone(Character)

        local function BypassSpeedAC()
            task.spawn(function()
                while OrionLib.Flags['BypassSpeedAC'].Value and OrionLib:IsRunning() do
                    if CloneCollisionPart then CloneCollisionPart.Massless = not CloneCollisionPart.Massless end
                    task.wait(OrionLib.Flags['BypassSpeedACRate'].Value) 
                end
            end)
        end; BypassSpeedAC()

        AddConnection(LocalPlayer.CharacterAdded,clone,OrionLib.Flags['BypassSpeedAC'])
        AddConnection(CollisionPart:GetPropertyChangedSignal('Anchored'),function()
            if not CollisionPart.Anchored then return end
            OrionLib.Flags['BypassSpeedAC']:Set(false)
            local Notify = OrionLib:MakeNotification({
                Name = "速度绕过",
                Content = "检测到滞后,已自动关闭.",
                Time = 2
            })
            repeat task.wait() until not CollisionPart.Anchored or not OrionLib:IsRunning()
            if not OrionLib:IsRunning() then return end
            if Notify then OrionLib:CloseNotification(Notify) end
            OrionLib.Flags['BypassSpeedAC']:Set(true)
            local Notify = OrionLib:MakeNotification({
                Name = "速度绕过",
                Content = "已自动重启.",
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
                if (char and OxygenNotify) and char:GetAttribute('Oxygen') == 100 then OxygenNotify:Close() end
            end)
        end

        OxygenNotify = Notify({
            Text = '剩余氧气',
            Content = Character:GetAttribute('Oxygen')
        }); SetCloseTask(Character)

        local function CheckOxygen(char)
            if CheckOxygenEvent then CheckOxygenEvent:Disconnect() end
            CheckOxygenEvent = AddConnection(char:GetAttributeChangedSignal('Oxygen'),function()
                local currentOxygen = char:GetAttribute('Oxygen')

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
            inst = SideRoomDupe:WaitForChild('DoorFake'),
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
        EspItem('KeyObtain',GameItems,OrionLib.Flags['KeyEsp'])
    end
})
Esp:AddToggle({
    Name = "保险丝透视",
    Save = true,
    Default = false,
    Flag = 'FuseEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('FuseObtain',GameItems,OrionLib.Flags['FuseEsp'])
    end
})
Esp:AddToggle({
    Name = "拉杆透视",
    Save = true,
    Default = false,
    Flag = 'LeverEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('LeverForGate',GameItems,OrionLib.Flags['LeverEsp'])
    end
})

Esp:AddToggle({
    Name = "物品透视",
    Save = true,
    Default = false,
    Flag = 'ItemsEsp',
    Callback = function(Value)
        if not Value then return end
        for item,name in pairs(Items) do EspItem(item,Items,OrionLib.Flags['ItemsEsp']) end
    end
})

Esp:AddToggle({
    Name = "实体透视",
    Save = true,
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
local function CheckFloor(floorName,flag)
    if not floorName then return warn('[CheckFloor] Got nil floor name.') end
    local correctFloor = CurrentFloor() == floorName
    if correctFloor then return true end
    OrionLib:MakeNotification({
        Name = '楼层检测',
        Content = '此楼层不支持该功能.',
        Time = 5
    }); if flag then flag:Set(false) end
    return false
end
Floor:AddLabel('您当前位于 '..CurrentFloor()..' 楼层.')
Floor:AddSection({Name = "酒店"})
Floor:AddSlider({
    Name = "开锁距离",
    Save = true,
    Min = 10,
    Max = 150,
    Default = 20,
    Increment = 1,
    Flag = 'AutoLibraryUnlockDistance'
})
Floor:AddToggle({
    Name = "自动图书馆开锁",
    Save = true,
    Default = false,
    Flag = 'AutoLibraryUnlock',
    Callback = function(Value)
        if not Value or not CheckFloor('Hotel',OrionLib.Flags['AutoLibraryUnlock']) then return end
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
        if not Value then return end
        repeat RemotesFolder.EBF:FireServer(); task.wait() until not OrionLib.Flags['AutoBreaker'].Value or not OrionLib:IsRunning()
    end
})
Anti:AddToggle({
    Name = "防相机抖动",
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'CamShake') end
})
Anti:AddToggle({
    Name = "防跳杀",
    Save = true,
    Default = false,
    Callback = function(Value) 
        FakeRemoteModule(Value,'jumpscares')
        FakeEvent(Value,'SpiderJumpscare')
    end
})
Anti:AddToggle({
    Name = "防过场",
    Save = true,
    Default = false,
    Callback = function(Value) 
        FakeRemoteModule(Value,'Cutscenes')
        FakeEvent(Value,'Cutscene')
    end
})
Anti:AddSection({Name = "防实体"})
Anti:AddToggle({
    Name = "防A90",
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'A90') end
})
Anti:AddToggle({
    Name = "防Screech",
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'Screech') end
})
Anti:AddToggle({
    Name = "防Halt",
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
        local MotorReplication = RemotesFolder.MotorReplication
        for i = 1,10 do MotorReplication:FireServer(-1000) end
        MotorReplication.Parent = nil
        RemotesFolder.PlayerDied.OnClientEvent:Once(function() OrionLib.Flags['Anti_Eyes_Lookman']:Set(false) end)
        repeat task.wait() until not OrionLib.Flags['Anti_Eyes_Lookman'].Value or not OrionLib:IsRunning()
        MotorReplication.Parent = RemotesFolder
    end
})
RemotesFolder.MotorReplication:FireServer(-750)
Anti:AddToggle({
    Name = "防Dread",
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'Dread') end
})
Anti:AddToggle({
    Name = "防Surge",
    Save = true,
    Default = false,
    Callback = function(Value) AntiClientEntity(Value,'SurgeRemote') end
})
Anti:AddToggle({
    Name = "防Dread",
    Save = true,
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
    if OrionLib.Flags['DupeDoorEsp'].Value then --DupeDoorEsp
        task.spawn(function()
            local SideRoomDupe = CurrentRoom():WaitForChild('SideroomDupe',2)
            if not SideRoomDupe then return end
            local DupeDoorEsp = AddESP({
                inst = SideRoomDupe:WaitForChild('DoorFake',2),
                Name = 'Dupe门',
                value = OrionLib.Flags['DupeDoorEsp'],
                Color = Color3.new(1,0,0)
            }); task.spawn(function()
                repeat task.wait() until LatestRoom.Value ~= value
                if DupeDoorEsp then DupeDoorEsp:Destroy() end
            end)
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