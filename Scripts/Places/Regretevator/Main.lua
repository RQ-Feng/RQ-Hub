local PlayerGui = LocalPlayer.PlayerGui--本地玩家PlayerGui

local RE = ReplicatedStorage:FindFirstChild('RE')

local function GetCurrentFloor() return workspace.Values.CurrentRoom.Value end

local function EspFloorItems(floor,flag)
    if GetCurrentFloor().Name ~= floor then return end
    AddESP({
        inst = GetCurrentFloor().Build.Lampert,
        value = OrionLib.Flags['espJaoba']
    })
end

-- workspace.PetCaptureDeluxe.Build.ActiveMonsters
-- workspace.ButtonCompetition.Build.Buttons.Active

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
        Time = 3
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
local Floor = Window:MakeTab({
    Name = "楼层",
    Icon = "rbxassetid://4483345998"
})
local TP = Window:MakeTab({
    Name = "传送",
    Icon = "rbxassetid://4483345998"
})
Tab:AddSection({
    Name = "通用"
})
Tab:AddToggle({
    Name = "手动旋转头部",
    Default = false,
    Flag = 'RotateHeadManually',
    Callback = function(Value)
        if Value then
            Character.SetPlayerRotation:FireServer(OrionLib.Flags['HeadRotationY'].Value,OrionLib.Flags['HeadRotationX'].Value)
            Character.ClientLookAt.Enabled = false
            Humanoid.AutoRotate = true
        else Character.ClientLookAt.Enabled = true end
    end
})
Tab:AddSlider({
	Name = "头部X轴",
	Min = 0,
	Max = 6.3,
	Default = 0,
	Increment = 0.1,
    Flag = 'HeadRotationX',
    Callback = function(Value)
        Character.SetPlayerRotation:FireServer(OrionLib.Flags['HeadRotationY'].Value,OrionLib.Flags['HeadRotationX'].Value)
    end
})
Tab:AddSlider({
	Name = "头部Y轴",
	Min = 0,
	Max = 6.3,
	Default = 0,
	Increment = 0.1,
    Flag = 'HeadRotationY',
    Callback = function()
        Character.SetPlayerRotation:FireServer(OrionLib.Flags['HeadRotationY'].Value,OrionLib.Flags['HeadRotationX'].Value)
    end
})
Tab:AddButton({
    Name = "手动复活(强制)",
    Callback = function() RE.Respawn:FireServer() end
})
Tab:AddToggle({
    Name = "死亡时自动复活",
    Flag = 'AutoRevive',
    Default = true,
    Callback = function(value)
        if not value then return end
        AddConnection(LocalPlayer.CharacterAdded,function(char)
            AddConnection(char:WaitForChild('Humanoid').Died,function() RE.Respawn:FireServer() end,OrionLib.Flags['AutoRevive'])
        end,OrionLib.Flags['AutoRevive'])
        AddConnection(Humanoid.Died,function() RE.Respawn:FireServer() end,OrionLib.Flags['AutoRevive'])
    end
})
Tab:AddToggle({ -- 轻松交互
    Name = "轻松交互",
    Flag = 'BetterPrompt',
    Default = true,
    Callback = function(Value)
        if not Value then return end
        BetterPrompt(16,OrionLib.Flags['BetterPrompt'])
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Flag = 'FullBrightLite',
    Default = true,
    Callback = function(Value)
        if not Value then return end
        FullBrightLite(OrionLib.Flags['FullBrightLite'])
    end
})
Esp:AddToggle({
    Name = "软盘透视",
    Flag = 'espFloppies',
    Callback = function(Value)
        if not Value then return end
        for _,floppy in pairs(workspace:GetDescendants()) do
            if inst.Name == 'Normal' and inst['Recolor'] and OrionLib.Flags['espFloppies'].Value then
                AddESP({
                    inst = inst.Parent,
                    value = OrionLib.Flags['espFloppies']
                })
            end
        end
    end
})
Esp:AddToggle({
    Name = "Jaoba透视(Jaoba楼层)",
    Flag = 'espJaoba',
    Callback = function()
        if GetCurrentFloor().Name ~= 'UES' then return end
        AddESP({
            inst = GetCurrentFloor().Build.JAOBA,
            value = OrionLib.Flags['espJaoba']
        })
    end
})
Esp:AddToggle({
    Name = "Lampert透视(3008楼层)",
    Flag = 'espLampert',
    Callback = function()
        if GetCurrentFloor().Name ~= '3008_Room' then return end
        AddESP({
            inst = GetCurrentFloor().Build.Lampert,
            value = OrionLib.Flags['espLampert']
        })
    end
})

--workspace.bugbo.Build.Rocks
TP:AddToggle({
    Name = "自动传送至通关区",
    Default = false,
    Flag = 'AutoWin'
})
AddConnection(workspace.Values.CurrentRoom.Changed,function()
    local floor = GetCurrentFloor();if not floor then return end
    if GetCurrentFloor().Name == 'UES' and OrionLib.Flags['espJaoba'].Value then
        AddESP({
            inst = GetCurrentFloor().Build.JAOBA,
            value = OrionLib.Flags['espJaoba']
        })
    end
    if GetCurrentFloor().Name == '3008_Room' and OrionLib.Flags['espLampert'].Value then
        AddESP({
            inst = GetCurrentFloor().Build.Lampert,
            value = OrionLib.Flags['espLampert']
        })
    end
    AddConnection(floor.DescendantAdded,function(inst)
        if inst.Name == 'WinPart' and OrionLib.Flags['AutoWin'].Value then Character:PivotTo(inst.CFrame) end
        if inst.Name == 'Normal' and inst['Recolor'] and OrionLib.Flags['espFloppies'].Value then
            AddESP({
                inst = inst.Parent,
                value = OrionLib.Flags['espFloppies']
            })
        end
    end)
end)