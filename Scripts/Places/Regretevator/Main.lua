local PlayerGui = LocalPlayer.PlayerGui--本地玩家PlayerGui

local RE = ReplicatedStorage:FindFirstChild('RE')
local DailyChallenge = RE.DailyChallenge

local Common = ReplicatedStorage.Scripts.Common

local promptBlacklist = {'KittyNPC','Expendable'}
local canAutoChallenges = {'Jump','KnockYourself','Walk','SurviveFloors'}

local function GetCurrentFloor() return workspace.Values.CurrentRoom.Value end

local function CheckCurrentFloor(floorName,button)
    local function SpecNotify(content)
        OrionLib:MakeNotification({
            Name = '检查楼层',
            Content = content,
            Time = 3
        })
    end
    if not GetCurrentFloor() then SpecNotify('请等待楼层开始.'); return false end
    local IsCorrectFloor = GetCurrentFloor().Name == floorName
    if button then 
        button:Set(false)
        SpecNotify('请在正确楼层使用.')
    end
    return IsCorrectFloor
end

local function IsPlaying()
  return ExecutorChecker['require'] and require(Common).IsPlaying(LocalPlayer) or LocalPlayer:GetAttribute('InElevator')
end

local function EspFloorItems(floorName,instName,flag)
    if type(floorName) ~= 'string' or type(instName) ~= 'string' then
        return warn('[EspFloorItems] expect string,got',type(floorName) ~= 'string' and type(floorName) or type(instName))
    elseif GetCurrentFloor().Name ~= floorName then return end
    
    AddESP({
        inst = GetCurrentFloor().Build:FindFirstChild(instName),
        value = flag
    })
end


--workspace.PizzaDelivery.Build.PizzaDoors
--workspace.PizzaDelivery.Build.PizzaBoxes

local function TeleportTo(toPositionVector3) -- 传送玩家-Vector3.new(x,y,z)
    if not HumanoidRootPart or not toPositionVector3 then return end   
    HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
end

