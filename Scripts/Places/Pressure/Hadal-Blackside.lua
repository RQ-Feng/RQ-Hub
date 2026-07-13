-- local设置
local entityNames = {"Angler", "RidgeAngler", "Blitz", "RidgeBlitz", "Pinkie", "RidgePinkie", "Froger", "RidgeFroger","Chainsmoker", "Pandemonium", "Eyefestation", "A60", "Mirage"} -- 实体
local autoInst_Blacklist = {"Locker", "MonsterLocker", "LockerUnderwater", "Generator", "BrokenCable","EncounterGenerator","Saboterousrusrer","Toilet","BigBed","Radio","BatteryPile","Lock","NormalDoor"}
local NotifyMes = {
    ["delete"] = "已成功删除",
    ["copy"] = "已成功复制",
    ["entity"] = "实体提醒"
}
local DoorName = {
    ['NormalDoor'] = "门",
    ['BigRoomDoor'] = "大门"
}
local playerPositions = {} -- 存储玩家坐标
local Entitytoavoid = {} -- 自动躲避用-检测自动躲避的实体
-- ESP开关 (已改用Flag管理)
local Platform -- 平台
local ezinst,autofix,auto367game,autoplay -- 功能开关

local PlayerGui = Players.LocalPlayer.PlayerGui--本地玩家PlayerGui
local RemoteFolder = ReplicatedStorage.Events -- Remote Event储存区之一
--local结束->Function设置
local function copyitems(copyitem) -- 复制物品
    local create_NumberValue = Instance.new("NumberValue") -- copy items-type NumberValue
    create_NumberValue.Name = copyitem
    create_NumberValue.Parent = game.Players.LocalPlayer.PlayerFolder.Inventory
end

local function createPlatform(name, sizeVector3,positionVector3) -- 创建平台-Vector3.new(x,y,z)
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
local function teleportPlayer(player, toPositionVector3) -- 传送玩家-Vector3.new(x,y,z)
    if not player.Character:FindFirstChild("HumanoidRootPart") then return end
    playerPositions[player.UserId] = player.Character.HumanoidRootPart.CFrame
    player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
end
local function teleportBack(player) -- 返回玩家 
    if playerPositions[player.UserId] then
        player.Character.HumanoidRootPart.CFrame = playerPositions[player.UserId]
        playerPositions[player.UserId] = nil
    else
        warn("返回失败!")
    end
end
local function chatMessage(chat) -- 发送信息
    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(tostring(chat))
