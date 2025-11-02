if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))() end
if not ESPLibrary then ESPLibrary = load("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau") end--lib
EspConnects = {}
teleportService = game:GetService("TeleportService") -- 传送服务
Players = game:GetService("Players") -- 玩家服务
Character = Players.LocalPlayer.Character -- 本地玩家Character
Humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
PlayerGui = Players.LocalPlayer.PlayerGui--本地玩家PlayerGui
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
function teleportPlayerTo(player,toPositionVector3,saveposition) -- 传送玩家-Vector3.new(x,y,z)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
Window:MakeTab({
    Name = "传送",
    Icon = "rbxassetid://4483345998"
})
Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998"
})
Tab:AddSection({
    Name = "通用"
})
Tab:AddToggle({ -- 轻松交互
    Name = "轻松交互",
    Default = true,
    Callback = function(Value)
        if Value then
            ezinst = true
            task.spawn(function()
                while ezinst and OrionLib:IsRunning() do
                    for _, toezInteract in pairs(workspace:GetDescendants()) do
                        if toezInteract:IsA("ProximityPrompt") then
                            toezInteract.HoldDuration = "0"
                            toezInteract.RequiresLineOfSight = false
                            toezInteract.MaxActivationDistance = "12"
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            ezinst = false
        end
    end
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Default = true,
    Callback = function(Value)
        = game:GetService("Lighting")
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
Tab:AddToggle({ -- 玩家提醒
    Name = "玩家提醒",
    Default = false,
    Flag = "PlayerNotifications"
})
Esp:AddButton({
    Name = "Jaoba透视(Jaoba楼层)",
    Callback = function()
        if workspace.UES == nil then
            nofloorerr()
            return
        end
        createBilltoesp(workspace.UES.Build.JAOBA,"Jaoba",Color3.new(1,1,1),true)
    end
})
Esp:AddButton({
    Name = "Lampert透视(3008楼层)",
    Callback = function()
        if workspace.3008_Room == nil then
            nofloorerr()
            return
        end
        createBilltoesp(workspace.3008_Room.Build.Lampert,"Lampert",Color3.new(1,1,1),true)
    end
})

TP:AddButton({
    Name = "柴火透视",
    Callback = function()
        for _, theEsp in pairs(workspace:GetDescendants()) do
        if workspace.idk == nil then
            nofloorerr()
            return
        end
        teleportPlayerTo(player,toPositionVector3,saveposition)
    end
})
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
