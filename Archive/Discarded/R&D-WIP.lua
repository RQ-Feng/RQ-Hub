local EspConnects = {}
local TeleportService = game:GetService("TeleportService") -- 传送服务
local Players = game:GetService("Players") -- 玩家服务
local Character = Players.LocalPlayer.Character -- 本地玩家Character
local humanoid = Character:FindFirstChild("Humanoid") -- 本地玩家humanoid
local PlayerGui = Players.LocalPlayer.PlayerGui--本地玩家PlayerGui
local function createBilltoesp(theobject,name,color,hlset) -- 创建BillboardGui-颜色:Color3.new(r,g,b)
    local bill = Instance.new("BillboardGui", theobject) -- 创建BillboardGui
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 100, 0, 50)
    bill.Adornee = theobject
    bill.MaxDistance = 2000
    bill.Name = name .. "esp"
    local mid = Instance.new("Frame", bill) -- 创建Frame-圆形
    mid.AnchorPoint = Vector2.new(0.5, 0.5)
    mid.BackgroundColor3 = color
    mid.Size = UDim2.new(0, 8, 0, 8)
    mid.Position = UDim2.new(0.5, 0, 0.5, 0)
    Instance.new("UICorner", mid).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", mid)
    local txt = Instance.new("TextLabel", bill) -- 创建TextLabel-显示
    txt.AnchorPoint = Vector2.new(0.5, 0.5)
    txt.BackgroundTransparency = 1
    txt.TextColor3 =color
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Position = UDim2.new(0.5, 0, 0.7, 0)
    txt.Text = name
    Instance.new("UIStroke", txt)
    if hlset then
        local hl = Instance.new("Highlight",bill)
        hl.Name = name .. "透视高光"
        hl.Parent = PlayerGui
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
    end)
end
local function espmodel(modelname,name,r,g,b,hlset) -- Esp物品(Model对象)用
    for _, themodel in pairs(workspace:GetDescendants()) do
        if themodel:IsA("Model") and themodel.Parent.Name ~= Players and themodel.Name == modelname then
            createBilltoesp(themodel,name, Color3.new(r,g,b),hlset)
        end
    end
    local esp = workspace.DescendantAdded:Connect(function(themodel)
        if themodel:IsA("Model") and themodel.Parent.Name ~= Players and themodel.Name == modelname then
            createBilltoesp(themodel,name, Color3.new(r,g,b),hlset)
        end
    end)
    table.insert(EspConnects,esp)
end
local function esppart(partname,name,r,g,b,hlset)--Esp
    for _, thepart in pairs(workspace:GetDescendants()) do
        if thepart:IsA("Part") and thepart.Parent.Name ~= Players and thepart.Name == modelname then
            createBilltoesp(thepart,name, Color3.new(r,g,b),hlset)
        end
    end
    local esp = workspace.DescendantAdded:Connect(function(thepart)
        if thepart:IsA("Part") and thepart.Parent.Name ~= Players and thepart.Name == modelname then
            createBilltoesp(thepart,name, Color3.new(r,g,b),hlset)
         end
    end)
    table.insert(EspConnects,esp)
end
local function Notify(name,content,time,Sound,Sound) -- 信息
    OrionLib:MakeNotification({
        Name = name,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = time or "3",
        Sound = Sound,
        Sound = Sound
    })
end
local function delNotifi(delthings)--删除信息
    Notify(delthings,"已成功删除")
end
local function entityNotifi(entityname) -- 实体提醒
    Notify("实体提醒", entityname)
end
local function loadfinish() -- 加载完成后向控制台发送
    print("--------------------------加载完成--------------------------")
    print("--Rooms&Doors Script已加载完成")
    print("--欢迎使用!" .. game.Players.LocalPlayer.Name)
    print("--此服务器游戏ID为:" .. game.GameId)
    print("--此服务器位置ID为:" .. game.PlaceId)
    print("--此服务器UUID为:" .. game.JobId)
    print("--此服务器上的游戏版本为:version_" .. game.PlaceVersion)
    print("--------------------------欢迎使用--------------------------")
end
loadfinish()
local Tab = Window:MakeTab({--main
	Name = "主界面",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Tab:AddToggle({
	Name = "实体提醒",
	Default = true,
	Flag = "NotifyEntities",
	Save = true
})
Tab:AddToggle({ -- 保持广角
    Name = "保持广角",
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
	Name = "删除此窗口",
	Default = true,
    Callback = function()
        OrionLib:Destroy()
    end
})
local Del = Window:MakeTab({--main
	Name = "删除",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Del:AddToggle({
	Name = "删除a60",
	Default = true,
	Flag = "noa60",
	Save = true
})
Del:AddToggle({
	Name = "删除a90",
	Default = true,
	Flag = "noa90",
	Save = true
})
local Esp = Window:MakeTab({--main
	Name = "透视",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Esp:AddToggle({
	Name = "门透视",
	Default = true,
    Callback = function()
        esppart("door","门","0","1","0")
    end
})
Esp:AddToggle({
	Name = "柜子透视",
	Default = true,
    Callback = function()
        espmodel("sdgadfasdf","柜子","0","1","0")
    end
})
Esp:AddToggle({
	Name = "a45柜透视",
	Default = true,
    Callback = function()
        espmodel("sdsafagdsa","a45柜","1","0","0")
    end
})
Esp:AddToggle({
	Name = "实体透视",
	Default = true,
    Callback = function()
        esppart("door","门","0","1","0")
    end
})
Esp:AddToggle({
	Name = "电池透视",
	Default = true,
    Callback = function()
        espmodel("battery","电池","0","0","0")
    end
})
Esp:AddToggle({
	Name = "桌子透视",
	Default = true,
    Callback = function()
        espmodel("hidetable","桌子","1","1","0")
    end
})
workspace.ChildAdded:Connect(function(child)
    if child.Name == "monster" and OrionLib.Flags.NotifyEntities.Value then
        task.wait(0.1)
        entityNotifi("a60出现")
    end
    if child.Name == "monster" and OrionLib.Flags.noa60.Value then
        task.wait(0.1)
        child:Destroy()
        delNotifi("a60")
    end
    if child.Name == "remotemonster" and OrionLib.Flags.noa60.Value then
        task.wait(0.1)
        child:Destroy()
    end
end)
workspace.ChildRemoved:Connect(function(child)--实体提醒-消失
    if child.Name == "monster" and OrionLib.Flags.NotifyEntities.Value then
        task.wait(0.1)
        entityNotifi("A60消失")
    end
end)