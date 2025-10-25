if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))() end--lib
OrionLib:MakeNotification({
    Name = "加载中...",
    Content = "可能会有短暂卡顿",
    Image = "rbxassetid://4483345998",
    Time = 4
})
Window = OrionLib:MakeWindow({
    IntroText = "Rooms",
    Name = "Rooms",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Cfg/Rooms"
})
-- local设置
local a60 = workspace:WaitForChild("monster")
local a120 = workspace:WaitForChild("monster2")
--local结束->Function设置
local function Notify(name,content,Sound,SoundId) -- 信息
    OrionLib:MakeNotification({
        Name = name,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = 3,
        Sound = Sound,
        SoundId = SoundId
    })
end
local function entityNotifi(entityname) -- 实体提醒
    Notify("实体提醒", entityname)
end
local function espobj(obj,name,color3) -- Esp
    bill = Instance.new("BillboardGui",obj) -- 创建BillboardGui
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 100, 0, 50)
    bill.Adornee = obj
    bill.MaxDistance = inf
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
    txt.TextColor3 = color
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Position = UDim2.new(0.5, 0, 0.7, 0)
    txt.Text = name
    Instance.new("UIStroke", txt)
    
    hl = Instance.new("Highlight",obj)
    hl.Name = name .. "透视高光"
    hl.Adornee = obj
    hl.DepthMode = "AlwaysOnTop"
    hl.FillColor = color
    hl.FillTransparency = "0.6"
end
function teleportPlayerTo(player,toPositionVector3,saveposition) -- 传送玩家-Vector3.new(x,y,z)
    if player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(toPositionVector3)
    end
end
--Function结束-其他
Notify("加载完成", "已成功加载")
--Tab界面
Tab = Window:MakeTab({
    Name = "主界面",
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
local NotifyEntities
Tab:AddToggle({
    Name = "实体移动提醒",
    Default = true,
    Callback = function(value)
        NotifyEntities = value
        if NotifyEntities == true then
           local a60oldpos,a60newpos = a60.Position,a60.Position
           local a120oldpos,a120newpos = a120.Position,a120.Position
           local a60detect,a120detect = false,false
           while OrionLib:IsRunning() and NotifyEntities do
                a60newpos = a60.Position
                a120newpos = a120.Position

                if a60newpos ~= a60oldpos then
                    Notify("实体提醒","a60开始移动")
                    a60detect = true
                elseif a60newpos == a60oldpos and a120detect == true then
                    Notify("实体提醒","a60停止移动")
                    a60detect = false
                end

                if a120newpos ~= a120oldpos then
                    Notify("实体提醒","a120开始移动")
                    a120detect = true
                elseif a120newpos == a120oldpos and a120detect == true then
                    Notify("实体提醒","a120停止移动")
                    a120detect = false
                end
                
                task.wait()
            end
        end
    end,
    Save = true
})
Section = Tab:AddSection({
    Name = "交互"
})
Tab:AddToggle({ -- 轻松交互
    Name = "无限交互距离",
    Default = true,
    Flag = "InfInteract",
    Save = true
})
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
Esp:AddToggle({ -- door
    Name = "门透视",
    Default = true,
    Flag = "DoorsEsp",
    Save = true
})
Esp:AddToggle({ -- locker
    Name = "柜子透视",
    Default = true,
    Flag = "LockerEsp",
    Save = true
})
Esp:AddToggle({ -- 物品
    Name = "电池透视",
    Default = true,
    Flag = "BatteryEsp",
    Save = true
})
Esp:AddToggle({ -- 实体
    Name = "实体透视",
    Default = true,
    Callback = function(Value)

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
    Name = "删除此窗口",
    Callback = function()
        OrionLib:Destroy()
    end
})
loadstring(game:HttpGet('https://raw.githubusercontent.com/C-Feng-dev/My-own-Script/refs/heads/main/Script/Tabs/OrionGui-About.lua'))()
workspaceDA = workspace.DescendantAdded:Connect(function(inst) -- 其他
    if inst:IsA("ClickDetector") and OrionLib.Flags.InfInteract.Value then -- 无限交互距离
        inst.MaxActivationDistance = inf
    end
end)