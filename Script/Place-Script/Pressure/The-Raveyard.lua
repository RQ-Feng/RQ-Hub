loadsuc, OrionLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/C-Feng-dev/Orion/refs/heads/main/main.lua'))()
end)
if loadsuc ~= true then
    warn("OrionLib加载错误,原因:" .. OrionLib)
    return
end
print("--OrionLib已加载完成--------------------------------加载中--")
OrionLib:MakeNotification({
    Name = "加载中...",
    Content = "可能会有短暂卡顿",
    Image = "rbxassetid://4483345998",
    Time = 4
})
Window = OrionLib:MakeWindow({
    IntroText = "The Raveyard",
    Name = "Pressure-The Raveyard",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Cfg/Pressure-Raveyard"
})
-- local设置
EspConnects = {}
doors = {"CryptDoor","GraveyardGate"}
TeleportService = game:GetService("TeleportService") -- 传送服务
Players = game:GetService("Players") -- 玩家服务
Character = Players.LocalPlayer.Character -- 本地玩家Character
humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
Espboxes = Players.LocalPlayer.PlayerGui
RemoteFolder = game:GetService('ReplicatedStorage').Events -- Remote Event储存区之一
--local结束->Function设置
function Notify(name,content,time,Sound,SoundId) -- 信息
    OrionLib:MakeNotification({
        Name = name,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = time or "3",
        SoundId = SoundId,
        Sound = Sound
    })
end
function delNotifi(delthings) -- 删除信息
    Notify(delthings, "已成功删除")
end
function entityNotifi(entityname) -- 实体提醒
    Notify("实体提醒", entityname)
end
function copyitems(copyitem) -- 复制物品
    create_NumberValue = Instance.new("NumberValue") -- copy items-type NumberValue
    create_NumberValue.Name = copyitem
    create_NumberValue.Parent = game.Players.LocalPlayer.PlayerFolder.Inventory
end
function createBilltoesp(theobject,name,color,hlset) -- 创建BillboardGui-颜色:Color3.new(r,g,b)
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
        hl.Name = name .. "透视高光"
        hl.Parent = Players.LocalPlayer.PlayerGui
        hl.Adornee = theobject
        hl.DepthMode = "AlwaysOnTop"
        hl.FillColor = color
        hl.FillTransparency = "0.5"
        task.spawn(function()
            while hl do
                if hl.Adornee == nil or not hl.Adornee:IsDescendantOf(workspace) then
                    hl:Destroy()
                end
                task.wait()
            end
        end)
    end
end
function espmodel(modelname,name,r,g,b,hlset) -- Esp物品(Model对象)用
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
function unesp(name) -- unEsp物品用
    for _, esp in pairs(workspace:GetDescendants()) do
        if esp.Name == name .. "esp" then
            esp:Destroy()
        end
    end
    for _, hl in pairs(workspace:GetDescendants()) do
        if hl.Name == name .. "透视高光" then
            hl:Destroy()
        end
    end
end
function teleportPlayerTo(player,toPositionVector3,saveposition) -- 传送玩家-Vector3.new(x,y,z)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        if saveposition then
            playerPositions[player.UserId] = player.Character.HumanoidRootPart.CFrame
        end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
function loadfinish() -- 加载完成后向控制台发送
    print("--------------------------加载完成--------------------------")
    print("--Pressure Script已加载完成")
    print("--欢迎使用!" .. game.Players.LocalPlayer.Name)
    print("--此服务器游戏ID为:" .. game.GameId)
    print("--此服务器位置ID为:" .. game.PlaceId)
    print("--此服务器UUID为:" .. game.JobId)
    print("--此服务器上的游戏版本为:version_" .. game.PlaceVersion)
    print("--当前您位于Pressure-The Raveyard")
    print("--------------------------欢迎使用--------------------------")
