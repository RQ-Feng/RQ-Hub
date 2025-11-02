local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character -- 本地玩家Character
local Humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
local PlayerGui = LocalPlayer.PlayerGui--本地玩家PlayerGui

local RE = ReplicatedStorage:FindFirstChild('RE')
local AllFloors = RE.GetAllFloorNames:InvokeServer()

local espJaoba,espLampert

local function teleportPlayerTo(player,toPositionVector3,saveposition) -- 传送玩家-Vector3.new(x,y,z)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end

if RE:FindFirstChild(tostring(game.JobId)) then 
    RE[game.JobId]:Destroy()
    OrionLib:MakeNotification({
        Name = '绕过反作弊',
        Content = '检测到反作弊RemoteEvent,为了账户安全已自动移除',
        Time = 5
    })
end

local Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
local Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
local TP = Window:MakeTab({
    Name = "传送",
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
local RotateHeadManuallyEvent,HeadRotationX,HeadRotationY
Tab:AddToggle({ -- 轻松交互
    Name = "手动旋转头部",
    Default = false,
    Callback = function(Value)
        RotateHeadManually = Value
        LocalPlayer:SetAttribute("NO_LOOK",Value)
    end
})
Tab:AddSlider({
	Name = "头部X轴",
	Min = 0,
	Max = 6.3,
	Default = 0,
	Increment = 0.1,
	Callback = function(Value)
		HeadRotationX = Value
        if RotateHeadManually then Character.SetPlayerRotation:FireServer(HeadRotationY,HeadRotationX) end
	end    
})
Tab:AddSlider({
	Name = "头部Y轴",
	Min = 0,
	Max = 6.3,
	Default = 0,
	Increment = 0.1,
	Callback = function(Value)
		HeadRotationY = Value
        if RotateHeadManually then Character.SetPlayerRotation:FireServer(HeadRotationY,HeadRotationX) end
	end    
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
        FullBrightLite = Value
        if FullBrightLite then
            task.spawn(function()
                while FullBrightLite and OrionLib:IsRunning() do
                    Light.Ambient = Color3.new(1, 1, 1)
                    Light.ColorShift_Bottom = Color3.new(1, 1, 1)
                    Light.ColorShift_Top = Color3.new(1, 1, 1)
                    task.wait()
                end
            end)
        else
            Light.Ambient = Color3.new(0, 0, 0)
            Light.ColorShift_Bottom = Color3.new(0, 0, 0)
            Light.ColorShift_Top = Color3.new(0, 0, 0)
        end
    end
})
Esp:AddButton({
    Name = "Jaoba透视(Jaoba楼层)",
    Callback = function(Value)
        espJaoba = Value
        if workspace.UES == nil or not espJaoba then return end
        AddESP({
            inst = workspace.UES.Build.JAOBA,
            value = espJaoba
        })
    end
})
Esp:AddButton({
    Name = "Lampert透视(3008楼层)",
    Callback = function()
        if workspace['3008_Room'] == nil then return end
        AddESP(ESPConfig)
        AddESP({
            inst = workspace['3008_Room'].Build.Lampert,
            value = espLampert
        })
    end
})

local floordetector;floordetector = AddConnection(workspace.ChildAdded,function()
  
end)