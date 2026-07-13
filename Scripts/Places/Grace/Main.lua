local Connects = {}
local noautoinst = {}
local humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
local PlayerGui = Players.LocalPlayer.PlayerGui--本地玩家PlayerGui
local doorsesp, leversp, SafeRoomVaultesp, itemesp, entityesp
local ezinst, autolever, autodoor, FullBrightLite

local playerPositions = {}
local function teleportPlayer(toPositionVector3)
    if Character:FindFirstChild("HumanoidRootPart") then
        playerPositions[LocalPlayer.UserId] = Character.HumanoidRootPart.CFrame
        Character.HumanoidRootPart.CFrame = toPositionVector3
    end
end

local function chatMessage(chat) -- 发送信息
    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(tostring(chat))
end

local function NotifiEntity(inst,EntityName,NotifyName,mode,delflag)
    if mode == "spawn" then
        if inst.Name == EntityName and OrionLib:IsRunning() then
            if delflag then
                OrionNotify("实体删除",NotifyName .. "已被删除")
            elseif OrionLib.Flags.NotifyEntities.Value then
                OrionNotify("实体提醒",NotifyName .. "出现")
            end        
            if OrionLib.Flags.chatNotifyEntities.Value then
                chatMessage(NotifyName .. "出现")
            end
        end
    elseif mode == "remove" then
        if inst.Name == EntityName and OrionLib:IsRunning() then
            if OrionLib.Flags.NotifyEntities.Value then
                if delflag then
                    OrionNotify("实体删除",NotifyName .. "已被删除")
                else
                    OrionNotify("实体提醒",NotifyName .. "消失")
                end
            end        
            if OrionLib.Flags.chatNotifyEntities.Value then
                chatMessage(NotifyName .. "消失")
            end
        end
    end
end

task.spawn(function()--关闭设置
	while (OrionLib:IsRunning()) do
		task.wait()
	end
	for _, Connection in pairs(Connects) do
		Connection:Disconnect()
	end
    local t = {"autodoor","autolever","autoinst","ezinst"}
    for _, v in pairs(t) do
        v = false
    end
end)

OrionNotify("加载完成", "已成功加载")

local Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})

local Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})

local Del = Window:MakeTab({
    Name = "删除",
    Icon = "rbxassetid://4483345998"
})

local another = Window:MakeTab({
    Name = "杂项",
    Icon = "rbxassetid://4483345998"
})

