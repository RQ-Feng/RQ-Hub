local EspConnects = {}
local Players = game:GetService("Players") -- 玩家服务
local Character = Players.LocalPlayer.Character -- 本地玩家Character
local Humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
Tabs = {
    Main = Window:AddTab('主界面'),
}
local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("玩家")
PlayerGroupBox:AddToggle("Speed", {
    Text = "速度",
    Tooltip = "在某些游戏可能无效果",
    Default = Humanoid.WalkSpeed,
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
    end
})
PlayerGroupBox:AddToggle("JumpPower", {
    Text = "跳跃高度",
    Tooltip = "在某些游戏可能无效果",
    Default = Humanoid.JumpPower,
    Callback = function(Value)
        Humanoid.JumpPower = Value
    end
})
local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("行为")
PlayerGroupBox:AddToggle("InstaInteract", {
    Text = "瞬间交互",
    Default = false
})
PlayerGroupBox:AddToggle("Infinitejump", {
    Text = "无限跳跃",
    Default = false,
    Callback = function(Value)
        if Value then
            Infjump = game:GetService("UserInputService").JumpRequest:Connect(function()
                Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
            end)
        else
            Infjump:Disconnect()
        end
    end
})
PlayerGroupBox:AddToggle("Noclip", {
    Text = "穿墙",
    Default = false,
    Callback = function(Value)
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = Value
            end
        end
    end
}):AddKeyPicker("NoclipKey", {
    Mode = "Toggle",
    Default = "N",
    Text = "Noclip",
    SyncToggleState = true
})
