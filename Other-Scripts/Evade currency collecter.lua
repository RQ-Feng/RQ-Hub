OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))()
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
ESPLibrary.GlobalConfig.Rainbow = true
OrionLib:MakeNotification({
    Name = "加载中",
    Content = "请稍等...",
    Time = 5
})
loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-script/Setting.lua'))()

local Tickets = workspace.Game.Effects.Tickets
local VisualEsp
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

local function CollectCurrency(str)
    game:GetService("ReplicatedStorage").Events.Collectibles.Invoke:InvokeServer(
        game:GetService("Players").LocalPlayer,str,"Collect"
    )
end

local function esp(inst,v)
    local ESPElement = ESPLibrary:Add({
        Name = inst.Name,
        Model = inst,
        MaxDistance = 1000,
        TextSize = 17,
        ESPType = "Highlight"
    })
    repeat task.wait() until not v
    ESPElement:Destroy()
end

local function AddConnection(signal,func)
    local event = signal:Connect(func)
    repeat task.wait() until not OrionLib:IsRunning()
    event:Disconnect()
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
Esp:AddToggle({
    Name = "自动收集活动货币",
    Default = true,
    Flag = "AutoCollectCurrency",
    Callback = function()
        -- local collect = require(game:GetService("ReplicatedStorage").Modules.Client.Loader.CollectablesController.CollectableClientContext.CollectableClient)
        -- local signal = require(game:GetService("ReplicatedStorage").Modules.Generics.Signal)

        -- local oldfunc = hookfunction(collect.new,function(cc, id, cd)
        --     v8 = {
        --         ["CollectableData"] = cd,
        --         ["ID"] = id,
        --         ["CollectableContext"] = cc,
        --         ["Properties"] = {},
        --         ["EnforcedProperties"] = {},
        --         ["PropertyAdded"] = signal.new(),
        --         ["PropertyRemoved"] = signal.new()
        --     }
        --     task.spawn(function() 
        --         while v8.ID and (not getfenv().StopHook) do
        --             game:GetService("ReplicatedStorage").Events.Collectibles.Invoke:InvokeServer(game:GetService("Players").LocalPlayer,v8.ID,"Collect")
        --         end
        --     end)
        --     local v9 = collect
        --     return setmetatable(v8, v9)
        -- end)
        -- repeat wait() until getfenv().StopHook
        -- getfenv().StopHook = nil
        -- hookfunction(collect.new,oldfunc)
    end
})
Tab:AddSlider({
    Name = "缩放",
    Min = 0,
    Max = 1.4,
    Default = 1,
    Increment = 0.1,
    Callback = function(Value)
        game:GetService("Players").LocalPlayer.PlayerScripts.Camera.FOVAdjusters.Zoom.Value = Value
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
                if visual.Name ~= 'Visual' then return end
                esp(visual,VisualEsp)
            end
        end
    end
})

AddConnection(Tickets.ChildAdded,function(inst) -- 其他
    if inst.Name ~= 'Visual' then return end
    if VisualEsp then esp(inst,VisualEsp) end
end)

task.spawn(function()
    repeat task.wait() until not OrionLib:IsRunning()
    ESPLibrary:Destroy()
end)