--Services
local StarterGui = game:GetService('StarterGui')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--检测重进
if game.PlaceId == 12411473842 then 
    local Event = ReplicatedStorage.Events.CreateLobby
    Event:InvokeServer(
        {
            LobbyAccess = "Public",
            LobbySize = 1,
            Gamemode = "Blacksite"
        }
    )
    StarterGui:SetCore('SendNotification',{
        Title = 'Pressure Auto Crystal',
        Text = '自动重进中',
        Duration = math.huge,
        Button1 = '好'
    }); return
end

local IsRunning = true

local GameplayFolder = workspace:FindFirstChild('GameplayFolder')
local Rooms = GameplayFolder:FindFirstChild('Rooms')
local Events = ReplicatedStorage.Events 
--.PlayAgain:FireServer()

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local AuxItems = LocalPlayer.PlayerGui.Main.Health.AuxItems

local PromptingParts = {}
local KeyItems = {'NormalKeyCard','RidgeKeyCard','PasswordPaper'}
--RequiresLineOfSight
--Debug
local function Warn(mes)
    warn('[Pressure Auto Crystal Debug]:',mes)
end

--通用
local function PromptPart(Part,func,distance)
    --防错误
    if not Part then return end
    func = func or function() end
    distance = distance or -3
    local SetCFTask = task.spawn(function()
        while task.wait() and Part and IsRunning do --循环保持Part在Camera前方
            local lookVector = HumanoidRootPart.CFrame.LookVector
            local newPosition = Part.Position - (lookVector * distance)
            local rotation = HumanoidRootPart.CFrame - HumanoidRootPart.CFrame.Position
            HumanoidRootPart.CFrame = CFrame.new(newPosition) * rotation
        end
    end)
    func()
    task.cancel(SetCFTask)
    task.wait()--等待上一个task停止循环
end
--开普通门
local function OpenNextDoor()
    for _,room in pairs(Rooms:GetChildren()) do
        if not room:IsA('Model') then continue end
        local Entrances = room:WaitForChild('Entrances')
        local Entrance = Entrances:FindFirstChildOfClass('Model')
        if not Entrance then continue end
        local Root = Entrance:WaitForChild('Root',2); if not Root then continue end
        local Lock = Entrance:GetAttribute('Locked') and Entrance:WaitForChild('Lock',2)

        local suc,prompt = pcall(function() return Lock and Lock.Main.ProximityPrompt or Root.ProximityPrompt end)
        if not suc or (not prompt.Enabled and not room.Interactables:FindFirstChild('LockersOnly')) then continue end-- 检查是否为最新门
        prompt.Enabled = true

        local FinalkeyName,Password

        if Lock then
            for _,key in pairs(Entrance.Exit.Value:GetDescendants()) do
                if table.find(KeyItems,key.Name) then
                    FinalkeyName = key.Name 
                    local ProxyPart = key:WaitForChild('ProxyPart')
                    if FinalkeyName == 'PasswordPaper' then 
                        Password = key.Code.SurfaceGui.TextLabel.Text; Warn(room.Name .. ' 密码为 ' .. Password)
                        break
                    else FinalkeyName = 'NormalKeyCard' end

                    PromptPart(ProxyPart,function()--拿道具
                        repeat task.wait() 
                            ProxyPart.ProximityPrompt.RequiresLineOfSight = false
                            ProxyPart.ProximityPrompt:InputHoldBegin()
                        until AuxItems[FinalkeyName].Visible == true
                    end,3)
                    break
                end
            end
        end

        if not Lock then 
            local lookVector = HumanoidRootPart.CFrame.LookVector
            local newPosition = Root.Position - (lookVector * math.random(6,12))
            local rotation = HumanoidRootPart.CFrame - HumanoidRootPart.CFrame.Position
            HumanoidRootPart.CFrame = CFrame.new(newPosition) * rotation
            task.wait(0.1)
        else 
            PromptPart(Root,function()
                while prompt.Enabled and task.wait() do 
                    if FinalkeyName == 'PasswordPaper' then prompt.Parent.RemoteFunction:InvokeServer(Password)
                    else prompt:InputHoldBegin() end
                end
            end,5)
        end
        Warn('一次'.. room.Name ..'尝试开门回合已完成')
    end
end
--修复装置
local function GeneratorFix(Generator)
    local Fixed = Generator.Fixed
    if Fixed.Value == 100 then return end
    Character:PivotTo(Generator.ProxyPart.CFrame)
    task.wait(0.5)
    Generator.RemoteFunction:InvokeServer('')
    task.wait(0.1)
    repeat task.wait(); Generator.RemoteEvent:FireServer('')
    until Fixed.Value == 100
end

local function FixBossMachine()
    --if Rooms:FindFirstChild('SearchlightsEncounter')
end
--最终运行设置
local Running = true
local RoomsAdded;RoomsAdded = Rooms.ChildAdded:Connect(function(room)
    if room.Name == 'SearchlightsEncounter' then
        local suc,bigdoor; repeat
            suc,bigdoor = pcall(function() return room.Interactables.EntranceDoor.BigDoor end)
        until suc
        repeat task.wait() until bigdoor:FindFirstChild('OpenValue') and bigdoor.OpenValue.Value
        task.spawn(15)
        for _,Generator in pairs(room.Interactables:GetChildren()) do
            if Generator.Name ~= 'PresetGenerator' then continue end
            GeneratorFix(Generator)
        end
    elseif room.Name == 'SearchlightsEnding' then
        --room.Triggers.Lever1.Highlight
    end
end)
local RunTask = task.spawn(function()
    while Running and task.wait() do OpenNextDoor() end
end)

local BF = Instance.new('BindableFunction')
BF.OnInvoke = function() 
    task.cancel(RunTask)
    RoomsAdded:Disconnect()
    IsRunning = false
    HumanoidRootPart.Anchored = false
end
StarterGui:SetCore('SendNotification',{
    Title = 'Pressure Auto Crystal',
    Text = '点击按钮以停止',
    Duration = math.huge,
    Button1 = '停止',
    Callback = BF
})