end
--Function结束-其他
task.spawn(function()--关闭esp的Connect
	while (OrionLib:IsRunning()) do
		task.wait()
	end
	for _, Connection in pairs(EspConnects) do
		Connection:Disconnect()
	end
end)
loadfinish()--其他结束->加载完成信息
Notify("加载完成", "已成功加载")
--Tab界面
Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
Del = Window:MakeTab({
    Name = "删除",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
--子界面
Section = Tab:AddSection({
    Name = "实体"
})
Tab:AddToggle({
    Name = "实体提醒",
    Default = true,
    Flag = "NotifyEntities",
    Save = true
})
Section = Tab:AddSection({
    Name = "交互"
})
Tab:AddToggle({ -- 轻松交互
    Name = "轻松交互",
    Default = true,
    Callback = function(Value)
        if Value == false then
            ezinst = false
            return
        end
        ezinst = true
        task.spawn(function()
            while ezinst and OrionLib:IsRunning() do
                for _, toezInteract in pairs(workspace:GetDescendants()) do
                    if toezInteract:IsA("ProximityPrompt") then
                        toezInteract.HoldDuration = "0.01"
                        toezInteract.RequiresLineOfSight = false
                        toezInteract.MaxActivationDistance = "11.5"
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})
Tab:AddToggle({ -- 轻松交互
    Name = "自动交互",
    Default = false,
    Callback = function(Value)
        if Value == false then
            autoinst = false
            return
        end
        autoinst = true
        task.spawn(function()
            while autoinst and OrionLib:IsRunning() do -- 交互-循环
                for _, proximity in pairs(workspace:GetDescendants()) do
                    if proximity:IsA("ProximityPrompt") then
                        proximity:InputHoldBegin()
                    end
                end
                task.wait(0.05)
            end
        end)
    end
})
Section = Tab:AddSection({
    Name = "相机"
})
Tab:AddToggle({ -- 保持广角
    Name = "保持广角",
    Default = true,
    Callback = function(Value)
        if Value then
            keep120fov = true
            task.spawn(function()
                while game.Workspace.Camera.FieldOfView ~= "120" and keep120fov and OrionLib:IsRunning() do
                    game.Workspace.Camera.FieldOfView = "120"
                    task.wait()
                end
            end)
        else
            keep120fov = false
        end
    end
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Default = true,
    Callback = function(Value)
        Light = game:GetService("Lighting")
        if Value then
            FullBrightLite = true
            task.spawn(function()
                while FullBrightLite and OrionLib:IsRunning() do
                    Light.Ambient = Color3.new(1, 1, 1)
                    Light.ColorShift_Bottom = Color3.new(1, 1, 1)
                    Light.ColorShift_Top = Color3.new(1, 1, 1)
                    task.wait()
                end
            end)
        else
            FullBrightLite = false
            Light.Ambient = Color3.new(0, 0, 0)
            Light.ColorShift_Bottom = Color3.new(0, 0, 0)
            Light.ColorShift_Top = Color3.new(0, 0, 0)
        end
    end
})
Section = Tab:AddSection({
    Name = "其他"
})
Tab:AddButton({ --传送门
    Name = "传送到下一扇门",
    Callback = function()
        for _, notopendoor in pairs(workspace:GetDescendants()) do
            if table.find(doors, notopendoor.Name) and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                teleportPlayerTo(Players.LocalPlayer, notopendoor.Root.Position + Vector3.new(0,5,0), false)
            end
        end
    end
})
Tab:AddToggle({ 
    Name = "自动过关(测试)",
    Callback = function(Value)
        if Value then
            autoplay = true
            task.spawn(function()
                while autoplay and OrionLib:IsRunning() do
                    for _, notopendoor in pairs(workspace.Rooms:GetDescendants()) do
                        if table.find(doors, notopendoor.Name) and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                            doors = {}
                            Exit = notopendoor.Exit.Value
                            for _, RoomsName in pairs(workspace.Rooms:GetChildren()) do
                                table.insert(Rooms,RoomsName.Name)
                            end
                            if not table.find(Rooms,Exit) then
                                Rooms = nil
                                Exit = nil
                                return
                            end
                            teleportPlayerTo(Players.LocalPlayer,notopendoor.Root.Position + Vector3.new(0,5,0), false)
                            if notopendoor.OpenValue.Value == true then
                                break         
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        else
            autoplay = false
        end
    end
})
Tab:AddButton({
    Name = "再来一局",
    Callback = function()
        Notify("再来一局","请稍等...")
        RemoteFolder.PlayAgain:FireServer()
    end
})
Tab:AddSlider({
    Name = "玩家透明度",
    Min = 0,
    Max = 1,
    Default = 0,
    Increment = 0.05,
    Callback = function(Value)
        for _, humanpart in pairs(Character:GetChildren()) do
            if humanpart:IsA("MeshPart") then
                humanpart.Transparency = Value
            end
        end
    end
})
Tab:AddToggle({ -- 玩家提醒
    Name = "玩家提醒",
    Default = true,
    Flag = "PlayerNotifications"
})
Del:AddButton({
    Name = "删除降雨效果",
    Callback = function()
        workspace.PlayerRain:Destroy()        
    end
})
Del:AddToggle({
    Name = "删除z564",
    Default = true,
    Flag = "noBouncer",
    Save = true
})
Del:AddToggle({
    Name = "删除z565",
    Default = true,
    Flag = "noSkeletonHead",
    Save = true
})
Del:AddToggle({
    Name = "删除z566",
    Default = true,
    Flag = "noStatueRoot",
    Save = true
})
Del:AddToggle({
    Name = "删除骷髅舞者",
    Default = true,
    Flag = "noSkeletonDancer",
    Save = true
})
Del:AddToggle({
    Name = "删除自然灾害",
    Default = true,
    Flag = "nodamage",
    Save = true
})
Esp:AddToggle({ -- door
    Name = "门透视",
    Default = true,
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Name == "Entrances" and themodel.Name == "CryptDoor" then
                    createBilltoesp(themodel,"门", Color3.new(0,1,0),true)
                end
                if themodel:IsA("Model") and themodel.Parent.Name == "Entrances" and themodel.Name == "GraveyardGate" then
                    createBilltoesp(themodel,"大门", Color3.new(0,1,0),true)
                end
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Name == "Entrances" and themodel.Name == "CryptDoor" then
                    createBilltoesp(themodel,"门", Color3.new(0,1,0),true)
                end
                if themodel:IsA("Model") and themodel.Parent.Name == "Entrances" and themodel.Name == "GraveyardGate" then
                    createBilltoesp(themodel,"大门", Color3.new(0,1,0),true)
                end
            end)
            table.insert(EspConnects,esp)
        else
            unesp("门")
            unesp("大门")
        end
    end
})
Esp:AddToggle({ -- 钱
    Name = "钱透视(待做)",
    Default = true,
    Callback = function(Value)
        if Value then
            espmodel("5Currency", "5钱", "1", "1", "1",false)
            espmodel("10Currency", "10钱", "1", "1", "1",false)
            espmodel("15Currency", "15钱", "0.5", "0.5", "0.5",false)
            espmodel("20Currency", "20钱", "1", "1", "1",false)
            espmodel("25Currency", "25钱", "1", "1", "0",false)
            espmodel("50Currency", "50钱", "1", "0.5", "0",true)
            espmodel("100Currency", "100钱", "1", "0", "1",true)
            espmodel("200Currency", "200钱", "0", "1", "1",true)
            espmodel("Relic", "500钱", "0", "1", "1",true)
        else
            unesp("5钱")
            unesp("10钱")
            unesp("15钱")
            unesp("20钱")
            unesp("25钱")
            unesp("50钱")
            unesp("100钱")
            unesp("200钱")
            unesp("500钱")
        end
    end
})
Esp:AddToggle({ -- 实体
    Name = "实体透视",
    Default = true,
    Flag = "EntityEsp"
})
Esp:AddToggle({ -- 玩家
    Name = "玩家透视",
    Default = false,
    Callback = function(Value)
        for _, player in pairs(game.Players:GetPlayers()) do
            if Value then
                if player ~= game.Players.LocalPlayer then
                    createBilltoesp(player.Character, player.Name, Color3.new(238, 201, 0),false)
                end
            else
                if player.Character:FindFirstChildOfClass("BillboardGui") then
                    player.Character:FindFirstChildOfClass("BillboardGui"):Destroy()
                end
            end
        end
    end
})
Section = others:AddSection({
    Name = "其他"
})
others:AddButton({
    Name = "注入Infinity Yield",
    Callback = function()
        Notify("注入Infinity Yield", "尝试注入中")
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        Notify("注入Infinity Yield", "注入完成(如果没有加载则重试)")
    end
})
others:AddButton({
    Name = "注入Dex v2 white(会卡顿)",
    Callback = function()
        Notify("注入Dex v2 white", "尝试注入中")
        loadstring(game:HttpGet('https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0'))()
        Notify("注入Dex v2 white", "注入完成(如果没有加载则重试)")
    end
})
others:AddButton({
    Name = "删除此窗口",
    Callback = function()
        OrionLib:Destroy()
    end
})
loadstring(game:HttpGet('https://raw.githubusercontent.com/C-Feng-dev/My-own-Script/refs/heads/main/Script/Tabs/OrionGui-About.lua'))()
workspaceDA = workspace.DescendantAdded:Connect(function(inst) -- 其他
    if inst.Name == "Bouncer" then -- 无环境伤害
        if OrionLib.Flags.EntityEsp.Value then -- 实体esp
            createBilltoesp(inst, inst.Name, Color3.new(1, 0, 0), true)
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.noBouncer.Value == false then
            entityNotifi("z564出现")
        elseif OrionLib.Flags.noBouncer.Value then
            task.wait(0.1)
            inst:Destroy()
            delNotifi("z564")
        end
    end
    if inst.Name == "SkeletonHead" then
        if OrionLib.Flags.EntityEsp.Value then -- 实体esp
            createBilltoesp(inst, inst.Name, Color3.new(1, 0, 0), true)
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.noSkeletonHead.Value == false then
            entityNotifi("z565出现")
        elseif OrionLib.Flags.noSkeletonHead.Value then
            task.wait(0.1)
            inst:Destroy()
            delNotifi("z565")
        end
    end
    if inst.Name == "SkeletonTail" and OrionLib.Flags.noSkeletonHead.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "SkelepedeBody" and OrionLib.Flags.noSkeletonHead.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "StatueRoot" then
        if OrionLib.Flags.EntityEsp.Value then -- 实体esp
            createBilltoesp(inst, inst.Name, Color3.new(1, 0, 0), true)
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.noStatueRoot.Value == false then
            entityNotifi("z566出现")
        elseif OrionLib.Flags.noStatueRoot.Value then
            task.wait(0.1)
            inst:Destroy()
            delNotifi("z566")
        end
    end
    if inst.Name == "SkeletonDancer" and OrionLib.Flags.noSkeletonDancer.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "DamagePart" and OrionLib.Flags.nodzamage.Value then
        task.wait(0.1)
        inst:Destroy()
    end
end)
Players.PlayerAdded:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        Notify("玩家提醒", player.Name .. Notififriend .. "已加入", 2,false)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        Notify("玩家提醒", player.Name .. Notififriend .. "已退出", 2,false)
    end
end)
