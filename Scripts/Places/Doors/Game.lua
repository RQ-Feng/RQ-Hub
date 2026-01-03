ESPLibrary.GlobalConfig['Rainbow'] = true
local RemotesFolder = ReplicatedStorage.RemotesFolder
local GameData = ReplicatedStorage.GameData
local Floors = {
    ['Garden'] = 'Outdoors',
    ['Ripple'] = {
        ['CringlesWorkshop'] = 'Cringle\'s Workshop',
        ['Daily_Default'] = 'Daily Runs'
    }
} 
local function CurrentRoom()
    return workspace.CurrentRooms[GameData.LatestRoom.Value]
end

local function CurrentFloor()
    local floor,floorSpecific = GameData.Floor.Value,GameData.FloorSpecific.Value
    return typeof(Floors[floor]) == 'table' and Floors[floor][floorSpecific] or Floors[floor] or floor
end

local function SetClipFunction(char,value)
    local value = value or false
    char.Collision.CollisionGroup = "PlayerCrouching"
    char.Collision.CollisionCrouch.CollisionGroup = "PlayerCrouching"

    char.Collision.CanCollide = value
    char.Collision.CollisionCrouch.CanCollide = value

    if Character:FindFirstChild('_CollisionPart') then Character:FindFirstChild('_CollisionPart').CanCollide = value end
end

local GameItems = {
    ['KeyObtain'] = '钥匙',
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

local Entities = {
    ['RushMoving'] = 'Rush',
    ['AmbushMoving'] = 'Ambush',
    ['SallyMoving'] = 'Sally',
    ['Eyes'] = 'Eyes',
    ['Dupe'] = 'Dupe',
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
    Name = "防实体",
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
        if not Value then return end
        BetterPrompt(16,OrionLib.Flags['BetterPrompt'])
    end
})
Tab:AddToggle({
    Name = "自动交互",
    Flag = 'AutoPrompt',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        AddConnection(game:GetService('ProximityPromptService').PromptShown,function(prompt :ProximityPrompt)
            if not table.find(Prompts,prompt.Name) then return end
            prompt.MaxActivationDistance = 16
            while prompt and not prompt:FindFirstAncestorOfClass('Model'):FindFirstChild('LootHolder') do fireproximityprompt(prompt); task.wait() end
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
    Name = "绕过速度",
    Min = 0.2,
    Max = 0.3,
    Default = 0.22,
    Increment = 0.01,
    Flag = 'BypassACSpeed'
})
Feature:AddToggle({
    Name = "绕过拉回",
    Default = false,
    Flag = 'BypassAC',
    Callback = function(Value)
        if not Value then return end
        local CloneCollisionPart
        local function clone(char)
            CloneCollisionPart = char:FindFirstChild('CollisionPart'):Clone()
            CloneCollisionPart.Parent = char
            CloneCollisionPart.CanCollide = false
            CloneCollisionPart.Name = '_CollisionPart'
            return CloneCollisionPart
        end
        
        CloneCollisionPart = Character:FindFirstChild('_CollisionPart') or clone(Character)

        local function BypassAC()
            while OrionLib.Flags['BypassAC'].Value and OrionLib:IsRunning() do
                if CloneCollisionPart then CloneCollisionPart.Massless = not CloneCollisionPart.Massless end
                task.wait(OrionLib.Flags['BypassACSpeed'].Value) 
            end
        end

        BypassAC();AddConnection(LocalPlayer.CharacterAdded,function(newchar) clone(newchar) end,OrionLib.Flags['BypassAC'])

        repeat task.wait() until not OrionLib.Flags['BypassAC'].Value or not OrionLib:IsRunning()

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
        local OriginalHipHeight = Humanoid.HipHeight
        Humanoid.HipHeight = 0.001
        AddConnection(Humanoid:GetPropertyChangedSignal("HipHeight"),function() Humanoid.HipHeight = 0.001 end,OrionLib.Flags['Godmode'])

        SetClipFunction(Character)
        AddConnection(Character.Collision:GetPropertyChangedSignal("CanCollide"),function() SetClipFunction(Character) end,OrionLib.Flags['Godmode'])
        AddConnection(Character.Collision.CollisionCrouch:GetPropertyChangedSignal("CanCollide"),function() SetClipFunction(Character) end,OrionLib.Flags['Godmode'])

        OrionLib.Flags['SilentCrouch'].Set(true)

        local function GodmodeLoop()
            repeat task.wait() until not OrionLib.Flags['SilentCrouch'].Value or not not OrionLib.Flags['Godmode'].Value or not OrionLib:IsRunning() 
            if not OrionLib.Flags['Godmode'].Value then return end
            OrionLib.Flags['SilentCrouch']:Set(true)
            OrionLib:MakeNotification({
                Name = "Godmode",
                Content = "请不要手动关闭静步.",
                Time = 2
            })
            GodmodeLoop()
        end

        GodmodeLoop()

        repeat task.wait() until not OrionLib.Flags['Godmode'].Value or not OrionLib:IsRunning()
        Humanoid.HipHeight = OriginalHipHeight
    end
})
Feature:AddToggle({
    Name = "静步",
    Flag = 'SilentCrouch',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        RemotesFolder.Crouch:FireServer(true)
        AddConnection(Character:GetAttributeChangedSignal('Crouching'), function(Crouch)
            if Crouch then return end
            RemotesFolder.Crouch:FireServer(true)
        end, OrionLib.Flags['SilentCrouch'])
        repeat task.wait() until not OrionLib.Flags['SilentCrouch'].Value or not OrionLib:IsRunning()
        RemotesFolder.Crouch:FireServer(false)
    end
})
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
        AddConnection(Character:GetAttributeChangedSignal('CanJump'),function() Character:SetAttribute("CanJump", Value) end,OrionLib.Flags['CanJump'])
        repeat task.wait() until not OrionLib.Flags['CanJump'].Value or not OrionLib:IsRunning()
        Character:SetAttribute("CanJump",false)
    end
})
Feature:AddToggle({
    Name = "开启滑铲",
    Flag = 'CanSlide',
    Default = false,
    Callback = function(Value)
        Character:SetAttribute("CanSlide", Value)
        AddConnection(Character:GetAttributeChangedSignal('CanSlide'),function() Character:SetAttribute("CanSlide", Value) end,OrionLib.Flags['CanSlide'])
        repeat task.wait() until not OrionLib.Flags['CanSlide'].Value or not OrionLib:IsRunning()
        Character:SetAttribute("CanSlide",false)
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
    Name = "钥匙透视",
    Default = false,
    Flag = 'KeyEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('KeyObtain',GameItems,OrionLib.Flags['KeyEsp'])
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
            local thr = coroutine.create(function()
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
            coroutine.resume(thr)
        end
    end
})
Floor:AddLabel('您当前位于 '..CurrentFloor()..' 楼层.')