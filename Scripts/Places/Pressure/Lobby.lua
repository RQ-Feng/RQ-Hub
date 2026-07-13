-- local设置
local playerPositions = {}
local PlaylistSong = Players.LocalPlayer.PlayerGui.Main.Client.MainClient.PlayList.Song
local humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
local Espboxes = Players.LocalPlayer.PlayerGui
local RemoteFolder = game:GetService('ReplicatedStorage').Events -- Remote Event储存区之一
--local结束->Function设置
-- #sym:ESPLibrary
local function teleportPlayer(player,toPositionVector3)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        playerPositions[player.UserId] = player.Character.HumanoidRootPart.CFrame
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
local function Animation(AnimationID) -- 动作播放
    local Animator = humanoid:WaitForChild("Animator")
    local DoAnimation = Instance.new("Animation")
    DoAnimation.AnimationId = AnimationID
    local AnimationTrack = Animator:LoadAnimation(DoAnimation)
    AnimationTrack:Play()
end
--Function结束-其他
OrionNotify("加载完成", "已成功加载")
--Tab界面
local Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
local Animator = Window:MakeTab({
    Name = "动画",
    Icon = "rbxassetid://4483345998"
})
local others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998"
})
--子界面
Tab:AddSection({
    Name = "主功能"
})
Tab:AddSection({
    Name = "相机"
})
Tab:AddToggle({ -- 保持广角
    Name = "保持广角",
    Default = true,
    Flag = "keep120fov",
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Default = true,
    Flag = "FullBrightLite",
})
Tab:AddSection({
    Name = "其他"
})
Tab:AddSlider({
    Name = "玩家透明度",
    Save = true,
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
        PlaylistSong.Volume = 0
        PlaylistSong.Looped = true
    end
})
Tab:AddButton({
    Name = "重启大厅音乐",
    Callback = function()
        PlaylistSong.Looped = false
        PlaylistSong.Playing = false
        PlaylistSong.Volume = 1.2
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

Tab:AddToggle({ -- 玩家
    Name = "玩家透视",
    Default = false,
    Flag = "PlayerEsp",
    Callback = function(Value)
        for _, player in pairs(game.Players:GetPlayers()) do
            if Value then
                if player ~= game.Players.LocalPlayer then
                    AddESP({
                        inst = player.Character,
                        Name = player.Name,
                        Color = Color3.new(238, 201, 0),
                        value = OrionLib.Flags['PlayerEsp']
                    })
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
-- 功能循环
AddConnection(RunService.RenderStepped,function()
    if OrionLib.Flags.keep120fov and OrionLib.Flags.keep120fov.Value and workspace.Camera.FieldOfView ~= 120 then
        workspace.Camera.FieldOfView = 120
    end
    if OrionLib.Flags.FullBrightLite and OrionLib.Flags.FullBrightLite.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    elseif not OrionLib.Flags.FullBrightLite or not OrionLib.Flags.FullBrightLite.Value then
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    end
end)
AddConnection(Players.PlayerAdded,function(player)
    if OrionLib.Flags.PlayerNotifications and OrionLib.Flags.PlayerNotifications.Value then
        local Notififriend = player:IsFriendsWith(Players.LocalPlayer.UserId) and "(好友)" or ""
        OrionNotify("玩家提醒", player.Name .. Notififriend .. "已加入", 2,false)
    end
end)
AddConnection(Players.PlayerRemoving,function(player)
    if OrionLib.Flags.PlayerNotifications and OrionLib.Flags.PlayerNotifications.Value then
        local Notififriend = player:IsFriendsWith(Players.LocalPlayer.UserId) and "(好友)" or ""
        OrionNotify("玩家提醒", player.Name .. Notififriend .. "已退出", 2,false)
    end
end)
