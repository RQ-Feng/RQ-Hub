local events = ReplicatedStorage.events
Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Tab:AddSection({Name = "Punches"})
local punches = LocalPlayer.stats.punches
local LatestRoomLabel = Tab:AddLabel('当前有 '.. punches.Value ..' 个punches.')
AddConnection(punches.Changed,function() LatestRoomLabel:Set('当前有 '.. punches.Value ..' 个punches.') end)
Tab:AddToggle({
    Name = "刷Punches",
    Save = true,
    Default = false,
    Flag = 'AutoPunches',
    Callback = function()
        while OrionLib.Flags['AutoPunches'].Value and OrionLib:IsRunning() do task.wait(0.1)
            events.player:FindFirstChild('local').punch:FireServer()
        end
    end
})
