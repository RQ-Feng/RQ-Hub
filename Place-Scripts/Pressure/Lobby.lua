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
    IntroText = "Pressure Lobby",
    Name = "Pressure-Lobby",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Cfg/Pressure-Lobby"
})
-- local设置
EspConnects = {}
TeleportService = game:GetService("TeleportService") -- 传送服务
Players = game:GetService("Players") -- 玩家服务
Character = Players.LocalPlayer.Character -- 本地玩家Character
humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
Espboxes = Players.LocalPlayer.PlayerGui
RemoteFolder = game:GetService('ReplicatedStorage').Events -- Remote Event储存区之一
--local结束->Function设置
function Notify(name,content,time,Sound,Sound) -- 信息
    OrionLib:MakeNotification({
        Name = name,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = time or "3",
        Sound = Sound,
        Sound = Sound
    })
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
function teleportPlayerTo(player,toPositionVector3,saveposition) -- 传送玩家-Vector3.new(x,y,z)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        if saveposition then
            playerPositions[player.UserId] = player.Character.HumanoidRootPart.CFrame
        end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
function Animation(AnimationID) -- 动作播放
    Animator = humanoid:WaitForChild("Animator")
    DoAnimation = Instance.new("Animation")
    DoAnimation.AnimationId = AnimationID
    AnimationTrack = Animator:LoadAnimation(DoAnimation)
    AnimationTrack:Play()
end
function loadfinish() -- 加载完成后向控制台发送
    print("--------------------------加载完成--------------------------")
    print("--Pressure Script已加载完成")
    print("--欢迎使用!" .. game.Players.LocalPlayer.Name)
    print("--此服务器游戏ID为:" .. game.GameId)
    print("--此服务器位置ID为:" .. game.PlaceId)
    print("--此服务器UUID为:" .. game.JobId)
    print("--此服务器上的游戏版本为:version_" .. game.PlaceVersion)
    print("--当前您位于Pressure-Lobby")
    print("--------------------------欢迎使用--------------------------")
end
--Function结束-其他
loadfinish()--其他结束->加载完成信息
Notify("加载完成", "已成功加载")
--Tab界面
Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
Animator = Window:MakeTab({
    Name = "动画",
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
    Name = "主功能"
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
                while game.Workspace.Camera.FieldOfView ~= "120" and keep120fov do
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
                while FullBrightLite do
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
--[[Tab:AddToggle({--第三人称
    Name = "第三人称(测试)",
    Default = false,
    Callback = function(Value)
        if Value then
            thirdperson = true
            task.spawn(function()
                while thirdperson do
                    workspace.Camera.CFrame = game:GetService("Players").LocalPlayer.Character.UpperTorso.CFrame * CFrame.new(1.5, 0.5, 6.5)                    
                    task.wait()
                end
            end)
        else
            thirdperson = false
        end
    end})]]
Section = Tab:AddSection({
    Name = "其他"
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
Tab:AddButton({
    Name = "关闭大厅音乐",
    Callback = function()
        workspace.PlaylistSong.Volume = 0
        workspace.PlaylistSong.Looped = true
    end
})
Tab:AddButton({
    Name = "重启大厅音乐",
    Callback = function()
        workspace.PlaylistSong:Destroy()
    end
})
Tab:AddButton({
    Name = "删除隐形墙",
    Callback = function()
        for _, iw in pairs(workspace:GetDescendants()) do
            if iw.Name == "InvisibleWalls" then
                iw:Destroy()
            end
        end
    end
})
Tab:AddButton({
    Name = "关闭大厅音乐",
    Callback = function()
        workspace.PlaylistSong.Volume = 0
        workspace.PlaylistSong.Looped = true
    end
})
Tab:AddButton({
    Name = "重启大厅音乐",
    Callback = function()
        workspace.PlaylistSong:Destroy()
    end
})
Tab:AddToggle({ -- 玩家
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
Animator:AddTextbox({
    Name = "动画ID",
    Callback = function(Animationid)
        Animation("rbxassetid://" .. Animationid)
    end
})
Animator:AddLabel('部分动画')
Animator:AddButton({
    Name = "进柜",
    Callback = function()
        Animation("rbxassetid://12497909905")
    end
})
Animator:AddButton({
    Name = "摔倒",
    Callback = function()
        Animation("rbxassetid://13842248811")
    end
})
Animator:AddButton({
    Name = "假门攻击",
    Callback = function()
        Animation("rbxassetid://14783001346")
    end
})
Animator:AddButton({
    Name = "假柜-攻击",
    Callback = function()
        Animation("rbxassetid://14826175401")
    end
})
Animator:AddButton({
    Name = "假柜-被救",
    Callback = function()
        Animation("rbxassetid://15901315168")
    end
})
Animator:AddButton({
    Name = "假柜-救人",
    Callback = function()
        Animation("rbxassetid://15901325144")
    end
})
Animator:AddButton({
    Name = "z90攻击",
    Callback = function()
        Animation("rbxassetid://17374784439")
    end
})
Animator:AddButton({
    Name = "电机修复",
    Callback = function()
        Animation("rbxassetid://17557575607")
    end
})
Animator:AddButton({
    Name = "z13甩人",
    Callback = function()
        Animation("rbxassetid://18836343961")
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
Players.PlayerAdded:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        Notify("玩家提醒", player.Name .. Notififriend .. "已加入", 2,false)
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
        Notify("玩家提醒", player.Name .. Notififriend .. "已退出", 2,false)
    end
end)
