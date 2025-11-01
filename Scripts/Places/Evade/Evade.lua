if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))() end
if not ESPLibrary then ESPLibrary = load("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau") end
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
ESPLibrary.GlobalConfig.Rainbow = true

loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-script/Setting.lua'))()

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character
LocalPlayer.CharacterAdded:Connect(function(newchar) char = newchar end)

local VisualEsp,AutoCollectCurrency,AutoZoom,AvoidEntityByAnchor
local Games = workspace.Game
local Tickets = Games.Effects.Tickets
local Spawns = Games.Map.Parts.Spawns
local Zoom = LocalPlayer.PlayerScripts.Camera.FOVAdjusters.Zoom

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

local function AddConnection(signal,func,value)
    pcall(function() 
        value = value or true
        local event = signal:Connect(func)
        repeat task.wait() until not OrionLib:IsRunning() or not value
        event:Disconnect()
    end)
end

local function BackToSpawn()
    pcall(function() char:WaitForChild('HumanoidRootPart').Anchored = false char:PivotTo(Spawns:FindFirstChild('SpawnLocation').CFrame) end)
end

local function AvoidEntityAnchorFunction()
    task.spawn(function() 
        while AvoidEntityByAnchor do
            char:WaitForChild('HumanoidRootPart').Anchored = true
            char:PivotTo(CFrame.new(0,10000,0))
            task.wait(10)
        end
        if not AvoidEntityByAnchor then BackToSpawn() end
    end)
end

local function CollectBread(bread)
    if not char then return end
    print('CollectBread')
    while bread and AutoCollectCurrency do pcall(function()
        if AvoidEntityByAnchor then char:FindFirstChild('HumanoidRootPart').Anchored = false end
        char:PivotTo(bread:FindFirstChild('HumanoidRootPart').CFrame)
    end) task.wait() end
end

Window = OrionLib:MakeWindow({
    IntroText = "Evade",
    Name = "Evade",
    SaveConfig = false
})

Tab = Window:MakeTab({
    Name = "主界面",
    Icon = "rbxassetid://4483345998"
})
Esp = Window:MakeTab({
    Name = "透视",
    Icon = "rbxassetid://4483345998"
})
Tab:AddSlider({
    Name = "缩放",
    Min = 0,
    Max = 1.4,
    Default = 1,
    Increment = 0.1,
    Flag = 'AutoZoom',
    Callback = function(value)
        Zoom.Value = value
    end
})
Tab:AddToggle({
    Name = "自动收集活动货币",
    Default = false,
    Callback = function(value)
        AutoCollectCurrency = value
        if AutoCollectCurrency then
            for _,bread in pairs(Tickets:GetChildren()) do CollectBread(bread) continue end
            AddConnection(Tickets.ChildAdded,function(bread) 
                if AutoCollectCurrency then CollectBread(bread) end
            end,AutoCollectCurrency)
        end
    end
})
Tab:AddToggle({
    Name = "躲避实体(固定传送)",
    Default = false,
    Callback = function(value)
        AvoidEntityByAnchor = value
        if AvoidEntityByAnchor and char then AvoidEntityAnchorFunction() else BackToSpawn() end
    end
})
Esp:AddToggle({
    Name = "活动货币透视",
    Default = true,
    Flag = "VisualEsp",
    Callback = function(value)
        VisualEsp = value
        if VisualEsp then
            for _,visual in pairs(Tickets:GetChildren()) do 
                if visual.Name == 'Visual' then AddESP({inst = visual,value = VisualEsp}) end 
            end
        end
    end
})

AddConnection(Tickets.ChildAdded,function(inst) -- 其他
    if inst.Name ~= 'Visual' then return end
    if VisualEsp then esp(inst,VisualEsp) end
end)

AddConnection(Zoom.Changed,function() Zoom.Value = OrionLib.Flags['AutoZoom'].Value end)

task.spawn(function()
    repeat task.wait() until not OrionLib:IsRunning()
    ESPLibrary:Destroy()
end)