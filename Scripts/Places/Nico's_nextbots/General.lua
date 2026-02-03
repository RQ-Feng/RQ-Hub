local events = ReplicatedStorage.events
local currentMap = workspace:FindFirstChild('currentMap')

local function GetMap() return currentMap and currentMap:GetChildren()[1] or workspace end
--Features
local function KickDoor(door)
    task.spawn(function()
        if door.Name ~= 'interactable_door' or not door:IsA('Model') or not OrionLib.Flags['KickAllDoors'].Value then return end
        repeat events.player.char.bashdoor:InvokeServer(door,true); task.wait(1) until 
        not door.Parent or not OrionLib.Flags['KickAllDoors'].Value or not OrionLib:IsRunning()
    end)
end
local JumpEffects

Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Exploit = Window:MakeTab({
    Name = "利用",
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
Exploit:AddToggle({
    Name = "重复蹦床效果",
    Default = false,
    Flag = 'RepeatJumpEffects',
    Callback = function(value)
        if not value then JumpEffects = nil; return end
        for _,inst in pairs(GetMap():GetDescendants()) do
            if inst.Name == 'JumpEffects' and inst:IsA('RemoteEvent') and OrionLib.Flags['RepeatJumpEffects'].Value then
                JumpEffects = inst
            end
        end; repeat task.wait() until JumpEffects
        local function RepeatJumpEffectsDelEffect(inst)
            task.spawn(function()
                local cache = HumanoidRootPart:WaitForChild(inst,1)
                if cache then cache:Destroy() end
            end)
        end
        while JumpEffects and OrionLib.Flags['RepeatJumpEffects'].Value and OrionLib:IsRunning() do task.wait()
            pcall(function() JumpEffects:FireServer() end)
            RepeatJumpEffectsDelEffect('BounceParticles')
            RepeatJumpEffectsDelEffect('boing')
        end
    end
})
Exploit:AddToggle({
    Name = "全局踢门",
    Default = false,
    Flag = 'KickAllDoors',
    Callback = function(value)
        if not value then return end
        for _,door in pairs(GetMap():GetDescendants()) do KickDoor(door) end
    end
})
AddConnection(currentMap.DescendantAdded,function(inst)
    if inst.Name == 'JumpEffects' and inst:IsA('RemoteEvent') and OrionLib.Flags['RepeatJumpEffects'].Value then
        JumpEffects = inst
    end
    KickDoor(inst)
end)