-- local设置
entityNames = {"Angler", "RidgeAngler", "Blitz", "RidgeBlitz", "Pinkie", "RidgePinkie", "Froger", "RidgeFroger","Chainsmoker", "Pandemonium", "Eyefestation", "A60", "Mirage"} -- 实体
noautoinst = {"Locker", "MonsterLocker", "LockerUnderwater", "Generator", "BrokenCable","EncounterGenerator","Saboterousrusrer","Toilet"}
playerPositions = {} -- 存储玩家坐标
Entitytoavoid = {} -- 自动躲避用-检测自动躲避的实体
EspConnects = {}
Character = Players.LocalPlayer.Character -- 本地玩家Character
humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
PlayerGui = Players.LocalPlayer.PlayerGui--本地玩家PlayerGui
RS = game:GetService("ReplicatedStorage")
RemoteFolder = RS.Events -- Remote Event储存区之一
--local结束->Function设置
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
function copyNotifi(copyitemname) -- 复制信息
    Notify(copyitemname, "已成功复制")
end
function delNotifi(delthings) -- 删除信息
    Notify(delthings, "已成功删除")
end
function entityNotifi(entityname) -- 实体提醒
    Notify("实体提醒", entityname)
end
function copyitems(copyitem) -- 复制物品
    create_NumberValue = Instance.new("NumberValue") -- copy items-type NumberValue
    create_NumberValue.Name = copyitem
    create_NumberValue.Parent = game.Players.LocalPlayer.PlayerFolder.Inventory
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
    if hlset then
        hl = Instance.new("Highlight",PlayerGui)
        hl.Name = name .. "透视高光"
        hl.Adornee = theobject
        hl.DepthMode = "AlwaysOnTop"
        hl.FillColor = color
        hl.FillTransparency = "0.6"
        task.spawn(function()
            while hl do
                if hl.Adornee == nil or not hl.Adornee:IsDescendantOf(workspace) then
                    hl:Destroy()
                end
                task.wait()
            end
        end)
    end
end
function espmodel(themodel,modelname,name,r,g,b,hlset) -- Esp物品(Model对象)用
    if themodel:IsA("Model") and themodel.Parent.Name ~= Players and themodel.Name == modelname then
        createBilltoesp(themodel, name, Color3.new(r,g,b),hlset)
    end
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
function createPlatform(name, sizeVector3,positionVector3) -- 创建平台-Vector3.new(x,y,z)
    if Platform then
        Platform:Destroy() -- 移除多余平台
    end
    Platform = Instance.new("Part")
    Platform.Name =name
    Platform.Size = sizeVector3
    Platform.Position = positionVector3
    Platform.Anchored = true
    Platform.Parent = workspace
    Platform.Transparency = 1
    Platform.CastShadow = false
end
function teleportPlayerTo(player,toPositionVector3,saveposition) -- 传送玩家-Vector3.new(x,y,z)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        if saveposition then
            playerPositions[player.UserId] = player.Character.HumanoidRootPart.CFrame
        end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
function teleportPlayerBack(player) -- 返回玩家 
    if playerPositions[player.UserId] then
        player.Character.HumanoidRootPart.CFrame = playerPositions[player.UserId]
        playerPositions[player.UserId] = nil -- 清除坐标
    else
        warn("返回失败!存储玩家原坐标的数值无法用于返回")
    end
end
function chatMessage(chat) -- 发送信息
    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(tostring(chat))
end
function loadfinish() -- 加载完成后向控制台发送
    print("--------------------------加载完成--------------------------")
    print("--Pressure Script已加载完成")
    print("--欢迎使用!" .. game.Players.LocalPlayer.Name)
    print("--此服务器游戏ID为:" .. GameId)
    print("--此服务器位置ID为:" .. PlaceId)
    print("--此服务器UUID为:" .. game.JobId)
    print("--此服务器上的游戏版本为:version_" .. game.PlaceVersion)
    print("--当前您位于Pressure-Hadal Blacksite")
    print("--------------------------欢迎使用--------------------------")
