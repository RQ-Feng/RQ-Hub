-- local设置
local TeleportService = game:GetService("TeleportService") -- 传送服务
local Players = game:GetService("Players") -- 玩家服务
local RunService = game:GetService("RunService") -- 运行服务
local Espboxes = LocalPlayer.PlayerGui
local MainRooms = workspace.RoomsHolder.MainRooms
local Remotes = game:GetService("ReplicatedStorage").Remotes
--Tables
local localEntities = {'ShadowEntity','ChaserEntityAlreadyAttacked','DoorcamperEntity','DoorcamperEntityType2','ChaserEntityType2AlreadyAttacked'}
local DoorInsts = {'MainDoor','MainMouse','Vent1','Keypad'}
--Function设置
local function Notify(name,content,time,Sound) -- 信息
    OrionLib:MakeNotification({
        Name = name,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = time or "3",
        Sound = Sound,
    })
end
local function teleportTo(toPositionVector3 ) -- 传送玩家-Vector3.new(x,y,z)
    if Character:FindFirstChild("HumanoidRootPart") then Character:PivotTo(CFrame.new(toPositionVector3)) end
end
local function AnchorPartToCamera(part)
    local event = RunService.RenderStepped:Connect(function()
        if part and part.Parent then
            local cameraCFrame = workspace.CurrentCamera.CFrame
            part.CFrame = CFrame.new(cameraCFrame.Position + cameraCFrame.LookVector * 5) * CFrame.Angles(0, math.rad(180), 0)
        else event:Disconnect() end
    end)
end
local function GetDoorType(DoorModel)
    if not DoorModel.Name == 'DoorModel' then return end
    if DoorModel:WaitForChild('MainDoor',3) then 
    if DoorModel:WaitForChild("DoorHp") and DoorModel.DoorHp:IsA('NumberValue') then return 'KickDoor' else return 'TouchDoor' end
    elseif DoorModel:WaitForChild('VentWallModel') then return 'VentDoor'
    elseif DoorModel:WaitForChild('PlanksWallModel') then return 'PlankDoor' end
end
local function GetDoorIsOpened(DoorModel)
    if not DoorModel.Name == 'DoorModel' then return end
    if GetDoorType(DoorModel) == 'TouchDoor' then
        local MainDoor = DoorModel:WaitForChild('MainDoor')
        local x,y,z = MainDoor.CFrame:ToObjectSpace(MainDoor.Parent.DoorFrame.CFrame):ToEulerAnglesXYZ()
        return math.deg(x) ~= 0 and true or false
    elseif GetDoorType(DoorModel) == 'KickDoor' then return DoorModel:WaitForChild('MainDoor'):WaitForChild('DoorHp').Value <= 0 and true or false
    elseif GetDoorType(DoorModel) == 'VentDoor' then
        
    elseif GetDoorType(DoorModel) == 'PlankDoor' then return DoorModel:WaitForChild('PlanksWallModel'):WaitForChild('woodfolder'):WaitForChild('KickHitbox'):WaitForChild('ObjHp').Value <= 0 and true or false
    else return end
end
--Feature functions
local function OpenDoor(door)
    if not table.find(DoorInsts, door.Name) or GetDoorIsOpened(door.Parent) then return end
    if door:FindFirstChild("TouchInterest") then
        if door.Name == 'MainDoor' and door.Parent.Name == 'DoorModel' and door:FindFirstChild("DoorHp") and door.DoorHp:IsA('NumberValue') then
            repeat wait() until (Character.HumanoidRootPart.Position - door.Position).Magnitude < 20
            repeat Character.MainControls.ScriptsForCall.R1:FireServer({BreakDoor = Door}); task.wait()
            until not OrionLib.Flags['AutoOpenDoor'].Value or Door:FindFirstChild("DoorHp").Value <= 0 or not OrionLib:IsRunning()
        elseif firetouchinterest then firetouchinterest(Players.LocalPlayer.Character.HumanoidRootPart,door)
        else pcall(function() teleportTo(door.Position) end) end
    elseif door.Name == 'Keypad' and door.Parent:FindFirstChild('RandomShape') then
        fireclickdetector(door.MainButtons[door.Parent.RandomShape.Value].ClickDetector)
    end
