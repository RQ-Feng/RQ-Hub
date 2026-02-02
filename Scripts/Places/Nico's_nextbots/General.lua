local events = ReplicatedStorage.events
Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Tab:AddLabel('当前处于WIP阶段.')
Tab:AddSection({Name = "Punches"})
local punches = LocalPlayer.stats.punches
local LatestRoomLabel = Tab:AddLabel('当前有 '.. punches.Value ..' 个Punches.')
AddConnection(punches.Changed,function() LatestRoomLabel:Set('当前有 '.. punches.Value ..' 个Punches.') end)
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
Tab:AddSection({Name = "其他"})
Tab:AddButton({
    Name = "紫砂",
    ClickTwice = true,
    Callback = function() events.player.char.ClientDeath:FireServer() end
})
Tab:AddButton({
    Name = "重生",
    ClickTwice = true,
    Callback = function() events.player.char.respawnchar:FireServer() end
})