local others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998"
})
Tab:AddToggle({
    Name = "实体提醒",
    Default = true,
    Flag = "NotifyEntities",
})
Tab:AddToggle({
    Name = "实体播报",
    Default = false,
    Flag = "chatNotifyEntities",
})
Tab:AddSection({
    Name = "交互"
})
Tab:AddLabel("交互距离超过40可能会导致交互bug")
Tab:AddSlider({
    Name = "交互距离",
    Save = true,
    Min = 12,
    Max = 100,
    Default = 12,
    Increment = 1,
    Flag = "autoinstdistance"
})
Tab:AddSlider({
    Name = "自动拉杆距离",
    Save = true,
    Min = 5,
    Max = 100,
    Default = 20,
    Increment = 1,
    Flag = "autoleverdistance"
})
Tab:AddSlider({
    Name = "自动开门距离",
    Save = true,
    Min = 5,
    Max = 100,
    Default = 20,
    Increment = 1,
    Flag = "autodoordistance"
})
Tab:AddToggle({ -- 轻松交互
    Name = "修改交互距离",
    Default = true,
    Callback = function(Value)  
        if Value then          
            ezinst = true
            task.spawn(function()
                while ezinst and OrionLib:IsRunning() do
                    for _, toezInteract in pairs(workspace.Rooms:GetDescendants()) do
                        if toezInteract:IsA("ProximityPrompt") then
                            toezInteract.RequiresLineOfSight = false
                            toezInteract.MaxActivationDistance = OrionLib.Flags.autoinstdistance.Value
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
Tab:AddToggle({
    Name = "自动拉杆",
    Default = false,
    Callback = function(Value)
        if Value == true then
            autolever = true
        else
            autolever = false
        end
        while autolever do  
            for _, breaker in pairs(workspace.Rooms:GetDescendants()) do
                if breaker.Name == "Breaker" then
                    if Players.LocalPlayer:DistanceFromCharacter(breaker:WaitForChild("base").Position) <= OrionLib.Flags.autoleverdistance.Value then
                        breaker.Touched:FireServer()
                    end
                end
            end
            task.wait(0.1)
        end
    end
})
Tab:AddToggle({
    Name = "自动开门(黄门)",
    Default = false,
    Callback = function(Value)
        if Value == true then
            autodoor = true
        else
            autodoor = false
        end
        while autodoor do
            for _, door in pairs(workspace.Rooms:GetDescendants()) do
                if door.Name == "TouchInterest" and door.Parent.Name == "kickBox" and Players.LocalPlayer:DistanceFromCharacter(door.Parent.Position) <= OrionLib.Flags.autodoordistance.Value then
                    door.Parent.Parent.RemoteEvent:FireServer()
                end
            end
            task.wait(0.1)
        end
    end
})
Tab:AddSection({
    Name = "其他"
})
Tab:AddLabel("请删除所有实体生成再使用自动过关")
Tab:AddButton({ -- 自动过关
    Name = "自动过关",
    Callback = function()
        if OrionLib.Flags.sureautogame.Value then
            task.spawn(function()
                while OrionLib.Flags.sureautogame.Value do
                    local hitboxes = {}
                    for _, hitbox in pairs(workspace.Rooms:GetDescendants()) do
                        if hitbox.Name == "hitBox" then
                            table.insert(hitboxes,hitbox)
                        end
                    end
                    for _, i in pairs(hitboxes) do
                        teleportPlayer(i.CFrame)
                    end
                    hitboxes = {}
                    task.wait(0.02)
                end
            end)
        else
            OrionNotify("自动过关","请二次确认后再使用")
        end
    end
})
Tab:AddToggle({ -- 玩家提醒
    Name = "自动过关(二次确认)",
    Default = false,
    Flag = "sureautogame"
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Default = true,
    Callback = function(Value)
        local Light = game:GetService("Lighting")
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
Tab:AddButton({
    Name = "返回大厅",
    Callback = function()
        game.ReplicatedStorage.byebyemyFRIENDbacktothelobby:FireServer()        
    end
})
Tab:AddSlider({
	Name = "视场角",
    Save = true,
	Min = 0,
	Max = 20,
	Default = 0,
	Increment = 1,
	ValueName = "+",
	Callback = function(Value)
        game:GetService("ReplicatedFirst").CamFOV.Value = Value
    end
})
Tab:AddToggle({ -- 玩家提醒
    Name = "玩家提醒",
    Default = false,
    Flag = "PlayerNotifications"
})
Esp:AddToggle({
    Name = "门透视",
    Default = true,
    Callback = function(Value)
        if Value then
            doorsesp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel.Name == "Door" then
                    if themodel.Parent.Parent.Name == "Rooms" then--第一个Parent为房间号
                        if themodel:WaitForChild("Door"):IsA("Model") then
                            AddESP({
                                inst = themodel:WaitForChild("Door"),
                                Name = "门",
                                Color = Color3.new(0,1,0),
                            })
                        elseif themodel:WaitForChild("Door"):IsA("Part") then
                            AddESP({
                                inst = themodel,
                                Name = "门",
                                Color = Color3.new(0,1,0),
                            })
                        end
                    end
                end
            end
            local esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel.Name == "Door" then
                    if themodel.Parent.Parent.Name == "Rooms" then
                        if themodel:WaitForChild("Door"):IsA("Model") then
                            AddESP({
                                inst = themodel:WaitForChild("Door"),
                                Name = "门",
                                Color = Color3.new(0,1,0),
                            })
                        elseif themodel:WaitForChild("Door"):IsA("Part") then
                            AddESP({
                                inst = themodel,
                                Name = "门",
                                Color = Color3.new(0,1,0),
                            })
                        end
                    end
                end
            end)
            table.insert(Connects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if doorsesp ~= true then
                        esp:Disconnect()
                        break
                    end
                    task.wait(0.1)
                end
            end)
        else
            doorsesp = false
        end
    end
})
Esp:AddToggle({ -- door
    Name = "拉杆透视",
    Default = true,
    Callback = function(Value)
        if Value then
            leveresp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel.Name == "Breaker" then
                    if themodel.Parent.Parent.Name == "Rooms" then
                        AddESP({
                            inst = themodel,
                            Name = "拉杆",
                            Color = Color3.new(1,0,0),
                        })
                    end
                end
            end
            local esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel.Name == "Breaker" then
                    if themodel.Parent.Parent.Name == "Rooms" then
                        AddESP({
                            inst = themodel,
                            Name = "拉杆",
                            Color = Color3.new(1,0,0),
                        })
                    end
                end
            end)
            table.insert(Connects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if leveresp ~= true then
                        esp:Disconnect()
                        break
                    end
                    task.wait(0.1)
                end
            end)
        else
            leveresp = false
        end
    end
})
Esp:AddToggle({
    Name = "安全区井口透视",
    Default = true,
    Callback = function(Value)
        if Value then
            SafeRoomVaultesp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel.Name == "VaultEntrance" then
                    if themodel.Parent.Name == "SafeRoom" then--第一个Parent为房间号
                        AddESP({
                            inst = themodel:WaitForChild("Hinged"),
                            Name = "井口",
                            Color = Color3.new(0,1,0),
                        })
                    end
                end
            end
            local esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel.Name == "VaultEntrance" then
                    if themodel.Parent.Name == "SafeRoom" then
                        AddESP({
                            inst = themodel:WaitForChild("Hinged"),
                            Name = "井口",
                            Color = Color3.new(0,1,0),
                        })
                    end
                end
            end)
            table.insert(Connects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if SafeRoomVaultesp ~= true then
                        esp:Disconnect()
                        break
                    end
                    task.wait(0.1)
                end
            end)
        else
            SafeRoomVaultesp = false
        end
    end
})
Del:AddLabel("使用God mode被某些实体击杀时可能会导致bug")
Del:AddButton({
    Name = "God mode",
    Callback = function()
        local suc,err = pcall(function()
            ReplicatedStorage.KillClient:Destroy()
            OrionNotify("伪God mode","成功删除")
        end)
            if not suc then
            OrionNotify("伪God mode","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Del:AddToggle({
    Name = "删除蓝眼",
    Default = true,
    Flag = "noblueeyes"
})
Del:AddToggle({
    Name = "删除红眼",
    Default = true,
    Flag = "noredeyes"
})
Del:AddToggle({ 
    Name = "删除Rush",
    Default = true,
    Flag = "norush"
})
Del:AddToggle({ 
    Name = "删除Worm",
    Default = true,
    Flag = "noworm"
})
Del:AddToggle({ 
    Name = "删除elkman",
    Default = true,
    Flag = "noelkman"
})
Del:AddToggle({ 
    Name = "删除Dozer",
    Default = true,
    Flag = "nodozer"
})
Del:AddButton({
    Name = "删除Goatman生成",
    Callback = function()
        local suc,err = pcall(function()
            ReplicatedStorage.SendGoatman:Destroy()
            OrionNotify("删除Goatman","成功删除")
        end)
            if not suc then
            OrionNotify("删除Goatman","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Del:AddButton({ 
    Name = "删除Rush生成",
    Callback = function()
        local suc,err = pcall(function()
            ReplicatedStorage.SendRush:Destroy()
            ReplicatedStorage.Rush:Destroy()
            OrionNotify("删除Rush","成功删除")
        end)
            if not suc then
            OrionNotify("删除Rush","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Del:AddButton({ 
    Name = "删除Sorrow生成",
    Callback = function()
        local suc,err = pcall(function()
            ReplicatedStorage.SendSorrow:Destroy()
            OrionNotify("删除Sorrow","成功删除")
        end)
            if not suc then
            OrionNotify("删除Sorrow","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Del:AddButton({ 
    Name = "删除Worm生成",
    Callback = function()
        local suc,err = pcall(function()
            ReplicatedStorage.SendWorm:Destroy()
            ReplicatedStorage.Worm:Destroy()
            OrionNotify("删除Worm","成功删除")
        end)
            if not suc then
            OrionNotify("删除Worm","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})

another:AddSection({
    Name = "倒计时设置"
})
another:AddLabel("需要至少激活一次倒计时才可使用")
another:AddTextbox({
	Name = "计时器时间",
	TextDisappear = true,
	Callback = function(Value)
		workspace.DEATHTIMER.Value = Value
	end	  
})
another:AddSection({
    Name = "其他"
})
another:AddButton({
	Name = "自杀(启动伪God mode后失效)",
	Callback = function()
		game:GetService("ReplicatedStorage").KillClient:InvokeServer()
	end	  
})
local workspaceDA = AddConnection(workspace.DescendantAdded,function(inst)
    NotifiEntity(inst,"Rush","Rush(粉怪)","spawn",OrionLib.Flags.norush.Value)
    NotifiEntity(inst,"Worm","Worm(白怪)","spawn",OrionLib.Flags.noworm.Value)
    if inst.Name == "Rush" and OrionLib.Flags.norush.Value then
        inst:Destroy()
        ReplicatedStorage.SendRush.Carnation.tinnitus.Playing = false
    end
    if inst.Name == "Worm" and OrionLib.Flags.noworm.Value then
        inst:Destroy()
        ReplicatedStorage.SendWorm.Slugfish.tinnitus.Playing = false
    end
    if inst.Name == "eye" and OrionLib.Flags.noblueeyes.Value then
        inst:Destroy()
    end
    if inst.Name == "eyePrime" and OrionLib.Flags.noredeyes.Value then
        inst:Destroy()
    end
    if inst.Name == "elkman" and OrionLib.Flags.noelkman.Value then
        inst:Destroy()
    end
end)
local workspaceDR = AddConnection(workspace.DescendantRemoving,function(inst)
    NotifiEntity(inst,"Rush","Rush(粉怪)","remove",OrionLib.Flags.norush.Value)
    NotifiEntity(inst,"Worm","Worm(白怪)","remove",OrionLib.Flags.noworm.Value)
end)
local PlayersGuiDR = AddConnection(PlayerGui.DescendantAdded,function(inst)
    if inst.Name == "smilegui" and OrionLib.Flags.nodozer.Value then
        inst:Destroy()
    end
end)