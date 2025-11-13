ESPLibrary.GlobalConfig['Rainbow'] = true

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
    ['Candle'] = '蜡烛',
    ['Flashlight'] = '手电筒',
    ['SkeletonKey'] = '骷髅钥匙',
    ['Crucifix'] = '十字架'
}

local function EspItem(ItemName,Value)
    for _,item in pairs(workspace:GetDescendants()) do
        if item.Name == ItemName and item:IsA('Model') and not Players:GetPlayerFromCharacter(item.Parent) then 
            AddESP({inst = item,Name = Items[ItemName] or GameItems[ItemName],value = Value}) 
        end
    end
    AddConnection(workspace.DescendantAdded,function(descendant)
        if descendant.Name == ItemName and descendant:IsA('Model') and not Players:GetPlayerFromCharacter(descendant.Parent) then 
            AddESP({inst = descendant,Name = Items[ItemName] or GameItems[ItemName],value = Value}) 
        end
    end,Value)
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
Tab:AddToggle({ -- 轻松交互
    Name = "轻松交互",
    Flag = 'BetterPrompt',
    Default = true,
    Callback = function(Value)
        if not Value then return end
        BetterPrompt(12,OrionLib.Flags['BetterPrompt'])
    end
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Flag = 'FullBrightLite',
    Default = true,
    Callback = function(Value)
        if not Value then return end
        FullBrightLite(OrionLib.Flags['FullBrightLite'])
    end
})
Feature:AddSection({Name = "绕过"})
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
            while OrionLib.Flags['BypassAC'] and OrionLib:IsRunning() do
                if CloneCollisionPart then CloneCollisionPart.Massless = not CloneCollisionPart.Massless end
                task.wait(0.23)                
            end
        end

        BypassAC();AddConnection(LocalPlayer.CharacterAdded,function(newchar) clone(newchar) end,OrionLib.Flags['BypassAC'])
    end
})
Feature:AddToggle({
    Name = "God mode",
    Default = false,
    Flag = 'Godmode',
    Callback = function(Value)

    end
})
Esp:AddToggle({
    Name = "钥匙透视",
    Default = false,
    Flag = 'KeyEsp',
    Callback = function(Value)
        if not Value then return end
        for _,item in pairs(workspace:GetDescendants()) do
            if item.Name == 'KeyObtain' and item:WaitForChild('Hitbox',10) then AddESP({inst = item,Name = '钥匙',value = OrionLib.Flags['KeyEsp']}) end
        end
        AddConnection(workspace.DescendantAdded,function(descendant)
            if descendant.Name == 'KeyObtain' and descendant:WaitForChild('Hitbox', 10) then AddESP({inst = descendant,Name = '钥匙',value = OrionLib.Flags['KeyEsp']}) end
        end,OrionLib.Flags['KeyEsp'])
    end
})
Esp:AddToggle({
    Name = "拉杆透视",
    Default = false,
    Flag = 'LeverEsp',
    Callback = function(Value)
        if not Value then return end
        EspItem('LeverForGate',OrionLib.Flags['LeverEsp'])
    end
})
Esp:AddToggle({
    Name = "物品透视",
    Default = false,
    Flag = 'ItemsEsp',
    Callback = function(Value)
        if not Value then return end
        for item,name in pairs(Items) do EspItem(item,OrionLib.Flags['ItemsEsp']) end
    end
})