end
Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Test = Window:MakeTab({
    Name = "测试",
    Icon = "rbxassetid://4483345998"
})
--子界面
Section = Tab:AddSection({
    Name = "主功能"
})
local autokickdoor = true
Tab:AddToggle({
    Name = "删除本地实体",
    Flag = 'DeleteLocalEntities',
    Save = true,
    Default = false,
    Callback = function(Value)
        if not Value then return end
        local function checkEntity(entity)
            if table.find(localEntities,entity.Name) and entity.Parent.Parent.Name == 'Entities' then entity:Destroy() end
        end; for _,entity in pairs(workspace.Entities:GetDescendants()) do checkEntity(entity) end
        AddConnection(workspace.Entities.DescendantAdded,checkEntity,OrionLib.Flags['DeleteLocalEntities'])
    end
})
Tab:AddToggle({
    Name = "自动踢门",
    Save = true,
    Flag = 'AutoKickDoor',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        for _,Door in pairs(workspace.RoomsHolder.MainRooms:GetDescendants()) do
            if Door.Name == 'MainDoor' and Door.Parent.Name == 'DoorModel' and Door:FindFirstChild("DoorHp") and Door.DoorHp:IsA('NumberValue') then
                repeat Character.MainControls.ScriptsForCall.R1:FireServer({BreakDoor = Door}); task.wait()
                until not OrionLib.Flags['AutoKickDoor'].Value or Door:FindFirstChild("DoorHp").Value <= 0
            elseif Door.Name == 'PlanksWallModel' then Door:WaitForChild('woodfolder'):WaitForChild('KickHitbox'):WaitForChild('ServerSideManager'):WaitForChild('r1'):FireServer()
            elseif Door.Name == 'VentWallModel' then end
        end
    end
})
Tab:AddToggle({
    Name = "自动开门",
    Save = true,
    Flag = 'AutoOpenDoor',
    Default = false,
    Callback = function(Value)
        if not Value then return end
        Notify('自动开门','建议打开自动踢门以实现最佳体验',2)
        for _, door in pairs(workspace.RoomsHolder.MainRooms:GetDescendants()) do OpenDoor(door) end
    end
})
Tab:AddSlider({
    Name = "传送间隔(秒)",
    Save = true,
    Flag = 'AutoOpenDoorDelay',
    Min = 0.05,
    Max = 1,
    Default = 0.5,
    Increment = 0.05,
})
Tab:AddToggle({
    Name = "无敌",
    Save = true,
    Flag = 'Godmode',
    Default = true,
    Callback = function(Value)
        if not Value then return end
        Remotes.DamageCall:FireServer(-(Character.HealthManager.MaxHealth.Value-Character.HealthManager.Value))
        AddConnection(Character.HealthManager.Changed,function() 
            local Damage = Character.HealthManager.MaxHealth.Value - Character.HealthManager.Value
            Remotes.DamageCall:FireServer(-Damage) 
        end,OrionLib.Flags['Godmode'])
    end
})
Tab:AddSection({Name = "杂项"})
Tab:AddToggle({ -- 玩家提醒
    Name = "玩家提醒",
    Save = true,
    Default = true,
    Flag = "PlayerNotifications"
})
Test:AddToggle({
    Name = "自动过关",
    Default = true,
    Callback = function(Value)

    end
})


AddConnection(MainRooms.DescendantAdded,function(obj)
    if OrionLib.Flags['AutoOpenDoor'] == true and table.find(DoorInsts,obj.Name) then OpenDoor(obj) end
    if autokickdoor == true then 
        if obj.Name == 'MainDoor' and obj.Parent.Name == 'DoorModel' and obj:WaitForChild("DoorHp") and obj:WaitForChild('DoorHp'):IsA('NumberValue') then
        Character:FindFirstChild("MainControls"):FindFirstChild("ScriptsForCall"):FindFirstChild("R1"):FireServer({BreakDoor = obj})
        elseif obj.Name == 'PlanksWallModel' then obj:WaitForChild('woodfolder'):WaitForChild('KickHitbox'):WaitForChild('ServerSideManager'):WaitForChild('r1'):FireServer() end
    end
    if OrionLib.Flags['Godmode'].Value and obj.Name == 'TouchKill' or obj.Name == 'VoidKill' then
        local Touch = obj:WaitForChild('TouchInterest',5)
        if not Touch then obj:Destroy() end; Touch:Destroy()
    end
end)

Players.PlayerAdded:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        local Notififriend = player:IsFriendsWith(Players.LocalPlayer.UserId) and "(好友)" or ''
        Notify("玩家提醒", player.Name .. Notififriend .. "已加入", 5,false)
    end
    if OrionLib.Flags.playeresp.Value and player ~= Players.LocalPlayer then
        AddESP{
            inst = player.Character,
            Name = player.Name,
            Color = Color3.new(238, 201, 0),
            Type = 'Highlight'
        }
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        local Notififriend = player:IsFriendsWith(Players.LocalPlayer.UserId) and "(好友)" or ''
        Notify("玩家提醒", player.Name .. Notififriend .. "已退出", 5,false)
    end
end)
