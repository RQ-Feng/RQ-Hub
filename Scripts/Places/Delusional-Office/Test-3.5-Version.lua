if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))() end
if not ESPLibrary then ESPLibrary = load("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau") end--lib
-- local设置
local EspConnects = {}
local TeleportService = game:GetService("TeleportService") -- 传送服务
local Players = game:GetService("Players") -- 玩家服务
local RunService = game:GetService("RunService") -- 运行服务
local player = Players.LocalPlayer -- 本地玩家
local Character = player.Character -- 本地玩家Character
local Espboxes = player.PlayerGui
local Remotes = game:GetService("ReplicatedStorage").Remotes
--Tables
local localEntities = {'ShadowEntity','ChaserEntityAlreadyAttacked','DoorcamperEntity','DoorcamperEntityType2','ChaserEntityType2AlreadyAttacked'}
local autodoorinsts = {'MainDoor','MainMouse','Vent1','Keypad'}
local Connections = {}
--local结束->Function设置
local function Notify(name,content,time,Sound) -- 信息
    OrionLib:MakeNotification({
        Name = name,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = time or "3",
        Sound = Sound,
    })
end
local function createBilltoesp(theobject,name,color,hlset) -- 创建BillboardGui-颜色:Color3.new(r,g,b)
    bill = Instance.new("BillboardGui", theobject) -- 创建BillboardGui
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 100, 0, 50)
    bill.Adornee = theobject
    bill.MaxDistance = 2000
    bill.Name = name .. "esp"
    mid = Instance.new("Frame", bill) -- 创建Frame-圆形
    mid.AnchorPoint = Vector2.new(0.5, 0.5)
    mid.BackgroundColor3 = color
    mid.Size = UDim2.new(0, 8, 0, 8)
    mid.Position = UDim2.new(0.5, 0, 0.5, 0)
    Instance.new("UICorner", mid).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", mid)
    txt = Instance.new("TextLabel", bill) -- 创建TextLabel-显示
    txt.AnchorPoint = Vector2.new(0.5, 0.5)
    txt.BackgroundTransparency = 1
    txt.TextColor3 =color
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Position = UDim2.new(0.5, 0, 0.7, 0)
    txt.Text = name
    Instance.new("UIStroke", txt)
    if hlset then
        hl = Instance.new("Highlight",bill)
        hl.Name = name .. "Esp Highlight"
        hl.Parent = Players.LocalPlayer.PlayerGui
        hl.Adornee = theobject
        hl.DepthMode = "AlwaysOnTop"
        hl.FillColor = color
        hl.FillTransparency = "0.5"
    end
    task.spawn(function()
        while hl do
            if hl.Adornee == nil or not hl.Adornee:IsDescendantOf(workspace) then
                hl:Destroy()
            end
            task.wait()
        end
    end)
end
local function espmodel(modelname,name,r,g,b,hlset) -- Esp物品(Model对象)用
    for _, themodel in pairs(workspace:GetDescendants()) do
        if themodel:IsA("Model") and themodel.Parent ~= Players and themodel.Name == modelname then
            createBilltoesp(themodel,name, Color3.new(r,g,b),hlset)
        end
    end
    esp = workspace.DescendantAdded:Connect(function(themodel)
        if themodel:IsA("Model") and themodel.Parent ~= Players and themodel.Name == modelname then
            createBilltoesp(themodel,name, Color3.new(r,g,b),hlset)
        end
    end)
    table.insert(EspConnects,esp)
end
local function unesp(name) -- unEsp物品用
    for _, esp in pairs(workspace:GetDescendants()) do
        if esp.Name == name .. "Esp Highlight" then
            esp:Destroy()
        end
    end
    for _, hl in pairs(workspace:GetDescendants()) do
        if hl.Name == name .. "Esp Highlight" then
            hl:Destroy()
        end
    end
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
--Function结束-其他
task.spawn(function() repeat wait() until not OrionLib:IsRunning() for _,connection in pairs(Connections) do connection:Disconnect() end end)
--其他结束->加载完成信息
print("--------------------------加载完成--------------------------")
    print("--欢迎使用!" .. game.Players.LocalPlayer.Name)
    print("--此服务器游戏ID为:" .. game.GameId)
    print("--此服务器位置ID为:" .. game.PlaceId)
    print("--此服务器UUID为:" .. game.JobId)
    print("--此服务器上的游戏版本为:version_" .. game.PlaceVersion)
    print("--------------------------欢迎使用--------------------------")
