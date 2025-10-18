--Grace
loadsuc, OrionLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/C-Feng-dev/Orion/refs/heads/main/main.lua'))()
end)
if loadsuc ~= true then
    warn("OrionLib加载错误,原因:" .. OrionLib)
    return
end
print("--OrionLib已加载完成--------------------------------加载中--")
OrionLib:MakeNotification({
    Name = "加载中...",
    Content = "可能会有短暂卡顿",
    Image = "rbxassetid://4483345998",
    Time = 4
})
Connects = {}
noautoinst = {}
Players = game:GetService("Players") -- 玩家服务
RS = game:GetService("ReplicatedStorage")
Character = Players.LocalPlayer.Character -- 本地玩家Character
humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
PlayerGui = Players.LocalPlayer.PlayerGui--本地玩家PlayerGui
Window = OrionLib:MakeWindow({
    IntroText = "Grace",
    Name = "Grace",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Cfg/Grace"
})
function Notify(name,content,time,Sound,SoundId) -- 信息
    OrionLib:MakeNotification({
        Name = name,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = time or "3",
        Sound = Sound,
        SoundId = SoundId
    })
end
function createBilltoesp(theobject,name,color,hlset) -- 创建BillboardGui-颜色:Color3.new(r,g,b)
    bill = Instance.new("BillboardGui", theobject) -- 创建BillboardGui
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 100, 0, 50)
    bill.Adornee = theobject
    bill.MaxDistance = 2000
    bill.Name = name .. "esp"
    mid = Instance.new("Frame", bill) -- 创建Frame-圆形
    mid.AnchorPoint = Vector2.new(0.5, 0.5)
    mid.BackgroundColor3 = color
    mid.Size = UDim2.new(0, 8, 0, 8)
    mid.Position = UDim2.new(0.5, 0, 0.5, 0)
    Instance.new("UICorner", mid).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", mid)
    txt = Instance.new("TextLabel", bill) -- 创建TextLabel-显示
    txt.AnchorPoint = Vector2.new(0.5, 0.5)
    txt.BackgroundTransparency = 1
    txt.TextColor3 =color
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Position = UDim2.new(0.5, 0, 0.7, 0)
    txt.Text = name
    Instance.new("UIStroke", txt)
    --[[if hlset then
        hl = Instance.new("Highlight",PlayerGui)
        hl.Name = name .. "透视高光"
        hl.Adornee = theobject
        hl.DepthMode = "AlwaysOnTop"
        hl.FillColor = color
        hl.FillTransparency = "0.6"
    end
    task.spawn(function()
        while hl do
            if hl.Adornee == nil or not hl.Adornee:IsDescendantOf(workspace) then
                hl:Destroy()
            end
            task.wait()
        end
    end)]]
end
function unesp(name) -- unEsp物品用
    for _, esp in pairs(workspace:GetDescendants()) do
        if esp.Name == name .. "esp" then
            esp:Destroy()
        end
    end
    for _, hl in pairs(workspace:GetDescendants()) do
        if hl.Name == name .. "透视高光" then
            hl:Destroy()
        end
    end
end
function teleportPlayerTo(toPositionVector3) -- 传送玩家-Vector3.new(x,y,z)
    if Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = toPositionVector3
    end
end
function chatMessage(chat) -- 发送信息
    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(tostring(chat))
end
function NotifiEntity(inst,EntityName,NotifyName,mode,delflag)
    if mode == "spawn" then
        if inst.Name == EntityName and OrionLib:IsRunning() then
            if delflag then
                Notify("实体删除",NotifyName .. "已被删除")
            elseif OrionLib.Flags.NotifyEntities.Value then
                Notify("实体提醒",NotifyName .. "出现")
            end        
            if OrionLib.Flags.chatNotifyEntities.Value then
                chatMessage(NotifyName .. "出现")
            end
        end
    elseif mode == "remove" then
        if inst.Name == EntityName and OrionLib:IsRunning() then
            if OrionLib.Flags.NotifyEntities.Value then
                if delflag then
                    Notify("实体删除",NotifyName .. "已被删除")
                else
                    Notify("实体提醒",NotifyName .. "消失")
                end
            end        
            if OrionLib.Flags.chatNotifyEntities.Value then
                chatMessage(NotifyName .. "消失")
            end
        end
    end