if RE:FindFirstChild(tostring(game.JobId)) then 
    local suc,cache = pcall(function() RE[game.JobId]:Destroy() end)
    OrionLib:MakeNotification({
        Name = '绕过反作弊',
        Content = 
        '检测到反作弊RemoteEvent,为了账户安全已自动移除',
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
local RotateHeadManuallyToggle
RotateHeadManuallyToggle = Tab:AddToggle({
    Name = "手动旋转头部",
    Default = false,
    Flag = 'RotateHeadManually',
    Callback = function(Value)
        if Value then
            Character.ClientLookAt.Enabled = false
            Character.SetPlayerRotation:FireServer(OrionLib.Flags['HeadRotationY'].Value,OrionLib.Flags['HeadRotationX'].Value)
            Humanoid.AutoRotate = true
            repeat task.wait() until not OrionLib.Flags['RotateHeadManually'].Value or not Character:FindFirstChild('ClientLookAt')
            RotateHeadManuallyToggle:Set(false)
        elseif Character:FindFirstChild('ClientLookAt') then Character.ClientLookAt.Enabled = true end
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
        if not OrionLib.Flags['RotateHeadManually'].Value then return end
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
        if not OrionLib.Flags['RotateHeadManually'].Value then return end
        Character.SetPlayerRotation:FireServer(OrionLib.Flags['HeadRotationY'].Value,OrionLib.Flags['HeadRotationX'].Value)
    end
})
Tab:AddButton({
    Name = "手动复活(强制)",
    ClickTwice = true,
    Callback = function() 
        RE.Respawn:FireServer()
    end
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
local TaskAmountUpdate,ChallengeEventAsync,MultiPlrContinue,finishChallenge --For AutoChallenge
local AutoChallengeToggle --Toggle
AutoChallengeToggle = Tab:AddToggle({
    Name = "自动任务(部分)",
    Flag = 'AutoChallenge',
    Default = false,
    Callback = function(value)
        if not value then return end
        local state,taskTable = DailyChallenge.TryStartChallenge:InvokeServer()
        local Task,Type,Amount

        local function TaskNotify(Content,setTogglefalse,ToggleName)
            OrionLib:MakeNotification({
                Name = ToggleName and '自动任务' or ('当前任务为 %s'):format(Type),
                Content = Content
            })
            if setTogglefalse then AutoChallengeToggle:Set(false) end
        end
        
        if finishChallenge then return TaskNotify('你已完成任务',true,true) end
        if not IsPlaying() then return TaskNotify('请在进入游戏后使用',true,true) end
        if state ~= 'Ongoing' then return TaskNotify('请在任务加载后使用',true,true) end

        Task = taskTable['Task']
        Type = Task['Type']
        Amount = Task['Amount']

        if not table.find(canAutoChallenges,Type) then return TaskNotify('当前任务无法自动完成',true) end

        if #Players:GetPlayers() > 1 and not MultiPlrContinue then
            MultiPlrContinue = true
            task.spawn(function() Type.wait(3); MultiPlrContinue = false end)
            return TaskNotify('当前服务器有多个玩家\n若仍旧启动请在3s内重新打开',true)
        end

        local cacheConnections = {}

        TaskAmountUpdate = DailyChallenge.TaskAmountUpdate.OnClientEvent:Connect(function(currentProgress)
            if Amount <= currentProgress then finishChallenge = true end
        end,OrionLib.Flags['AutoChallenge']); table.insert(cacheConnections,TaskAmountUpdate)
        
        ChallengeEventAsync = AddConnection(DailyChallenge.ChallengeEventAsync.OnClientEvent,function(state)
            if state == 'ChallengeCompleted' then finishChallenge = true end
        end,OrionLib.Flags['AutoChallenge']); table.insert(cacheConnections,ChallengeEventAsync)
        
        TaskNotify('尝试自动完成中...')

        local TaskTracker = Character and (Character:FindFirstChild('JumpTaskTracker') or Character:FindFirstChild('KnockYourselfTaskTracker'))
        local Remote; if TaskTracker then Remote = TaskTracker:FindFirstChild('Remote') end
        local HeartbeatConnection; if Type == 'Walk' then 
            HeartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(10,0,0)
            end)
            table.insert(cacheConnections,HeartbeatConnection)
        end

        repeat 
            if Remote then Remote:FireServer() end
            local GetCFrame,WinPartCFrame = pcall(function() return GetCurrentFloor().Build.WinPart.CFrame end)
            if Type == 'SurviveFloors' then TeleportTo(GetCFrame and WinPartCFrame or Vector3.new(0,5000,0)) end
            task.wait() 
        until finishChallenge or not OrionLib.Flags['AutoChallenge'].Value or not OrionLib:IsRunning()

        for _,con in pairs(cacheConnections) do con:Disconnect() end
        if Type == 'SurviveFloors' then TeleportTo(workspace.Needed.Spawn.Position) end
        if finishChallenge then TaskNotify('当前任务已完成.',true,true) end
    end
})
Tab:AddToggle({ -- 轻松交互
    Name = "轻松交互",
    Flag = 'BetterPrompt',
    Default = true,
    Callback = function(Value)
        if not Value then return end
        for _,prompt in pairs(workspace:GetDescendants()) do 
            if not prompt:IsA('ProximityPrompt') then return end
            if table.find(promptBlacklist,prompt:FindFirstAncestorWhichIsA('Model').Name) then return end
            CheckPrompt(prompt,16)
        end
        AddConnection(workspace.DescendantAdded,function(prompt)
            if not prompt:IsA('ProximityPrompt') then return end
            if table.find(promptBlacklist,prompt:FindFirstAncestorWhichIsA('Model').Name) then return end
            CheckPrompt(prompt,16)
        end,OrionLib.Flags['BetterPrompt'])
    end
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
    Flag = 'FloppiesESP',
    Callback = function(Value)
        if not Value then return end
        for _,floppy in pairs(workspace:GetDescendants()) do
            if inst.Name == 'Normal' and inst['Recolor'] then
                AddESP({
                    inst = inst.Parent,
                    value = OrionLib.Flags['espFloppies']
                })
            end
        end
    end
})
Esp:AddToggle({
    Name = "反作弊Hitbox透视",
    Flag = 'AntiCheatESP',
    Callback = function(Value)
        if not Value or not GetCurrentFloor() then return end
        for _,ac in pairs(GetCurrentFloor():GetDescendants()) do
            if inst.Name ~= 'AntiCheat' and inst.Name ~= 'AREALDENIAL' then continue end
            inst.Transparency = 0
            AddESP({
                inst = inst,
                value = OrionLib.Flags['AntiCheatESP']
            })
        end
    end
})
Esp:AddSection({Name = "楼层透视"})
Esp:AddToggle({
    Name = "Jaoba透视(Jaoba楼层)",
    Flag = 'espJaoba',
    Callback = function(value)
        if not value or GetCurrentFloor().Name ~= 'UES' then return end
        AddESP({
            inst = GetCurrentFloor().Build.JAOBA,
            value = OrionLib.Flags['espJaoba']
        })
    end
})
Esp:AddToggle({
    Name = "Lampert透视(3008楼层)",
    Flag = 'espLampert',
    Callback = function(value)
        if not value or GetCurrentFloor().Name ~= '3008_Room' then return end
        AddESP({
            inst = GetCurrentFloor().Build.Lampert,
            value = OrionLib.Flags['espLampert']
        })
    end
})
Esp:AddToggle({
    Name = "Monsters透视(PetCaptureDeluxe楼层)",
    Flag = 'espLampert',
    Callback = function(value)
        if not value or GetCurrentFloor().Name ~= '3008_Room' then return end
        AddESP({
            inst = GetCurrentFloor().Build.Lampert,
            value = OrionLib.Flags['espLampert']
        })
    end
})
Esp:AddToggle({
    Name = "Lampert透视(3008楼层)",
    Flag = 'espLampert',
    Callback = function(value)
        if not value or GetCurrentFloor().Name ~= '3008_Room' then return end
        AddESP({
            inst = GetCurrentFloor().Build.Lampert,
            value = OrionLib.Flags['espLampert']
        })
    end
})
-- workspace.PetCaptureDeluxe.Build.ActiveMonsters
-- workspace.ButtonCompetition.Build.Buttons.Active
--workspace.bugbo.Build.Rocks
TP:AddToggle({
    Name = "自动传送至通关区",
    Default = false,
    Flag = 'AutoWin',
    Callback = function(value)
        if not value or not GetCurrentFloor() then return end
        if not IsPlaying() then return OrionLib:MakeNotification({
            Name = '自动传送至通关区',
            Content = '请在进入游戏后使用'
        }) end

        for _,part in pairs(GetCurrentFloor():GetDescendants()) do
            if part.Name == 'WinPart' then Character:PivotTo(part.CFrame) end
        end
    end
})
local AutoCoinsBySuperDropper; AutoCoinsBySuperDropper = Floor:AddToggle({
    Name = "SuperDropper刷金币",
    Default = false,
    Flag = 'AutoCoinsBySuperDropper',
    Callback = function(value)
        --if not value or then return end
        CheckCurrentFloor('SuperDropper',AutoCoinsBySuperDropper)

        --workspace.SuperDropper.RespawnCenter
        --workspace.SuperDropper.Build.EndHatch
        --workspace.SuperDropper.ResetMap(RemoteEvent)
        --workspace.ColorTheTiles.Tiles
    end
})
AddConnection(workspace.Values.CurrentRoom.Changed,function()
    local floor = GetCurrentFloor(); if not floor then return end
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
        if inst.Name == 'WinPart' and OrionLib.Flags['AutoWin'].Value and IsPlaying() then Character:PivotTo(inst.CFrame) end
        if inst.Name == 'Normal' and inst['Recolor'] and OrionLib.Flags['FloppiesESP'].Value then
            AddESP({
                inst = inst.Parent,
                value = OrionLib.Flags['FloppiesESP']
            })
        end
        if inst.Name == 'AntiCheat' or inst.Name == 'AREALDENIAL' and OrionLib.Flags['AntiCheatESP'].Value then
            inst.Transparency = 0
            AddESP({
                inst = inst,
                value = OrionLib.Flags['AntiCheatESP']
            })
        end
    end)
end)