Notify("加载完成", "已成功加载")
--Tab界面
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
local autodoor = true
local autodelay = 1
local antiClientEntities = {}
local EntityAdded
Tab:AddToggle({
    Name = "删除本地实体",
    Default = true,
    Callback = function(Value)
        if Value then
            for _,entity in pairs(workspace.Entities:GetDescendants()) do
                if table.find(localEntities,entity.Name) and entity.Parent.Parent.Name == 'Entities' then
                    entity:Destroy() Notify('删除本地实体','成功删除实体:'..entity.Name)
                end
            end
            EntityAdded = workspace.Entities.DescendantAdded:Connect(function(entity)
                if table.find(localEntities,entity.Name) and entity.Parent.Parent.Name == 'Entities' then
                    entity:Destroy() Notify('删除本地实体','成功删除实体:'..entity.Name)
                end
            end)
            table.insert(Connections,event)
            table.insert(antiClientEntities,event)
        else EntityAdded:Disconnect() end
    end
})
Tab:AddToggle({
    Name = "自动踢门",
    Default = false,
    Callback = function(Value)
        autokickdoor = Value
        if not autokickdoor then return end
        for _,Door in pairs(workspace.RoomsHolder.MainRooms:GetDescendants()) do
            if Door.Name == 'MainDoor' and Door.Parent.Name == 'DoorModel' and Door:FindFirstChild("DoorHp") and Door.DoorHp:IsA('NumberValue') then
            task.spawn(function()
                repeat Character:FindFirstChild("MainControls"):FindFirstChild("ScriptsForCall"):FindFirstChild("R1"):FireServer({BreakDoor = Door}) wait()
                until not autokickdoor or Door:FindFirstChild("DoorHp").Value <= 0
            end)
            elseif Door.Name == 'PlanksWallModel' then Door:WaitForChild('woodfolder'):WaitForChild('KickHitbox'):WaitForChild('ServerSideManager'):WaitForChild('r1'):FireServer()
            elseif Door.Name == 'VentWallModel' then end
        end
    end
})
Tab:AddToggle({
    Name = "自动开门",
    Default = false,
    Callback = function(Value)
        autodoor = Value
        if autodoor == false then return end
        Notify('自动开门','建议打开自动踢门以实现最佳体验',2)
        for _, inst in pairs(workspace.RoomsHolder.MainRooms:GetDescendants()) do
            if table.find(autodoorinsts, inst.Name) then
                if GetDoorIsOpened(inst.Parent) then continue end
                pcall(function() teleportTo(inst.Position) end)
                if inst:FindFirstChild("TouchInterest") then
                    if inst.Name == 'MainDoor' and inst.Parent.Name == 'DoorModel' and inst:FindFirstChild("DoorHp") and inst.DoorHp:IsA('NumberValue') then
                        repeat wait() until (Character.HumanoidRootPart.Position - inst.Position).Magnitude < 20
                        Character:FindFirstChild("MainControls"):FindFirstChild("ScriptsForCall"):FindFirstChild("R1"):FireServer({BreakDoor = inst}) 
                    elseif firetouchinterest then firetouchinterest(Players.LocalPlayer.Character.HumanoidRootPart,inst)
                    else teleportTo(inst.Position) end
                elseif inst.Name == 'Keypad' and inst.Parent:FindFirstChild('RandomShape') then
                    fireclickdetector(inst.MainButtons[inst.Parent.RandomShape.Value].ClickDetector)
                end
            end
        end
    end
})
Tab:AddSlider({
    Name = "传送间隔(秒)",
    Min = 0.05,
    Max = 1,
    Default = 0.5,
    Increment = 0.05,
    Callback = function(Value)
       autodelay = Value
    end
})
local GodMode
Tab:AddToggle({
    Name = "伪无敌",
    Default = true,
    Callback = function(Value)
        if Value then
            Remotes.DamageCall:FireServer(-(Character.HealthManager.MaxHealth.Value-Character.HealthManager.Value))
            GodMode = Character.HealthManager.Changed:Connect(function() Remotes.DamageCall:FireServer(-(Character.HealthManager.MaxHealth.Value-Character.HealthManager.Value)) end)
            table.insert(Connections,GodMode)
        elseif GodMode then GodMode:Disconnect() end
    end
})
Section = Tab:AddSection({
    Name = "杂项"
})
Tab:AddToggle({ -- 玩家提醒
    Name = "玩家提醒",
    Default = true,
    Flag = "PlayerNotifications"
})
Tab:AddButton({
    Name = "删除此窗口",
    Callback = function()
        OrionLib:Destroy()
    end
})
Test:AddToggle({
    Name = "自动过关",
    Default = true,
    Callback = function(Value)
        if Value then
            Remotes.DamageCall:FireServer(-(Character.HealthManager.MaxHealth.Value-Character.HealthManager.Value))
            GodMode = Character.HealthManager.Changed:Connect(function() Remotes.DamageCall:FireServer(-(Character.HealthManager.MaxHealth.Value-Character.HealthManager.Value)) end)
            table.insert(Connections,GodMode)
        elseif GodMode then GodMode:Disconnect() end
    end
})
task.spawn(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/C-Feng-dev/My-own-Script/refs/heads/main/Script/Tabs/OrionGui-About.lua'))() end)

local DescendantAdded = workspace.RoomsHolder.MainRooms.DescendantAdded:Connect(function(obj)
    if autodoor == true and table.find(autodoorinsts,obj.Name) then
        pcall(function() teleportTo(obj.Position) end)
        if obj:WaitForChild("TouchInterest") then 
            if obj.Name == 'MainDoor' and obj.Parent.Name == 'DoorModel' and obj:FindFirstChild("DoorHp") and obj.DoorHp:IsA('NumberValue') then
            repeat wait() until (Character.HumanoidRootPart.Position - inst.Position).Magnitude < 20
            Character:FindFirstChild("MainControls"):FindFirstChild("ScriptsForCall"):FindFirstChild("R1"):FireServer({BreakDoor = obj}) else
            if firetouchinterest then firetouchinterest(Players.LocalPlayer.Character.HumanoidRootPart,obj)
            else teleportTo(obj.Position) end end
       elseif obj.Name == 'Keypad' and obj.Parent:WaitForChild('RandomShape') then fireclickdetector(obj.MainButtons[obj.Parent.RandomShape.Value].ClickDetector:FireClick()) end
    end
    if autokickdoor == true then 
        if obj.Name == 'MainDoor' and obj.Parent.Name == 'DoorModel' and obj:WaitForChild("DoorHp") and obj:WaitForChild('DoorHp'):IsA('NumberValue') then
        Character:FindFirstChild("MainControls"):FindFirstChild("ScriptsForCall"):FindFirstChild("R1"):FireServer({BreakDoor = obj})
        elseif obj.Name == 'PlanksWallModel' then obj:WaitForChild('woodfolder'):WaitForChild('KickHitbox'):WaitForChild('ServerSideManager'):WaitForChild('r1'):FireServer() end
    end
    if Godmode and obj.Name == 'TouchKill' or obj.Name == 'VoidKill' then
        obj = not obj:WaitForChild('TouchInterest') and nil
        obj:WaitForChild('TouchInterest'):Destroy() 
    end
end)
task.spawn(function() repeat wait() until not OrionLib:IsRunning() DescendantAdded:Disconnect() end)

Players.PlayerAdded:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        Notify("玩家提醒", player.Name .. Notififriend .. "已加入", 5,false)
    end
    if OrionLib.Flags.playeresp.Value and player ~= Players.LocalPlayer then
        createBilltoesp(player.Character, player.Name, Color3.new(238, 201, 0))
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        Notify("玩家提醒", player.Name .. Notififriend .. "已退出", 5,false)
    end
end)
