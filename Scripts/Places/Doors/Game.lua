--ESPLibrary.GlobalConfig['Rainbow'] = true
local RemotesFolder = game:GetService("ReplicatedStorage").RemotesFolder

local function CurrentRoom()
    return workspace.CurrentRooms[game:GetService("ReplicatedStorage").GameData.LatestRoom.Value]
end

local function CurrentFloor()
    return game:GetService("ReplicatedStorage").GameData.Floor.Value
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
    ['Crucifix'] = '十字架'
}

local Entities = {
    ['RushMoving'] = 'Rush',
    ['AmbushMoving'] = 'Ambush',
    ['SallyMoving'] = 'Sally',
    ['Eyes'] = 'Eyes',
    ['Dupe'] = 'Dupe'
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
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
Anti = Window:MakeTab({
    Name = "防实体",
    Icon = "rbxassetid://4483345998"
})
Tab:AddToggle({
    Name = "轻松交互",
    Flag = 'BetterPrompt',
    Default = true,
    Callback = function(Value)
        if not Value then return end
        BetterPrompt(12,OrionLib.Flags['BetterPrompt'])
    end
})
Tab:AddToggle({
    Name = "自动交互",
    Flag = 'AutoPrompt',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        local thr = coroutine.create(function()
            while OrionLib.Flags['AutoPrompt'].Value and OrionLib:IsRunning() do
                for _, descendant in ipairs(workspace:GetDescendants()) do
                    if not descendant:IsA('ProximityPrompt') or (descendant.Parent:GetPivot().Position - HumanoidRootPart.Position).Magnitude > 12 then continue end
                    if descendant.Parent.Parent.Name == 'DrawerContainer' and not descendant.Parent.Parent:FindFirstChild('LootHolder') then
                       fireproximityprompt(descendant) continue
                    elseif table.find(Prompts,descendant.Name) then fireproximityprompt(descendant) continue end
                end
                task.wait()
            end
        end)
        coroutine.resume(thr)
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
--Feature:AddSection({Name = "绕过"})
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
        end
        
        if not Character:FindFirstChild('_CollisionPart') then clone(Character) end
        CloneCollisionPart = Character:FindFirstChild('_CollisionPart')

        local function BypassAC()
            while OrionLib.Flags['BypassAC'].Value and OrionLib:IsRunning() do
                if CloneCollisionPart then CloneCollisionPart.Massless = not CloneCollisionPart.Massless end
                task.wait(0.4)                
            end
        end

        BypassAC();AddConnection(LocalPlayer.CharacterAdded,function(newchar) clone(newchar) end,OrionLib.Flags['BypassAC'])
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
Feature:AddSection({Name = "玩家"})
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
    Name = "更小碰撞箱",
    Flag = 'SmallHitbox',
    Default = false,
    Callback = function(Value)
        SetClipFunction(Character)
        AddConnection(LocalPlayer.CharacterAdded,SetClipFunction,OrionLib.Flags['SmallHitbox'])
        AddConnection(Character.Collision:GetPropertyChangedSignal("CanCollide"),SetClipFunction,OrionLib.Flags['SmallHitbox'])
        AddConnection(Character.Collision.CollisionCrouch:GetPropertyChangedSignal("CanCollide"),SetClipFunction,OrionLib.Flags['SmallHitbox'])
        repeat task.wait() until not OrionLib.Flags['SmallHitbox'].Value or not OrionLib:IsRunning()
        SetClipFunction(Character,true)
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
-- Feature:AddToggle({
--     Name = "God mode",
--     Default = false,
--     Flag = 'Godmode',
--     Callback = function(Value)
--         if not Value then return end

--         local NoCharRaycastParam = RaycastParams.new()
--         NoCharRaycastParam.FilterType = Enum.RaycastFilterType.Exclude
--         NoCharRaycastParam.FilterDescendantsInstances = {Character}

--         SetClipFunction(Character)

--         AddConnection(Character.Collision:GetPropertyChangedSignal("CanCollide"),SetClipFunction,OrionLib.Flags['Godmode'])

--         AddConnection(Character.Collision.CollisionCrouch:GetPropertyChangedSignal("CanCollide"),function()
--             SetClipFunction(Character)
--             for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
--                 if track.Animation.AnimationId == Character.Animations.Crouch.AnimationId then
--                     track:Stop(0);break
--                 end
--             end
--         end,OrionLib.Flags['Godmode'])

--         local raycast = workspace:Raycast(HumanoidRootPart.Position,Vector3.new(HumanoidRootPart.Position.X,-1000,HumanoidRootPart.Position.Z), NoCharRaycastParam)
--         if not raycast then return end
--         Character.Collision.Position = HumanoidRootPart.Position - Vector3.new(0, raycast.Distance - 0.9, 0)
--         if Character:FindFirstChild('_CollisionPart') then Character:FindFirstChild('_CollisionPart').Position = Character.Collision.Position + Vector3.new(0, 2.5, 0) end

--         repeat task.wait() until not OrionLib.Flags['Godmode'].Value or not OrionLib:IsRunning() 

--         if Character.Collision.Position ~= HumanoidRootPart.Position then Character.Collision.Position = HumanoidRootPart.Position end
--         if Character:FindFirstChild('_CollisionPart') and Character:FindFirstChild('_CollisionPart').Position ~= HumanoidRootPart.Position then 
--             Character:FindFirstChild('_CollisionPart').Position = Character.Collision.Position + Vector3.new(0, 2.5, 0) --idk what is the correct distance xD
--         end
--         Character.Collision.CanCollide = not Character:GetAttribute("Crouching")
--         if Character.Collision:FindFirstChild("CollisionCrouch") then
--             Character.Collision.CollisionCrouch.CanCollide = Character:GetAttribute("Crouching")
--         end
--     end
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