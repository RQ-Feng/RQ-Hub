-- local设置
local EspConnects = {}
local playerPositions = {}
local doors = {"CryptDoor","GraveyardGate"}
local ezinst,autoinst -- 功能开关
local humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
local Espboxes = Players.LocalPlayer.PlayerGui
local RemoteFolder = ReplicatedStorage.Events -- Remote Event储存区之一
--local结束->Function设置
local function delNotifi(delthings) -- 删除信息
    OrionNotify(delthings, "已成功删除")
end
local function entityNotifi(entityname) -- 实体提醒
    OrionNotify("实体提醒", entityname)
end
local function copyitems(copyitem) -- 复制物品
    local create_NumberValue = Instance.new("NumberValue") -- copy items-type NumberValue
    create_NumberValue.Name = copyitem
    create_NumberValue.Parent = game.Players.LocalPlayer.PlayerFolder.Inventory
end
-- #sym:ESPLibrary
local function teleportPlayer(player,toPositionVector3)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        playerPositions[player.UserId] = player.Character.HumanoidRootPart.CFrame
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
--Function结束-其他
OrionNotify("加载完成", "已成功加载")
--Tab界面
local Tab = Window:MakeTab({
    Name = "主界面",
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
local Section = Tab:AddSection({
    Name = "实体"
})
Tab:AddToggle({
    Name = "实体提醒",
    Save = true,
    Default = true,
    Flag = "NotifyEntities",
})
Tab:AddSection({
    Name = "交互"
})
Tab:AddToggle({ -- 轻松交互
    Name = "轻松交互",
    Save = true,
    Default = true,
    Callback = function(Value)
        if Value == false then
            ezinst = false
            return
        end
        ezinst = true
        task.spawn(function()
            while ezinst and OrionLib:IsRunning() do
                for _, toezInteract in pairs(workspace:GetDescendants()) do
                    if toezInteract:IsA("ProximityPrompt") then
                        toezInteract.HoldDuration = "0.01"
                        toezInteract.RequiresLineOfSight = false
                        toezInteract.MaxActivationDistance = "11.5"
                    end
                end
                task.wait(0.1)
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
                    if proximity:IsA("ProximityPrompt") then
                        proximity:InputHoldBegin()
                    end
                end
                task.wait(0.05)
            end
        end)
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
})
Tab:AddToggle({ -- 高亮
    Name = "高亮(低质量)",
    Save = true,
    Default = true,
    Flag = "FullBrightLite",
})
Tab:AddSection({
    Name = "其他"
})
Tab:AddButton({ --传送门
    Name = "传送到下一扇门",
    Callback = function()
        for _, notopendoor in pairs(workspace:GetDescendants()) do
            if table.find(doors, notopendoor.Name) and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                teleportPlayer(Players.LocalPlayer, notopendoor.Root.Position + Vector3.new(0,5,0))
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
                    for _, notopendoor in pairs(workspace.Rooms:GetDescendants()) do
                        if table.find(doors, notopendoor.Name) and notopendoor.Parent.Name == "Entrances" and notopendoor.OpenValue.Value == false then
                            doors = {}
                            Exit = notopendoor.Exit.Value
                            for _, RoomsName in pairs(workspace.Rooms:GetChildren()) do
                                table.insert(Rooms,RoomsName.Name)
                            end
                            if not table.find(Rooms,Exit) then
                                Rooms = nil
                                Exit = nil
                                return
                            end
                            teleportPlayer(Players.LocalPlayer,notopendoor.Root.Position + Vector3.new(0,5,0))
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
        OrionNotify("再来一局","请稍等...")
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
    Default = true,
    Flag = "PlayerNotifications"
})
Del:AddButton({
    Name = "删除降雨效果",
    Callback = function()
        workspace.PlayerRain:Destroy()        
    end
})
Del:AddToggle({
    Name = "删除z564",
    Save = true,
    Default = true,
    Flag = "noBouncer",
})
Del:AddToggle({
    Name = "删除z565",
    Save = true,
    Default = true,
    Flag = "noSkeletonHead",
})
Del:AddToggle({
    Name = "删除z566",
    Save = true,
    Default = true,
    Flag = "noStatueRoot",
})
Del:AddToggle({
    Name = "删除骷髅舞者",
    Save = true,
    Default = true,
    Flag = "noSkeletonDancer",
})
Del:AddToggle({
    Name = "删除自然灾害",
    Save = true,
    Default = true,
    Flag = "nodamage",
})
Esp:AddToggle({ -- door
    Name = "门透视",
    Save = true,
    Default = true,
    Flag = "DoorEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent.Name == "Entrances" then
                    if themodel.Name == "CryptDoor" then AddESP({inst = themodel, Name = "门", Color = Color3.new(0,1,0), value = OrionLib.Flags["DoorEsp"]})
                    elseif themodel.Name == "GraveyardGate" then AddESP({inst = themodel, Name = "大门", Color = Color3.new(0,1,0), value = OrionLib.Flags["DoorEsp"]})
                    end
                end
            end
            AddConnection(workspace.DescendantAdded,function(themodel)
                if themodel:IsA("Model") and themodel.Parent.Name == "Entrances" then
                    if themodel.Name == "CryptDoor" then AddESP({inst = themodel, Name = "门", Color = Color3.new(0,1,0), value = OrionLib.Flags["DoorEsp"]})
                    elseif themodel.Name == "GraveyardGate" then AddESP({inst = themodel, Name = "大门", Color = Color3.new(0,1,0), value = OrionLib.Flags["DoorEsp"]})
                    end
                end
            end,OrionLib.Flags["DoorEsp"])
        end
    end
})
Esp:AddToggle({ -- 钱
    Name = "钱透视(待做)",
    Save = true,
    Default = true,
    Flag = "MoneyEsp",
    Callback = function(Value)
        if Value then
            for _, themodel in pairs(workspace:GetDescendants()) do
                if themodel:IsA("Model") and themodel.Parent ~= Players then
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
                if themodel:IsA("Model") and themodel.Parent ~= Players then
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
        for _, player in pairs(game.Players:GetPlayers()) do
            if Value then
                if player ~= game.Players.LocalPlayer then
                    AddESP({inst = player.Character, Name = player.Name, Color = Color3.new(238, 201, 0), value = OrionLib.Flags['PlayerEsp']})
                end
            end
        end
    end
})
local workspaceDA = AddConnection(workspace.DescendantAdded,function(inst) -- 其他
    if inst.Name == "Bouncer" then -- 无环境伤害
        if OrionLib.Flags.EntityEsp and OrionLib.Flags.EntityEsp.Value then -- 实体esp
            AddESP({inst = inst, Name = inst.Name, Color = Color3.new(1, 0, 0), value = OrionLib.Flags['EntityEsp']})
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.noBouncer.Value == false then
            entityNotifi("z564出现")
        elseif OrionLib.Flags.noBouncer.Value then
            task.wait(0.1)
            inst:Destroy()
            delNotifi("z564")
        end
    end
    if inst.Name == "SkeletonHead" then
        if OrionLib.Flags.EntityEsp and OrionLib.Flags.EntityEsp.Value then -- 实体esp
            AddESP({inst = inst, Name = inst.Name, Color = Color3.new(1, 0, 0), value = OrionLib.Flags['EntityEsp']})
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.noSkeletonHead.Value == false then
            entityNotifi("z565出现")
        elseif OrionLib.Flags.noSkeletonHead.Value then
            task.wait(0.1)
            inst:Destroy()
            delNotifi("z565")
        end
    end
    if inst.Name == "SkeletonTail" and OrionLib.Flags.noSkeletonHead.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "SkelepedeBody" and OrionLib.Flags.noSkeletonHead.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "StatueRoot" then
        if OrionLib.Flags.EntityEsp and OrionLib.Flags.EntityEsp.Value then -- 实体esp
            AddESP({inst = inst, Name = inst.Name, Color = Color3.new(1, 0, 0), value = OrionLib.Flags['EntityEsp']})
        end
        if OrionLib.Flags.NotifyEntities.Value and OrionLib.Flags.noStatueRoot.Value == false then
            entityNotifi("z566出现")
        elseif OrionLib.Flags.noStatueRoot.Value then
            task.wait(0.1)
            inst:Destroy()
            delNotifi("z566")
        end
    end
    if inst.Name == "SkeletonDancer" and OrionLib.Flags.noSkeletonDancer.Value then
        task.wait(0.1)
        inst:Destroy()
    end
    if inst.Name == "DamagePart" and OrionLib.Flags.nodamage.Value then
        task.wait(0.1)
        inst:Destroy()
    end
end)
-- 功能循环
AddConnection(RunService.RenderStepped,function()
    if OrionLib.Flags.keep120fov and OrionLib.Flags.keep120fov.Value and workspace.Camera.FieldOfView ~= 120 then
        workspace.Camera.FieldOfView = 120
    end
    if OrionLib.Flags.FullBrightLite and OrionLib.Flags.FullBrightLite.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    elseif not OrionLib.Flags.FullBrightLite or not OrionLib.Flags.FullBrightLite.Value then
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    end
end)
AddConnection(Players.PlayerAdded,function(player)
    if OrionLib.Flags.PlayerNotifications and OrionLib.Flags.PlayerNotifications.Value then
        local Notififriend = player:IsFriendsWith(Players.LocalPlayer.UserId) and "(好友)" or ""
        OrionNotify("玩家提醒", player.Name .. Notififriend .. "已加入", 2,false)
    end
end)
AddConnection(Players.PlayerRemoving,function(player)
    if OrionLib.Flags.PlayerNotifications and OrionLib.Flags.PlayerNotifications.Value then
        local Notififriend = player:IsFriendsWith(Players.LocalPlayer.UserId) and "(好友)" or ""
        OrionNotify("玩家提醒", player.Name .. Notififriend .. "已退出", 2,false)
    end
end)