end
function loadfinish() -- 加载完成后向控制台发送
    print("--------------------------加载完成--------------------------")
    print("--Grace Script已加载完成")
    print("--欢迎使用!" .. game.Players.LocalPlayer.Name)
    print("--此服务器游戏ID为:" .. game.GameId)
    print("--此服务器位置ID为:" .. game.PlaceId)
    print("--此服务器UUID为:" .. game.JobId)
    print("--此服务器上的游戏版本为:version_" .. game.PlaceVersion)
    print("--------------------------欢迎使用--------------------------")
end
--Function结束-其他
task.spawn(function()--关闭设置
	while (OrionLib:IsRunning()) do
		task.wait()
	end
	for _, Connection in pairs(Connects) do
		Connection:Disconnect()
	end
    t = {"autodoor","autolever","autoinst","ezinst"}
    for _, v in pairs(t) do
        v = false
    end
end)
loadfinish()--其他结束->加载完成信息
Notify("加载完成", "已成功加载")
Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
Del = Window:MakeTab({
    Name = "删除",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
another = Window:MakeTab({
    Name = "杂项",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
Tab:AddToggle({
    Name = "实体提醒",
    Default = true,
    Flag = "NotifyEntities",
    Save = true
})
Tab:AddToggle({
    Name = "实体播报",
    Default = false,
    Flag = "chatNotifyEntities",
    Save = true
})
Section = Tab:AddSection({
    Name = "交互"
})
Tab:AddLabel("交互距离超过40可能会导致交互bug")
Tab:AddSlider({
    Name = "交互距离",
    Min = 12,
    Max = 100,
    Default = 12,
    Increment = 1,
    Flag = "autoinstdistance"
})
Tab:AddSlider({
    Name = "自动拉杆距离",
    Min = 5,
    Max = 100,
    Default = 20,
    Increment = 1,
    Flag = "autoleverdistance"
})
Tab:AddSlider({
    Name = "自动开门距离",
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
Section = Tab:AddSection({
    Name = "其他"
})
Tab:AddLabel("请删除所有实体生成再使用自动过关")
Tab:AddButton({ -- 自动过关
    Name = "自动过关",
    Callback = function()
        if OrionLib.Flags.sureautogame.Value then
            task.spawn(function()
                while OrionLib.Flags.sureautogame.Value do
                    hitboxes = {}
                    for _, hitbox in pairs(workspace.Rooms:GetDescendants()) do
                        if hitbox.Name == "hitBox" then
                            table.insert(hitboxes,hitbox)
                        end
                    end
                    for _, i in pairs(hitboxes) do
                        teleportPlayerTo(i.CFrame)
                    end
                    hitboxes = {}
                    task.wait(0.02)
                end
            end)
        else
            Notify("自动过关","请二次确认后再使用")
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
        Light = game:GetService("Lighting")
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
                            createBilltoesp(themodel:WaitForChild("Door"),"门", Color3.new(0,1,0),true)
                        elseif themodel:WaitForChild("Door"):IsA("Part") then
                            createBilltoesp(themodel,"门", Color3.new(0,1,0),true)
                        end
                    end
                end
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel.Name == "Door" then
                    if themodel.Parent.Parent.Name == "Rooms" then
                        if themodel:WaitForChild("Door"):IsA("Model") then
                            createBilltoesp(themodel:WaitForChild("Door"),"门", Color3.new(0,1,0),true)
                        elseif themodel:WaitForChild("Door"):IsA("Part") then
                            createBilltoesp(themodel,"门", Color3.new(0,1,0),true)
                        end
                    end
                end
            end)
            table.insert(Connects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if doorsesp ~= true then
                        esp:Disconnect()
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "门透视高光" then
                                hl:Destroy()   
                            end   
                        end
                        break
                    end
                    task.wait(0.1)
                end
            end)
        else
            doorsesp = false
            unesp("门")
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
                        createBilltoesp(themodel,"拉杆", Color3.new(1,0,0),false)
                    end
                end
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel.Name == "Breaker" then
                    if themodel.Parent.Parent.Name == "Rooms" then
                        createBilltoesp(themodel,"拉杆", Color3.new(1,0,0),false)
                    end
                end
            end)
            table.insert(Connects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if leveresp ~= true then
                        esp:Disconnect()
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "拉杆透视高光" then
                                hl:Destroy()   
                            end   
                        end
                        break
                    end
                    task.wait(0.1)
                end
            end)
        else
            leveresp = false
            unesp("拉杆")
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
                        createBilltoesp(themodel:WaitForChild("Hinged"),"井口", Color3.new(0,1,0),true)
                    end
                end
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel.Name == "VaultEntrance" then
                    if themodel.Parent.Name == "SafeRoom" then
                        createBilltoesp(themodel:WaitForChild("Hinged"),"井口", Color3.new(0,1,0),true)
                    end
                end
            end)
            table.insert(Connects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if SafeRoomVaultesp ~= true then
                        esp:Disconnect()
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "井口透视高光" then
                                hl:Destroy()   
                            end   
                        end
                        break
                    end
                    task.wait(0.1)
                end
            end)
        else
            SafeRoomVaultesp = false
            unesp("井口")
        end
    end
})
Del:AddLabel("使用God mode被某些实体击杀时可能会导致bug")
Del:AddButton({
    Name = "God mode",
    Callback = function()
        suc,err = pcall(function()
            RS.KillClient:Destroy()
            Notify("伪God mode","成功删除")
        end)
            if not suc then
            Notify("伪God mode","删除时出错,可能已删除")
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
        suc,err = pcall(function()
            RS.SendGoatman:Destroy()
            Notify("删除Goatman","成功删除")
        end)
            if not suc then
            Notify("删除Goatman","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Del:AddButton({ 
    Name = "删除Rush生成",
    Callback = function()
        suc,err = pcall(function()
            RS.SendRush:Destroy()
            RS.Rush:Destroy()
            Notify("删除Rush","成功删除")
        end)
            if not suc then
            Notify("删除Rush","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Del:AddButton({ 
    Name = "删除Sorrow生成",
    Callback = function()
        suc,err = pcall(function()
            RS.SendSorrow:Destroy()
            Notify("删除Sorrow","成功删除")
        end)
            if not suc then
            Notify("删除Sorrow","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Del:AddButton({ 
    Name = "删除Worm生成",
    Callback = function()
        suc,err = pcall(function()
            RS.SendWorm:Destroy()
            RS.Worm:Destroy()
            Notify("删除Worm","成功删除")
        end)
            if not suc then
            Notify("删除Worm","删除时出错,可能已删除")
            warn("删除时出错:" .. err .. ",可能已删除")
        end
    end
})
Section = another:AddSection({
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
Section = another:AddSection({
    Name = "其他"
})
another:AddButton({
	Name = "自杀(启动伪God mode后失效)",
	Callback = function()
		game:GetService("ReplicatedStorage").KillClient:InvokeServer()
	end	  
})
Section = others:AddSection({
    Name = "其他"
})
others:AddButton({
    Name = "注入Infinity Yield",
    Callback = function()
        Notify("注入Infinity Yield", "尝试注入中")
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        Notify("注入Infinity Yield", "注入完成(如果没有加载则重试)")
    end
})
others:AddButton({
    Name = "注入Dex v2 white(会卡顿)",
    Callback = function()
        Notify("注入Dex v2 white", "尝试注入中")
        loadstring(game:HttpGet('https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0'))()
        Notify("注入Dex v2 white", "注入完成(如果没有加载则重试)")
    end
})
others:AddButton({
    Name = "删除此窗口",
    Callback = function()
        OrionLib:Destroy()
    end
})
loadstring(game:HttpGet('https://raw.githubusercontent.com/C-Feng-dev/My-own-Script/refs/heads/main/Script/Tabs/OrionGui-About.lua'))()
workspaceDA = workspace.DescendantAdded:Connect(function(inst)
    NotifiEntity(inst,"Rush","Rush(粉怪)","spawn",OrionLib.Flags.norush.Value)
    NotifiEntity(inst,"Worm","Worm(白怪)","spawn",OrionLib.Flags.noworm.Value)
    if inst.Name == "Rush" and OrionLib.Flags.norush.Value then
        inst:Destroy()
        RS.SendRush.Carnation.tinnitus.Playing = false
    end
    if inst.Name == "Worm" and OrionLib.Flags.noworm.Value then
        inst:Destroy()
        RS.SendWorm.Slugfish.tinnitus.Playing = false
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
workspaceDR = workspace.DescendantRemoving:Connect(function(inst)
    NotifiEntity(inst,"Rush","Rush(粉怪)","remove",OrionLib.Flags.norush.Value)
    NotifiEntity(inst,"Worm","Worm(白怪)","remove",OrionLib.Flags.noworm.Value)
end)
PlayersGuiDR = PlayerGui.DescendantAdded:Connect(function(inst)
    if inst.Name == "smilegui" and OrionLib.Flags.nodozer.Value then
        inst:Destroy()
    end
end)