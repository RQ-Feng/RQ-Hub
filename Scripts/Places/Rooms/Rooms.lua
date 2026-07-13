-- local设置
local a60 = workspace:WaitForChild("monster")
local a120 = workspace:WaitForChild("monster2")
local NotifyEntities,workspaceDA
--local结束->Function设置
local function entityNotifi(entityname) -- 实体提醒
    OrionNotify("实体提醒", entityname)
end
-- #sym:ESPLibrary
local function AddRoomESP(obj,name,color3) -- Esp
    AddESP({
        inst = obj,
        Name = name,
        Color = color3,
    })
end
local playerPositions = {}
local function teleportPlayer(player,toPositionVector3)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        playerPositions[player.UserId] = player.Character.HumanoidRootPart.CFrame
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
--Function结束-其他
OrionNotify("加载完成", "已成功加载")
--Tab界面
local Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
local Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
local others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998"
})
--子界面
local Section = Tab:AddSection({
    Name = "实体"
})
Tab:AddToggle({
    Name = "实体移动提醒",
    Save = true,
    Default = true,
    Flag = "NotifyEntities",
})
Tab:AddSection({
    Name = "交互"
})
Tab:AddToggle({ -- 轻松交互
    Name = "无限交互距离",
    Save = true,
    Default = true,
    Flag = "InfInteract",
})
Tab:AddSection({
    Name = "其他"
})
Tab:AddButton({ --传送门
    Name = "传送到下一扇门",
    Callback = function()
        for _, notopendoor in pairs(workspace:GetDescendants()) do
            if notopendoor.Name == "NormalDoor" and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                teleportPlayer(Players.LocalPlayer, notopendoor.Root.Position)
            end
        end
    end
})
Esp:AddToggle({ -- door
    Name = "门透视",
    Save = true,
    Default = true,
    Flag = "DoorsEsp",
})
Esp:AddToggle({ -- locker
    Name = "柜子透视",
    Save = true,
    Default = true,
    Flag = "LockerEsp",
})
Esp:AddToggle({ -- 物品
    Name = "电池透视",
    Save = true,
    Default = true,
    Flag = "BatteryEsp",
})
Esp:AddToggle({ -- 实体
    Name = "实体透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            for _, door in pairs(workspace:GetDescendants()) do
                if door.Name == "NormalDoor" and door.Parent.Name == "Entrances" then
                    AddRoomESP(door,"门",Color3.new(0,1,0))
                end
            end
        end
    end
})
Esp:AddToggle({ -- locker
    Name = "柜子透视",
    Save = true,
    Default = true,
    Flag = "LockerEsp",
    Callback = function(Value)
        if Value then
            for _, locker in pairs(workspace:GetDescendants()) do
                if locker.Name == "Locker" and locker.Parent.Name ~= Players then
                    AddRoomESP(locker,"柜子",Color3.new(0,1,0))
                end
            end
        end
    end
})
Esp:AddToggle({ -- 物品
    Name = "电池透视",
    Save = true,
    Default = true,
    Flag = "BatteryEsp",
    Callback = function(Value)
        if Value then
            for _, battery in pairs(workspace:GetDescendants()) do
                if battery.Name == "DefaultBattery1" then
                    AddRoomESP(battery,"电池",Color3.new(1,1,1))
                end
            end
        end
    end
})
Esp:AddToggle({ -- 实体
    Name = "实体透视",
    Save = true,
    Default = true,
    Flag = "EntityEsp",
    Callback = function(Value)
        if Value then
            AddRoomESP(a60,"a60",Color3.new(1,0,0))
            AddRoomESP(a120,"a120",Color3.new(1,0,0))
        end
    end
})
local workspaceDA = AddConnection(workspace.DescendantAdded,function(inst) -- 其他
    if inst:IsA("ClickDetector") and OrionLib.Flags.InfInteract and OrionLib.Flags.InfInteract.Value then -- 无限交互距离
        inst.MaxActivationDistance = inf
    end
    if OrionLib.Flags.DoorsEsp and OrionLib.Flags.DoorsEsp.Value and inst.Name == "NormalDoor" and inst.Parent.Name == "Entrances" then
        AddRoomESP(inst,"门",Color3.new(0,1,0))
    end
    if OrionLib.Flags.LockerEsp and OrionLib.Flags.LockerEsp.Value and inst.Name == "Locker" then
        AddRoomESP(inst,"柜子",Color3.new(0,1,0))
    end
    if OrionLib.Flags.BatteryEsp and OrionLib.Flags.BatteryEsp.Value and inst.Name == "DefaultBattery1" then
        AddRoomESP(inst,"电池",Color3.new(1,1,1))
    end
    if OrionLib.Flags.EntityEsp and OrionLib.Flags.EntityEsp.Value and (inst == a60 or inst == a120) then
        AddRoomESP(inst,inst.Name,Color3.new(1,0,0))
    end
    if OrionLib.Flags.NotifyEntities and OrionLib.Flags.NotifyEntities.Value then
        local oldPos = inst.Position
        task.spawn(function()
            task.wait(0.5)
            if inst and inst.Parent and inst.Position ~= oldPos then
                entityNotifi(inst.Name .. "开始移动")
            end
        end)
    end
end)