end
--Function结束-其他
OrionNotify("加载完成", "已成功加载")
--Tab界面
local Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
local Item = Window:MakeTab({
    Name = "物品",
    Icon = "rbxassetid://4483345998"
})
local Del = Window:MakeTab({
    Name = "删除",
    Icon = "rbxassetid://4483345998"
})
local Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
local others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998"
})
--子界面
Tab:AddSection({
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
        teleportBack(Players.LocalPlayer)
    end
})
Tab:AddSection({
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
                        if toezInteract:IsA("ProximityPrompt") and not string.find(toezInteract:FindFirstAncestorOfClass("Model").Name,'bunny') then
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
-- Tab:AddToggle({ -- 轻松修复
--     Name = "轻松修复",
--     Save = true,
--     Default = true,
--     Callback = function(Value)
--         if Value == false then
--             ezfix = false
--             return
--         end
--         ezfix = true
--         task.spawn(function()
--             while ezfix and OrionLib:IsRunning() do
--                 FixGame = PlayerGui.Main.FixMinigame.Background.Frame.Middle
--                 FixGame.Circle.Rotation = FixGame.Pointer.Rotation - 20
--                 task.wait()
--             end
--         end)
--     end
-- })
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
            for _, autofixthing in pairs(workspace.GameplayFolder.Rooms:GetDescendants()) do
                if autofixthing.Name == "Generator" then
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
    Flag = "AutoPrompt",
    Callback = function(Value)
        if not Value then return end
        AddConnection(ProximityPromptService.PromptShown,function(prompt)
            local model = prompt:FindFirstAncestorOfClass("Model")
            if table.find(autoInst_Blacklist,model.Name) or string.find(model.Name,'bunny') then return end
            while prompt and prompt.Parent and OrionLib:IsRunning() and OrionLib.Flags['AutoPrompt'].Value do     
                fireproximityprompt(prompt); task.wait() 
            end
        end,OrionLib.Flags['AutoPrompt'])
    end
})
Tab:AddSection({
    Name = "相机"
})
Tab:AddToggle({ -- 保持广角
    Name = "保持广角",
    Save = true,
    Default = true,
    Flag = "keep120fov",
    Callback = function(Value)
        if not Value then return end
        AddConnection(workspace.Camera.Changed,function(property)
            if property ~= 'FieldOfView' then return end
            workspace.Camera.FieldOfView = "120"
        end)
        workspace.Camera.FieldOfView = "120"
    end
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Save = true,
    Default = true,
    Callback = function(Value) FullBright(Value) end
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
Tab:AddSection({
    Name = "其他"
})
Tab:AddButton({ --传送门
    Name = "传送到下一扇门",
    Callback = function()
        for _, notopendoor in pairs(workspace:GetDescendants()) do
            if notopendoor.Name == "NormalDoor" and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                teleportPlayer(Players.LocalPlayer, notopendoor.Root.Position)
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
                            teleportPlayer(Players.LocalPlayer,notopendoor.Root.Position)
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
    ClickTwice = true,
    Callback = function()
        OrionNotify("再来一局","请稍等...")
        RemoteFolder.PlayAgain:FireServer()
    end
})
-- Tab:AddSlider({
--     Name = "玩家透明度",
--     Save = true,
--     Min = 0,
--     Max = 1,
--     Default = 0,
--     Increment = 0.05,
--     Callback = function(Value)
--         for _, humanpart in pairs(Character:GetChildren()) do
--             if humanpart:IsA("MeshPart") then
--                 humanpart.Transparency = Value
--             end
--         end
--     end
-- })
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
            OrionNotify("闪光灯", NotifyMes["copy"])
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.FlashBeacon:Destroy()
            OrionNotify("闪光灯", NotifyMes["delete"])
        end
    end
})
Item:AddButton({
    Name = "黑光",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Blacklight")
            OrionNotify("黑光", NotifyMes["copy"])
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Blacklight:Destroy()
            OrionNotify("黑光", NotifyMes["delete"])
        end
    end
})
Item:AddButton({
    Name = "手摇手电筒",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("WindupLight")
            OrionNotify("手摇手电筒", NotifyMes["copy"])
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.WindupLight:Destroy()
            OrionNotify("手摇手电筒", NotifyMes["delete"])
        end
    end
})
Item:AddButton({
    Name = "手电筒",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Flashlight")
            OrionNotify("手电筒", NotifyMes["copy"])
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Flashlight:Destroy()
            OrionNotify("手电筒", NotifyMes["delete"])
        end
    end
})
Item:AddButton({
    Name = "灯笼",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Lantern")
            OrionNotify("灯笼", NotifyMes["copy"])
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Lantern:Destroy()
            OrionNotify("灯笼", NotifyMes["delete"])
        end
    end
})
Item:AddButton({
    Name = "魔法书",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Book")
            OrionNotify("魔法书", NotifyMes["copy"])
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Book:Destroy()
            OrionNotify("魔法书", NotifyMes["delete"])
        end
    end
})
Item:AddButton({
    Name = "软糖手电筒",
    Callback = function()
        if OrionLib.Flags.cpyordel.Value == "复制" then
            copyitems("Gummylight")
            OrionNotify("软糖手电筒", NotifyMes["copy"])
        else
            game.Players.LocalPlayer.PlayerFolder.Inventory.Gummylight:Destroy()
            OrionNotify("软糖手电筒", NotifyMes["delete"])
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
    Flag = "DoorEsp",
    Callback = function(Value)
        if not Value then return end
        for _,door in pairs(room:WaitForChild("Entrances")) do
            AddESP({
                inst = door,
                Name = DoorName[door.Name] or door.Name,
                Color = Color3.new(0,1,0)
            })
        end
    end
})
Esp:AddToggle({ -- locker
    Name = "柜子透视",
    Save = true,
    Default = true,
    Flag = "LockerEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players and themodel.Name == "Locker" then
                    AddESP({inst = themodel, Name = "柜子", Color = Color3.new(0,1,0), value = OrionLib.Flags["LockerEsp"]})
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players and themodel.Name == "Locker" then
                    AddESP({inst = themodel, Name = "柜子", Color = Color3.new(0,1,0), value = OrionLib.Flags["LockerEsp"]})
                end
            end,OrionLib.Flags["LockerEsp"])
        end
    end
})
Esp:AddToggle({ -- keycard
    Name = "钥匙卡透视",
    Save = true,
    Default = true,
    Flag = "KeycardEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "NormalKeyCard" then AddESP({inst = themodel, Name = "钥匙卡", Color = Color3.new(0,0,1), value = OrionLib.Flags["KeycardEsp"]})
                    elseif themodel.Name == "InnerKeyCard" then AddESP({inst = themodel, Name = "特殊钥匙卡", Color = Color3.new(100,0,255), value = OrionLib.Flags["KeycardEsp"]})
                    elseif themodel.Name == "RidgeKeyCard" then AddESP({inst = themodel, Name = "山脊钥匙卡", Color = Color3.new(1,1,0), value = OrionLib.Flags["KeycardEsp"]})
                    end
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "NormalKeyCard" then AddESP({inst = themodel, Name = "钥匙卡", Color = Color3.new(0,0,1), value = OrionLib.Flags["KeycardEsp"]})
                    elseif themodel.Name == "InnerKeyCard" then AddESP({inst = themodel, Name = "特殊钥匙卡", Color = Color3.new(100,0,255), value = OrionLib.Flags["KeycardEsp"]})
                    elseif themodel.Name == "RidgeKeyCard" then AddESP({inst = themodel, Name = "山脊钥匙卡", Color = Color3.new(1,1,0), value = OrionLib.Flags["KeycardEsp"]})
                    end
                end
            end,OrionLib.Flags["KeycardEsp"])
        end
    end
})
Esp:AddToggle({ -- fake door
    Name = "假门透视",
    Save = true,
    Default = true,
    Flag = "FakeDoorEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players and (themodel.Name == "TricksterRoom" or themodel.Name == "ServerTrickster" or themodel.Name == "RidgeTricksterRoom") then
                    AddESP({inst = themodel, Name = "假门", Color = Color3.new(1,0,0), value = OrionLib.Flags["FakeDoorEsp"]})
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players and (themodel.Name == "TricksterRoom" or themodel.Name == "ServerTrickster" or themodel.Name == "RidgeTricksterRoom") then
                    AddESP({inst = themodel, Name = "假门", Color = Color3.new(1,0,0), value = OrionLib.Flags["FakeDoorEsp"]})
                end
            end,OrionLib.Flags["FakeDoorEsp"])
        end
    end
})
Esp:AddToggle({ -- fake locker
    Name = "假柜透视",
    Save = true,
    Default = true,
    Flag = "FakeLockerEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players and themodel.Name == "MonsterLocker" then
                    AddESP({inst = themodel, Name = "假柜子", Color = Color3.new(1,0,0), value = OrionLib.Flags["FakeLockerEsp"]})
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players and themodel.Name == "MonsterLocker" then
                    AddESP({inst = themodel, Name = "假柜子", Color = Color3.new(1,0,0), value = OrionLib.Flags["FakeLockerEsp"]})
                end
            end,OrionLib.Flags["FakeLockerEsp"])
        end
    end
})
Esp:AddToggle({ -- 发电机
    Name = "修复设备透视",
    Save = true,
    Default = true,
    Flag = "FixDeviceEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "EncounterGenerator" then AddESP({inst = themodel, Name = "未修复发电机", Color = Color3.new(1,0,0), value = OrionLib.Flags["FixDeviceEsp"]})
                    elseif themodel.Name == "BrokenCables" then AddESP({inst = themodel, Name = "未修复电缆", Color = Color3.new(1,0,0), value = OrionLib.Flags["FixDeviceEsp"]})
                    end
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "EncounterGenerator" then AddESP({inst = themodel, Name = "未修复发电机", Color = Color3.new(1,0,0), value = OrionLib.Flags["FixDeviceEsp"]})
                    elseif themodel.Name == "BrokenCables" then AddESP({inst = themodel, Name = "未修复电缆", Color = Color3.new(1,0,0), value = OrionLib.Flags["FixDeviceEsp"]})
                    end
                end
            end,OrionLib.Flags["FixDeviceEsp"])
        end
    end
})
Esp:AddToggle({ -- 物品
    Name = "物品透视",
    Save = true,
    Default = true,
    Flag = "ItemEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "DefaultBattery1" then AddESP({inst = themodel, Name = "电池", Color = Color3.new(1,1,1), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Flashlight" then AddESP({inst = themodel, Name = "手电筒", Color = Color3.new(25,25,25), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Lantern" then AddESP({inst = themodel, Name = "灯笼", Color = Color3.new(99,99,99), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "FlashBeacon" then AddESP({inst = themodel, Name = "闪光", Color = Color3.new(1,1,1), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Blacklight" then AddESP({inst = themodel, Name = "黑光", Color = Color3.new(127,0,255), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Gummylight" then AddESP({inst = themodel, Name = "软糖手电筒", Color = Color3.new(15,230,100), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "CodeBreacher" then AddESP({inst = themodel, Name = "红卡", Color = Color3.new(255,30,30), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "DwellerPiece" then AddESP({inst = themodel, Name = "墙居者肉块", Color = Color3.new(50,10,25), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Medkit" then AddESP({inst = themodel, Name = "医疗箱", Color = Color3.new(80,51,235), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "WindupLight" then AddESP({inst = themodel, Name = "手摇手电筒", Color = Color3.new(85,100,66), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Book" then AddESP({inst = themodel, Name = "魔法书", Color = Color3.new(0,255,255), value = OrionLib.Flags["ItemEsp"]})
                    end
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "DefaultBattery1" then AddESP({inst = themodel, Name = "电池", Color = Color3.new(1,1,1), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Flashlight" then AddESP({inst = themodel, Name = "手电筒", Color = Color3.new(25,25,25), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Lantern" then AddESP({inst = themodel, Name = "灯笼", Color = Color3.new(99,99,99), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "FlashBeacon" then AddESP({inst = themodel, Name = "闪光", Color = Color3.new(1,1,1), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Blacklight" then AddESP({inst = themodel, Name = "黑光", Color = Color3.new(127,0,255), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Gummylight" then AddESP({inst = themodel, Name = "软糖手电筒", Color = Color3.new(15,230,100), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "CodeBreacher" then AddESP({inst = themodel, Name = "红卡", Color = Color3.new(255,30,30), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "DwellerPiece" then AddESP({inst = themodel, Name = "墙居者肉块", Color = Color3.new(50,10,25), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Medkit" then AddESP({inst = themodel, Name = "医疗箱", Color = Color3.new(80,51,235), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "WindupLight" then AddESP({inst = themodel, Name = "手摇手电筒", Color = Color3.new(85,100,66), value = OrionLib.Flags["ItemEsp"]})
                    elseif themodel.Name == "Book" then AddESP({inst = themodel, Name = "魔法书", Color = Color3.new(0,255,255), value = OrionLib.Flags["ItemEsp"]})
                    end
                end
            end,OrionLib.Flags["ItemEsp"])
        end
    end
})
Esp:AddToggle({ -- 钱
    Name = "研究(钱)透视",
    Save = true,
    Default = true,
    Flag = "MoneyEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "5Currency" then AddESP({inst = themodel, Name = "5钱", Color = Color3.new(1,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "10Currency" then AddESP({inst = themodel, Name = "10钱", Color = Color3.new(1,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "15Currency" then AddESP({inst = themodel, Name = "15钱", Color = Color3.new(0.5,0.5,0.5), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "20Currency" then AddESP({inst = themodel, Name = "20钱", Color = Color3.new(1,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "25Currency" then AddESP({inst = themodel, Name = "25钱", Color = Color3.new(1,1,0), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "50Currency" then AddESP({inst = themodel, Name = "50钱", Color = Color3.new(1,0.5,0), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "100Currency" then AddESP({inst = themodel, Name = "100钱", Color = Color3.new(1,0,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "200Currency" then AddESP({inst = themodel, Name = "200钱", Color = Color3.new(0,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "Relic" then AddESP({inst = themodel, Name = "500钱", Color = Color3.new(0,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    end
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Parent ~= Players then
                    if themodel.Name == "5Currency" then AddESP({inst = themodel, Name = "5钱", Color = Color3.new(1,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "10Currency" then AddESP({inst = themodel, Name = "10钱", Color = Color3.new(1,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "15Currency" then AddESP({inst = themodel, Name = "15钱", Color = Color3.new(0.5,0.5,0.5), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "20Currency" then AddESP({inst = themodel, Name = "20钱", Color = Color3.new(1,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "25Currency" then AddESP({inst = themodel, Name = "25钱", Color = Color3.new(1,1,0), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "50Currency" then AddESP({inst = themodel, Name = "50钱", Color = Color3.new(1,0.5,0), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "100Currency" then AddESP({inst = themodel, Name = "100钱", Color = Color3.new(1,0,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "200Currency" then AddESP({inst = themodel, Name = "200钱", Color = Color3.new(0,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    elseif themodel.Name == "Relic" then AddESP({inst = themodel, Name = "500钱", Color = Color3.new(0,1,1), value = OrionLib.Flags["MoneyEsp"]})
                    end
                end
            end,OrionLib.Flags["MoneyEsp"])
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
    Flag = "PlayerEsp",
    Callback = function(Value)
        if not Value then return end
        for _, player in pairs(game.Players:GetPlayers()) do
            if player == game.Players.LocalPlayer then continue end
            AddESP({
                inst = player.Character,
                Name = player.Name,
                Color = Color3.fromRGB(238, 201, 0),
                value = OrionLib.Flags["PlayerEsp"]
            })
        end
    end
})

AddConnection(workspace.GameplayFolder.Rooms.ChildAdded,function(room) -- Esp
    if OrionLib.Flags["DoorEsp"].Value then
        for _,door in pairs(room:WaitForChild("Entrances"):GetChildren()) do
            AddESP({
                inst = door,
                Name = DoorName[door.Name] or door.Name,
                Color = Color3.new(0,1,0)
            })
        end
    end
end) -- 房间
AddConnection(workspace.DescendantAdded,function(inst) -- 其他
    if inst.Name == "Eyefestation" and OrionLib.Flags.noeyefestation.Value then
        inst:Destroy()
        OrionNotify("Eyefestation", NotifyMes["delete"])
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
        OrionNotify("Searchlights", NotifyMes["delete"])
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
        OrionNotify("z432", NotifyMes["delete"])
    end
    if inst.Name == "WaterPart" and inst:FindFirstAncestorOfClass("Folder").Name == "Rooms" and OrionLib.Flags.nowatertoswim.Value then -- 水区
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "Trickster" and inst:FindFirstAncestorOfClass("Model").Name == "Trickster" and OrionLib.Flags.noTrickster.Value then -- 假门
        OrionNotify("检测假门", "尝试删除")
        inst.Trickster:Destroy()
    end
    if (inst.Name == "WallDweller" or inst.Name == "RottenWallDweller") and OrionLib.Flags.NotifyEntities.Value then
        OrionNotify(NotifyMes["entity"], "墙居者出现")
        if OrionLib.Flags.chatNotifyEntities.Value then chatMessage("墙居者出现") end
        repeat task.wait() until not inst
        if not OrionLib.Flags.NotifyEntities.Value then return end
        OrionNotify(NotifyMes["entity"], "墙居者消失")
        if OrionLib.Flags.chatNotifyEntities.Value then chatMessage("墙居者消失") end
    end
end)
AddConnection(workspace.ChildAdded,function(child) -- 关于实体
    local childName = string.lower(child.Name)
    if table.find(entityNames, child.Name) and child:IsDescendantOf(workspace) then
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.avoid.Value == false then -- 实体提醒
            OrionNotify(NotifyMes["entity"], child.Name .. "出现")
        end
        if OrionLib.Flags.avoid.Value and childName ~= "mirage" then -- 自动躲避
            createPlatform("AvoidPlatform", Vector3.new(3000, 1, 3000), Vector3.new(5000, 10000, 5000))
            teleportPlayer(Players.LocalPlayer, Platform.Position + Vector3.new(0, Platform.Size.Y / 2 + 5, 0))
            Entitytoavoid[child] = true
            OrionNotify(NotifyMes["entity"], child.Name .. "出现,自动躲避中")
        end
        if OrionLib.Flags.chatNotifyEntities.Value then -- 实体播报
            chatMessage(child.Name .. "出现")
        end
        if OrionLib.Flags.EntityEsp.Value then -- 实体esp
            AddESP({
                inst = child,
                Name = child.Name,
                Color = Color3.new(1, 0, 0),
                value = OrionLib.Flags["EntityEsp"]
            })
        end
        if OrionLib.Flags.nopandemonium.Value and (string.find(childName, "pande") or string.find(childName, "monium")) then -- 删除z367
            task.wait(0.1)
            child:Destroy()
            OrionNotify("Pandemonium", NotifyMes["delete"])
        end
    end
end)
AddConnection(workspace.ChildRemoved,function(child) -- 关于实体
    if table.find(entityNames, child.Name) then
        if OrionLib.Flags.avoid.Value and Entitytoavoid[child] then -- 自动躲避
            teleportBack(Players.LocalPlayer)
            Entitytoavoid[child] = nil 
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.avoid.Value == false then -- 实体提醒
            OrionNotify(NotifyMes["entity"], child.Name .. "消失")
        end
        if OrionLib.Flags.chatNotifyEntities.Value then -- 实体播报
            chatMessage(child.Name .. "消失")
        end
    end 
    if child.Name == "Mirage" then -- Mirage
        if OrionLib.Flags.NotifyEntities.Value then
            OrionNotify(NotifyMes["entity"], "Mirage消失")
        end
        if OrionLib.Flags.chatNotifyEntities.Value then
            chatMessage(child.Name .. "消失")
        end
    end
end)
AddConnection(Players.PlayerAdded,function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        OrionNotify("玩家提醒", player.Name .. Notififriend .. "已加入", 2,false)
    end
    if OrionLib.Flags['PlayerEsp'] then
        AddESP({
            inst = player.Character,
            Name = player.Name,
            Color = Color3.fromRGB(238, 201, 0),
            value = OrionLib.Flags["PlayerEsp"]
        })
    end
end)
AddConnection(Players.PlayerRemoving,function(player)
    if OrionLib.Flags.PlayerNotifications.Value then
        if player:IsFriendsWith(Players.LocalPlayer.UserId) then
            Notififriend = "(好友)"
        else
            Notififriend = ""
        end
        OrionNotify("玩家提醒", player.Name .. Notififriend .. "已退出", 2,false)
    end
end)