end
--Function结束-其他
task.spawn(function()--关闭esp的Connect
	while (OrionLib:IsRunning()) do
		task.wait()
	end
	for _, Connection in pairs(EspConnects) do
		Connection:Disconnect()
	end
end)
loadfinish()--其他结束->加载完成信息
Notify("加载完成", "已成功加载")
--Tab界面
Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Item = Window:MakeTab({
    Name = "物品",
    Icon = "rbxassetid://4483345998"
})
Del = Window:MakeTab({
    Name = "删除",
    Icon = "rbxassetid://4483345998"
})
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998"
})
--子界面
Section = Tab:AddSection({
    Name = "实体"
})
Tab:AddToggle({
    Name = "实体提醒",
    Save = true,
    Default = true,
    Flag = "NotifyEntities",
})
Tab:AddToggle({
    Name = "实体播报",
    Save = true,
    Default = false,
    Flag = "chatNotifyEntities",
})
Tab:AddToggle({
    Name = "自动躲避",
    Save = true,
    Default = false,
    Flag = "avoid",
})
Tab:AddButton({ -- 手动返回
    Name = "手动返回",
    Callback = function()
        teleportPlayerBack(Players.LocalPlayer)
    end
})
Section = Tab:AddSection({
    Name = "交互"
})
Tab:AddToggle({ -- 轻松交互
    Name = "轻松交互",
    Save = true,
    Default = true,
    Callback = function(Value)  
        if Value == true then          
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
Tab:AddToggle({ -- 轻松修复
    Name = "轻松修复",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value == false then
            ezfix = false
            return
        end
        ezfix = true
        task.spawn(function()
            while ezfix and OrionLib:IsRunning() do
                FixGame = PlayerGui.Main.FixMinigame.Background.Frame.Middle
                FixGame.Circle.Rotation = FixGame.Pointer.Rotation - 20
                task.wait()
            end
        end)
    end
})
Tab:AddToggle({ -- 自动修复
    Name = "自动修复",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value == false then
            autofix = false
            return
        end
        autofix = true
        task.spawn(function()
            for _, autofixthing in pairs(workspace.Rooms:GetDescendants()) do
                if autofixthing.Name == "EncounterGenerator" then
                    autofixthing.RemoteFunction:InvokeServer("")
                    while autofixthing.Fixed ~= 100 do
                        autofixthing.RemoteEvent:FireServer("")
                        autofixthing.RemoteEvent:FireServer("")
                        autofixthing.RemoteEvent:FireServer("")
                        autofixthing.RemoteEvent:FireServer("")
                        task.wait()
                    end
                end
            end
        end)
    end
})
Tab:AddToggle({ -- 轻松交互
    Name = "自动过367小游戏",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value == false then
            auto367game = false
            return
        end
        auto367game = true
        task.spawn(function()
            while auto367game and OrionLib:IsRunning() do
                PandemoniumGame = PlayerGui.Main.PandemoniumMiniGame.Background.Frame
                PandemoniumGame.circle.Position = UDim2.new(0, 0, 0, 20)
                task.wait()
            end
        end)
    end
})
Tab:AddToggle({ -- 轻松交互
    Name = "自动交互",
    Save = true,
    Default = false,
    Callback = function(Value)
        if Value == false then
            autoinst = false
            return
        end
        autoinst = true
        task.spawn(function()
            while autoinst and OrionLib:IsRunning() do -- 交互-循环
                for _, proximity in pairs(workspace:GetDescendants()) do
                    if proximity:IsA("ProximityPrompt") and
                        not table.find(noautoinst, proximity:FindFirstAncestorOfClass("Model").Name) then
                        proximity:InputHoldBegin()
                    end
                end
                task.wait(0.05)
            end
        end)
    end
})
Section = Tab:AddSection({
    Name = "相机"
})
Tab:AddToggle({ -- 保持广角
    Name = "保持广角",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            keep120fov = true
            task.spawn(function()
                while game.Workspace.Camera.FieldOfView ~= "120" and keep120fov and OrionLib:IsRunning() do
                    game.Workspace.Camera.FieldOfView = "120"
                    task.wait()
                end
            end)
        else
            keep120fov = false
        end
    end
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Save = true,
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
--[[Tab:AddToggle({--第三人称
    Name = "第三人称(测试)",
    Save = true,
    Default = false,
    Callback = function(Value)
        if Value then
            thirdperson = true
            task.spawn(function()
                while thirdperson do
                    workspace.Camera.CFrame = game:GetService("Players").LocalPlayer.Character.UpperTorso.CFrame * CFrame.new(1.5, 0.5, 6.5)                    
                    task.wait()
                end
            end)
        else
            thirdperson = false
        end
    end})]]
Section = Tab:AddSection({
    Name = "其他"
})
Tab:AddButton({ --传送门
    Name = "传送到下一扇门",
    Callback = function()
        for _, notopendoor in pairs(workspace:GetDescendants()) do
            if notopendoor.Name == "NormalDoor" and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                teleportPlayerTo(Players.LocalPlayer, notopendoor.Root.Position, false)
            end
        end
    end
})
Tab:AddToggle({ 
    Name = "自动过关(测试)",
    Save = true,
    Callback = function(Value)
        if Value then
            autoplay = true
            task.spawn(function()
                while autoplay and OrionLib:IsRunning() do
                    for _, notopendoor in pairs(workspace:GetDescendants()) do
                        if notopendoor.Name == "NormalDoor" and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                            teleportPlayerTo(Players.LocalPlayer,notopendoor.Root.Position, false)
                            if notopendoor.OpenValue.Value == true then
                                break
                            end          
                        end
                    end
                    task.wait(0.05)
                end
            end)
        else
            autoplay = false
        end
    end
})
Tab:AddButton({
    Name = "再来一局",
    Callback = function()
        Notify("再来一局","请稍等...")
        RemoteFolder.PlayAgain:FireServer()
    end
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
    Save = true,
    Default = false,
    Flag = "PlayerNotifications"
})
Tab:AddButton({
    Name = "删除已修复装置的透视",
    Default = true,
    Callback = function()
        for _, FixedThings in pairs(workspace:GetDescendants()) do
            if FixedThings.Name == "EncounterGenerator" and FixedThings.Fixed.Value == 100 then
                FixedThings:FindFirstChildOfClass("BillboardGui"):Destroy()
            end
            if FixedThings.Name == "BrokenCables" and FixedThings.Fixed.Value == 100 then
                FixedThings:FindFirstChildOfClass("BillboardGui"):Destroy()
            end
        end
    end
})
Item:AddParagraph("提醒", "复制物品需要背包内有物品本体,复制出的工具行为与本体相同")
Item:AddDropdown({
    Name = "功能",
    Default = "复制",
    Options = {"复制", "删除"},
    Flag = "cpyordel"
})
Item:AddButton({
    Name = "闪光灯",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("FlashBeacon")
            copyNotifi("闪光灯")
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.FlashBeacon:Destroy()
            delNotifi("闪光灯")
        end
    end
})
Item:AddButton({
    Name = "黑光",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Blacklight")
            copyNotifi("黑光")
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Blacklight:Destroy()
            delNotifi("黑光")
        end
    end
})
Item:AddButton({
    Name = "手摇手电筒",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("WindupLight")
            copyNotifi("手摇手电筒")
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.WindupLight:Destroy()
            delNotifi("手摇手电筒")
        end
    end
})
Item:AddButton({
    Name = "手电筒",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Flashlight")
            copyNotifi("手电筒")
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Flashlight:Destroy()
            delNotifi("手电筒")
        end
    end
})
Item:AddButton({
    Name = "灯笼",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Lantern")
            copyNotifi("灯笼")
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Lantern:Destroy()
            delNotifi("灯笼")
        end
    end
})
Item:AddButton({
    Name = "魔法书",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Book")
            copyNotifi("魔法书")
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Book:Destroy()
            delNotifi("魔法书")
        end
    end
})
Item:AddButton({
    Name = "软糖手电筒",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Gummylight")
            copyNotifi("软糖手电筒")
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Gummylight:Destroy()
            delNotifi("软糖手电筒")
        end
    end
})
Del:AddToggle({
    Name = "删除z317",
    Save = true,
    Default = true,
    Flag = "noeyefestation",
})
Del:AddToggle({
    Name = "删除z367",
    Save = true,
    Default = true,
    Flag = "nopandemonium",
})
Del:AddToggle({
    Name = "删除Searchlights(待增强)",
    Save = true,
    Default = true,
    Flag = "nosearchlights",
})
Del:AddToggle({
    Name = "删除S-Q",
    Save = true,
    Default = true,
    Flag = "nosq",
})
Del:AddToggle({
    Name = "删除炮台",
    Save = true,
    Default = true,
    Flag = "noturret",
})
Del:AddToggle({
    Name = "删除自然伤害(大部分)",
    Save = true,
    Default = true,
    Flag = "nodamage",
})
Del:AddToggle({
    Name = "删除z432",
    Save = true,
    Default = true,
    Flag = "noFriendPart",
})
Del:AddToggle({
    Name = "删除水区",
    Save = true,
    Default = true,
    Flag = "nowatertoswim",
})
Del:AddToggle({
    Name = "删除假柜",
    Save = true,
    Default = true,
    Flag = "noMonsterLocker",
})
Esp:AddToggle({ -- door
    Name = "门透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            doorsesp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel.Parent.Name == "Entrances" then
                    espmodel(themodel,"NormalDoor","门","0","1","0",true)
                    espmodel(themodel,"BigRoomDoor","大门","0","1","0",true)
                end
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                if themodel.Parent.Name == "Entrances" then
                    espmodel(themodel,"NormalDoor","门","0","1","0",true)
                    espmodel(themodel,"BigRoomDoor","大门","0","1","0",true)
                end
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if doorsesp == false then
                        esp:Disconnect()
                        unesp("门")
                        unesp("大门")
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "门透视高光" or hl.Name == "大门透视高光" then
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
        end
    end
})
Esp:AddToggle({ -- locker
    Name = "柜子透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            lockeresp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                espmodel(themodel,"Locker","柜子","0","1","0",false)
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                espmodel(themodel,"Locker","柜子","0","1","0",false)
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if lockeresp == false then
                        esp:Disconnect()
                        unesp("柜子")
                        break
                    end   
                    task.wait(0.1)
                end                
            end)
        else
            lockeresp = false
        end
    end
})
Esp:AddToggle({ -- keycard
    Name = "钥匙卡透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            keyesp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                espmodel(themodel,"NormalKeyCard","钥匙卡","0","0","1",true)
                espmodel(themodel,"InnerKeyCard","特殊钥匙卡","100","0","255",true)
                espmodel(themodel,"RidgeKeyCard","山脊钥匙卡","1","1","0",true)
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                espmodel(themodel,"NormalKeyCard","钥匙卡","0","0","1",true)
                espmodel(themodel,"InnerKeyCard","特殊钥匙卡","100","0","255",true)
                espmodel(themodel,"RidgeKeyCard","山脊钥匙卡","1","1","0",true)
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if keyesp == false then
                        esp:Disconnect()
                        unesp("钥匙卡")
                        unesp("特殊钥匙卡")
                        unesp("山脊钥匙卡")
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "钥匙卡透视高光" or hl.Name == "特殊钥匙卡透视高光" or hl.Name == "山脊钥匙卡透视高光" then
                                hl:Destroy()                            
                            end
                        end
                        break
                    end   
                    task.wait(0.1)
                end
            end)
        else
            keyesp = false
        end
    end
})
Esp:AddToggle({ -- fake door
    Name = "假门透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            fakedooresp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                espmodel(themodel,"TricksterRoom", "假门", "1", "0", "0",true)
                espmodel(themodel,"ServerTrickster", "假门", "1", "0", "0",true)
                espmodel(themodel,"RidgeTricksterRoom", "假门", "1", "0", "0",true)
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                espmodel(themodel,"TricksterRoom", "假门", "1", "0", "0",true)
                espmodel(themodel,"ServerTrickster", "假门", "1", "0", "0",true)
                espmodel(themodel,"RidgeTricksterRoom", "假门", "1", "0", "0",true)
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if fakedooresp == false then
                        esp:Disconnect()
                        unesp("假门")
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "假门透视高光" then
                                hl:Destroy()                            
                            end
                        end
                        break
                    end   
                    task.wait(0.1)
                end
            end)
        else
            fakedooresp = false
        end
    end
})
Esp:AddToggle({ -- fake locker
    Name = "假柜透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            fakelockeresp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                espmodel(themodel,"MonsterLocker", "假柜子", "1", "0", "0",false)
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                espmodel(themodel,"MonsterLocker", "假柜子", "1", "0", "0",false)
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if fakelockeresp == false then
                        esp:Disconnect()
                        unesp("假柜子")
                        break
                    end   
                    task.wait(0.1)
                end
            end)
        else
            fakelockeresp = false
        end
    end
})
Esp:AddToggle({ -- 发电机
    Name = "修复设备透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            fixdeviceesp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                espmodel(themodel,"EncounterGenerator", "未修复发电机", "1", "0", "0",false)
                espmodel(themodel,"BrokenCables", "未修复电缆", "1", "0", "0",false)
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                espmodel(themodel,"EncounterGenerator", "未修复发电机", "1", "0", "0",false)
                espmodel(themodel,"BrokenCables", "未修复电缆", "1", "0", "0",false)
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if fixdeviceesp == false then
                        esp:Disconnect()
                        unesp("未修复发电机")
                        unesp("未修复电缆")
                        break
                    end   
                    task.wait(0.1)
                end
            end)
        else
            fixdeviceesp = false
        end
    end
})
Esp:AddToggle({ -- 物品
    Name = "物品透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            itemesp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                espmodel(themodel,"DefaultBattery1", "电池", "1", "1", "1",false)
                espmodel(themodel,"Flashlight", "手电筒", "25", "25", "25",false)
                espmodel(themodel,"Lantern", "灯笼", "99", "99", "99",false)
                espmodel(themodel,"FlashBeacon", "闪光", "1", "1", "1",false)
                espmodel(themodel,"Blacklight", "黑光", "127", "0", "255",false)
                espmodel(themodel,"Gummylight", "软糖手电筒", "15", "230", "100",false)
                espmodel(themodel,"CodeBreacher", "红卡", "255", "30", "30",false)
                espmodel(themodel,"DwellerPiece", "墙居者肉块", "50", "10", "25",false)
                espmodel(themodel,"Medkit", "医疗箱", "80", "51", "235",false)
                espmodel(themodel,"WindupLight", "手摇手电筒", "85", "100", "66",false)
                espmodel(themodel,"Book", "魔法书", "0", "255", "255",true)
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                espmodel(themodel,"DefaultBattery1", "电池", "1", "1", "1",false)
                espmodel(themodel,"Flashlight", "手电筒", "25", "25", "25",false)
                espmodel(themodel,"Lantern", "灯笼", "99", "99", "99",false)
                espmodel(themodel,"FlashBeacon", "闪光", "1", "1", "1",false)
                espmodel(themodel,"Blacklight", "黑光", "127", "0", "255",false)
                espmodel(themodel,"Gummylight", "软糖手电筒", "15", "230", "100",false)
                espmodel(themodel,"CodeBreacher", "红卡", "255", "30", "30",false)
                espmodel(themodel,"DwellerPiece", "墙居者肉块", "50", "10", "25",false)
                espmodel(themodel,"Medkit", "医疗箱", "80", "51", "235",false)
                espmodel(themodel,"WindupLight", "手摇手电筒", "85", "100", "66",false)
                espmodel(themodel,"Book", "魔法书", "0", "255", "255",true)
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if itemesp == false then
                        esp:Disconnect()
                        unesp("电池")
                        unesp("手电筒")
                        unesp("灯笼")
                        unesp("闪光")
                        unesp("黑光")
                        unesp("软糖手电筒")
                        unesp("红卡")
                        unesp("墙居者肉块")
                        unesp("医疗箱")
                        unesp("手摇手电筒")
                        unesp("魔法书")
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "魔法书透视高光" then
                                hl:Destroy()                            
                            end
                        end
                        break
                    end   
                    task.wait(0.1)
                end
            end)
        else
            itemesp = false
        end
    end
})
Esp:AddToggle({ -- 钱
    Name = "研究(钱)透视",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value then
            moneyesp = true
            for _, themodel in pairs(workspace:GetDescendants()) do
                espmodel(themodel,"5Currency", "5钱", "1", "1", "1",false)
                espmodel(themodel,"10Currency", "10钱", "1", "1", "1",false)
                espmodel(themodel,"15Currency", "15钱", "0.5", "0.5", "0.5",false)
                espmodel(themodel,"20Currency", "20钱", "1", "1", "1",false)
                espmodel(themodel,"25Currency", "25钱", "1", "1", "0",false)
                espmodel(themodel,"50Currency", "50钱", "1", "0.5", "0",true)
                espmodel(themodel,"100Currency", "100钱", "1", "0", "1",true)
                espmodel(themodel,"200Currency", "200钱", "0", "1", "1",true)
                espmodel(themodel,"Relic", "500钱", "0", "1", "1",true)
            end
            esp = workspace.DescendantAdded:Connect(function(themodel)
                espmodel(themodel,"5Currency", "5钱", "1", "1", "1",false)
                espmodel(themodel,"10Currency", "10钱", "1", "1", "1",false)
                espmodel(themodel,"15Currency", "15钱", "0.5", "0.5", "0.5",false)
                espmodel(themodel,"20Currency", "20钱", "1", "1", "1",false)
                espmodel(themodel,"25Currency", "25钱", "1", "1", "0",false)
                espmodel(themodel,"50Currency", "50钱", "1", "0.5", "0",true)
                espmodel(themodel,"100Currency", "100钱", "1", "0", "1",true)
                espmodel(themodel,"200Currency", "200钱", "0", "1", "1",true)
                espmodel(themodel,"Relic", "500钱", "0", "1", "1",true)
            end)
            table.insert(EspConnects,esp)
            task.spawn(function()
                while OrionLib:IsRunning() do
                    if moneyesp == false then
                        esp:Disconnect()
                        unesp("5钱")
                        unesp("10钱")
                        unesp("15钱")
                        unesp("20钱")
                        unesp("25钱")
                        unesp("50钱")
                        unesp("100钱")
                        unesp("200钱")
                        unesp("500钱")
                        for _, hl in pairs(PlayerGui:GetChildren()) do
                            if hl.Name == "50钱透视高光" or hl.Name == "100钱透视高光" or hl.Name == "200钱透视高光" or hl.Name == "500钱透视高光" then
                                hl:Destroy()                            
                            end
                        end
                        break
                    end   
                    task.wait(0.1)
                end
            end)
        else
            moneyesp = false
        end
    end
})
Esp:AddToggle({ -- 实体
    Name = "实体透视",
    Save = true,
    Default = true,
    Flag = "EntityEsp"
})
Esp:AddToggle({ -- 玩家
    Name = "玩家透视",
    Save = true,
    Default = false,
    Callback = function(Value)
        for _, player in pairs(game.Players:GetPlayers()) do
            if Value then
                if player ~= game.Players.LocalPlayer then
                    createBilltoesp(player.Character, player.Name, Color3.new(238, 201, 0),false)
                end
            else
                if player.Character:FindFirstChildOfClass("BillboardGui") then
                    player.Character:FindFirstChildOfClass("BillboardGui"):Destroy()
                end
            end
        end
    end
})
workspaceDA = workspace.DescendantAdded:Connect(function(inst) -- 其他
    if inst.Name == "Eyefestation" and OrionLib.Flags.noeyefestation.Value then
        inst:Destroy()
        delNotifi("Eyefestation")
    end
    if inst.Name == "EnragedEyefestation" and OrionLib.Flags.noeyefestation.Value then
        inst:Destroy()
    end
    if inst.Name == "EyefestationGaze" and OrionLib.Flags.noeyefestation.Value then
        inst:Destroy()
    end
    if inst.Name == "EnragedEyefestation" and OrionLib.Flags.noeyefestation.Value then -- 其他
        task.wait(0.2)
        inst:Destroy()
    end
    if inst.Name == "Searchlights" and OrionLib.Flags.nosearchlights.Value then -- 无Searchlights
        for _, SLE in pairs(workspace:GetDescendants()) do
            if SLE.Name == "SearchlightsEncounter" then
                task.wait(0.1)
                SLE_room = workspace.Rooms.SearchlightsEncounter
                SLE_room.Searchlights:Destroy()
                SLE_room.MainSearchlight:Destroy()
            elseif SLE.Name == "SearchlightsEnding" and OrionLib.Flags.nosearchlights.Value then
                task.wait(0.1)
                SLE_room = workspace.Rooms.SearchlightsEnding.Interactables
                SLE_room.Searchlights1:Destroy()
                SLE_room.Searchlights2:Destroy()
                SLE_room.Searchlights3:Destroy()
                SLE_room.Searchlights:Destroy()
            end
        end
        delNotifi("Searchlights")
    end
    if inst.Name == "Steams" and OrionLib.Flags.nodamage.Value then -- 无环境伤害
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "DamageParts" and OrionLib.Flags.nodamage.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "DamagePart" and OrionLib.Flags.nodamage.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "Electricity" and OrionLib.Flags.nodamage.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "TurretSpawn" and OrionLib.Flags.noturret.Value then -- 炮台
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "TurretSpawn1" and OrionLib.Flags.noturret.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "TurretSpawn2" and OrionLib.Flags.noturret.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "TurretSpawn3" and OrionLib.Flags.noturret.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "MonsterLocker" and OrionLib.Flags.noMonsterLocker.Value then -- 假柜子
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "Joint1" and OrionLib.Flags.nosq.Value then -- S-Q
        task.wait(0.1)
        inst.Parent:Destroy()
    end
    if inst.Name == "FriendPart" and OrionLib.Flags.noFriendPart.Value then -- z432nowatertoswim
        task.wait(0.1)
        inst:Destroy()
        delNotifi("z432")
    end
    if inst.Name == "WaterPart" and inst:FindFirstAncestorOfClass("Folder").Name == "Rooms" and OrionLib.Flags.nowatertoswim.Value then -- 水区
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "Trickster" and inst:FindFirstAncestorOfClass("Model").Name == "Trickster" and OrionLib.Flags.noTrickster.Value then -- 假门
        Notify("检测假门", "尝试删除")
        inst.Trickster:Destroy()
    end
    if inst.Name == "WallDweller" and OrionLib.Flags.NotifyEntities.Value then -- 实体提醒-z90
        entityNotifi("墙居者出现")
        if OrionLib.Flags.chatNotifyEntities.Value then
            chatMessage("墙居者出现")
        end
    end
    if inst.Name == "RottenWallDweller" and OrionLib.Flags.NotifyEntities.Value then
        entityNotifi("墙居者出现")
        if OrionLib.Flags.chatNotifyEntities.Value then
            chatMessage("墙居者出现")
        end
    end
end)
workspaceDR = workspace.DescendantRemoving:Connect(function(inst) -- 实体提醒-z90
    if inst.Name == "WallDweller" and OrionLib.Flags.NotifyEntities.Value then
        entityNotifi("墙居者消失")
        if OrionLib.Flags.chatNotifyEntities.Value then
            chatMessage("墙居者消失")
        end
    end
    if inst.Name == "RottenWallDweller" and OrionLib.Flags.NotifyEntities.Value then
        entityNotifi("墙居者消失")
        if OrionLib.Flags.chatNotifyEntities.Value then
            chatMessage("墙居者消失")
        end
    end
end)
workspaceCA = workspace.ChildAdded:Connect(function(child) -- 关于实体
    if table.find(entityNames, child.Name) and child:IsDescendantOf(workspace) then
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.avoid.Value == false then -- 实体提醒
            entityNotifi(child.Name .. "出现")
        end
        if OrionLib.Flags.avoid.Value and child.Name ~= "Mirage" then -- 自动躲避
            createPlatform("AvoidPlatform", Vector3.new(3000, 1, 3000), Vector3.new(5000, 10000, 5000))
            teleportPlayerTo(Players.LocalPlayer, Platform.Position + Vector3.new(0, Platform.Size.Y / 2 + 5, 0),true)
            Entitytoavoid[child] = true
            entityNotifi(child.Name .. "出现,自动躲避中")
        end
        if OrionLib.Flags.chatNotifyEntities.Value then -- 实体播报
            chatMessage(child.Name .. "出现")
        end
        if OrionLib.Flags.EntityEsp.Value then -- 实体esp
            createBilltoesp(child, child.Name, Color3.new(1, 0, 0), true)
        end
        if OrionLib.Flags.nopandemonium.Value and child.Name == "Pandemonium" and child:IsDescendantOf(workspace) then -- 删除z367
            task.wait(0.1)
            child:Destroy()
            delNotifi("Pandemonium")
        end
    end
end)
workspaceCR = workspace.ChildRemoved:Connect(function(child) -- 关于实体
    if table.find(entityNames, child.Name) then
        if OrionLib.Flags.avoid.Value and Entitytoavoid[child] then -- 自动躲避
            teleportPlayerBack(Players.LocalPlayer)
            Entitytoavoid[child] = nil
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.avoid.Value == false then -- 实体提醒
            entityNotifi(child.Name .. "消失")
        end
        if OrionLib.Flags.chatNotifyEntities.Value then -- 实体播报
            chatMessage(child.Name .. "消失")
        end
    end 
    if child.Name == "Mirage" then -- Mirage
        if OrionLib.Flags.NotifyEntities.Value then
            entityNotifi("Mirage消失")
        end
        if OrionLib.Flags.chatNotifyEntities.Value then
            chatMessage(child.Name .. "消失")
        end
    end
end)
Players.PlayerAdded:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        Notify("玩家提醒", player.Name .. Notififriend .. "已加入", 2,false)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        Notify("玩家提醒", player.Name .. Notififriend .. "已退出", 2,false)
    end
end)
