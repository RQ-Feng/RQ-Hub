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
--前期设置
local IsRunning = true
local NeedToStop = false
local stuckTime,stuckTimeLimited = 0,80
local CheckStuckTime = task.spawn(function()
    while IsRunning and stuckTime < stuckTimeLimited do
        task.wait(1)
        stuckTime = stuckTime + 1
        if stuckTime >= stuckTimeLimited then
            for i = 1, 5 do
                game:GetService('TeleportService'):Teleport(12411473842,Players.LocalPlayer)
                task.wait(10)
            end
            warn('Rejoin failed,lol.')
        end
    end
end)

local GameplayFolder = workspace:FindFirstChild('GameplayFolder')
local Rooms = GameplayFolder:FindFirstChild('Rooms')
local Events = ReplicatedStorage.Events 

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local MainGui = LocalPlayer.PlayerGui:WaitForChild('Main')
repeat task.wait() until not MainGui:WaitForChild('Loading').Visible
local AuxItems = MainGui.Health.AuxItems

local entityNames = {"Angler", "RidgeAngler", "Blitz", "RidgeBlitz", "Pinkie", "RidgePinkie", "Froger", "RidgeFroger","Chainsmoker", "Pandemonium", "A60"} -- 实体
local NoPromptDoors = {'LargeRoundDoor'}
local SpecialRooms = {}
local KeyItems = {'NormalKeyCard','RidgeKeyCard','PasswordPaper'}
--RequiresLineOfSight
--Debug
local function Warn(mes)
    warn('[Pressure Auto Crystal Debug]:',mes)
end

--通用
local function DoorIsOpened(Entrance)
    local Root = Entrance:WaitForChild('Root',1)
    local Lock = Entrance:GetAttribute('Locked') and Entrance:WaitForChild('Lock',2)
    if not Entrance or not Root or Entrance:WaitForChild('OpenValue').Value then return true end
    local suc,prompt = pcall(function() return Lock and Lock.Main.ProximityPrompt or Root.ProximityPrompt end)
    if not suc or not prompt.Enabled then return true end
    if Entrance:GetAttribute('OpenedByAutoCrystal') then return true end
    return false
end

local function GetDistance(part1, part2)
    return (part1.Position - part2.Position).Magnitude
end

local function TeleportLookVector(Part,distance)
    distance = distance or 5
    local lookVector = HumanoidRootPart.CFrame.LookVector
    local newPosition = Part.Position - (lookVector * distance)
    local rotation = HumanoidRootPart.CFrame - HumanoidRootPart.CFrame.Position
    HumanoidRootPart.CFrame = CFrame.new(newPosition) * rotation
    task.wait(0.1)
end

local function PromptPart(Part,func,distance)
    --防错误
    if not Part then return end
    func = func or function() end
    distance = distance or -3
    local SetCFTask = task.spawn(function()
        while task.wait() and Part and IsRunning do --循环保持Part在Camera前方
            TeleportLookVector(Part,distance)
        end
    end)
    func()
    task.cancel(SetCFTask)
    task.wait()--等待上一个task停止循环
end

local function InteractPrompt(ProximityPrompt)
    ProximityPrompt.HoldDuration = 0
    ProximityPrompt.RequiresLineOfSight = false
    ProximityPrompt:InputHoldBegin()
    task.wait()
    ProximityPrompt:InputHoldEnd()
end
--开普通门
local function OpenNextDoor()
    for _,room in pairs(Rooms:GetChildren()) do
        if not room:IsA('Model') or NeedToStop then continue end
        if SpecialRooms[room.Name] then 
            Warn(room.Name .. ' 尝试使用特殊Function通过')
            SpecialRooms[room.Name](room); continue 
        end--特殊房间特殊对待
        local Entrances = room:WaitForChild('Entrances',1)
        if not Entrances then continue end
        local Entrance = Entrances:FindFirstChildOfClass('Model')
        --对于双门的特定检测
        Entrance = Entrance and (string.find(Entrance.Name, "DoubleDoor") and Entrance:FindFirstChild('NormalDoor') or Entrance)
        local lastRoom = Entrance and (string.find(Entrance.Parent.Name, "DoubleDoor") and Entrance.Parent:WaitForChild('Exit') or Entrance:WaitForChild('Exit'))
        
        if not Entrance or (DoorIsOpened(Entrance) and not lastRoom.Value:FindFirstChild('TricksterRoom')) or Entrance:GetAttribute('OpenedByAutoCrystal') then continue end -- 检查是否为最新门
        local Root = Entrance:WaitForChild('Root',2); if not Root then continue end
        local Lock = Entrance:GetAttribute('Locked') and Entrance:WaitForChild('Lock',2)

        if table.find(NoPromptDoors,Entrance.Name) then return TeleportLookVector(Root,math.random(6,12)) end

        local suc,prompt = pcall(function() return Lock and Lock.Main.ProximityPrompt or Root.ProximityPrompt end)

        local FinalkeyName,Password

        if Lock then
            for _,key in pairs(Entrance.Exit.Value:GetDescendants()) do
                if table.find(KeyItems,key.Name) then
                    FinalkeyName = key.Name 
                    local ProxyPart = key:WaitForChild('ProxyPart',2)
                    if FinalkeyName == 'PasswordPaper' then 
                        Password = key.Code.SurfaceGui.TextLabel.Text; Warn(room.Name .. ' 密码为 ' .. Password)
                        break
                    else FinalkeyName = 'NormalKeyCard' end

                    PromptPart(ProxyPart,function()--拿道具
                        repeat task.wait()
                            InteractPrompt(ProxyPart.ProximityPrompt)
                        until AuxItems[FinalkeyName].Visible == true
                    end,3)
                    break
                end
            end
        end

        if not Lock then 
            while not DoorIsOpened(Entrance) and task.wait(0.1) do TeleportLookVector(Root,math.random(6,12)) end
        else 
            PromptPart(Root,function()
                while prompt.Enabled and task.wait() do 
                    if FinalkeyName == 'PasswordPaper' then prompt.Parent.RemoteFunction:InvokeServer(Password)
                    else InteractPrompt(prompt) end
                end
            end,5)
        end
        Entrance:SetAttribute('OpenedByAutoCrystal',true)
        stuckTime = 0
    end
end
--修复装置
local function GeneratorFix(Generator)
    if not Generator then return end
    local Fixed = Generator.Fixed
    if Fixed.Value == 100 then return end
    Character:PivotTo(Generator.ProxyPart.CFrame)
    task.wait(0.5)
    Generator.RemoteFunction:InvokeServer('')
    task.wait(0.1)
    repeat task.wait(); Generator.RemoteEvent:FireServer('')
    until Fixed.Value == 100
end

local function FixBossMachine(room)
    if room.Name == 'SearchlightsEncounter' then
        local suc,bigdoor; repeat
            suc,bigdoor = pcall(function() return room.Interactables.EntranceDoor.BigDoor end)
        until suc
        repeat task.wait(1)
            TeleportLookVector(bigdoor:FindFirstChild('Root'),10)
        until bigdoor:FindFirstChild('OpenValue') and bigdoor.OpenValue.Value
        task.wait(15)
        for _,Generator in pairs(room.Interactables:GetChildren()) do
            if Generator.Name ~= 'PresetGenerator' then continue end
            GeneratorFix(Generator)
        end
    end
end
--特殊房间Function设置
SpecialRooms['FirewallStart'] = function(room)
    local Elevator = workspace:FindFirstChild('Elevator')
    if not Elevator then return end
    local Highlight = Elevator.ElevatorKey.Highlight
    local ProximityPrompt = Highlight:FindFirstChild('ProximityPrompt')
    if not ProximityPrompt then return end
    PromptPart(Highlight,function()
        while ProximityPrompt.Parent and task.wait() do InteractPrompt(ProximityPrompt) end
    end,4)
end
SpecialRooms['FirewallElevator'] = function(room)
    local ChaseRooms = room:FindFirstChild('ChaseRooms')
    local OpenedDoors = 0
    for _,chaseRoom in pairs(ChaseRooms:GetChildren()) do
        if string.find(chaseRoom.Name,'FirewallTutorialStart') then continue end
        OpenedDoors = OpenedDoors + 1
        local Entrance = chaseRoom.Entrances.SpawningBlock:FindFirstChildOfClass('Model')
        while not Entrance.OpenValue.Value and not Entrance:GetAttribute('OpenedByAutoCrystal') and task.wait(0.1) do TeleportLookVector(Entrance:WaitForChild('RootPart',1),math.random(2,6)) end
        Entrance:SetAttribute('OpenedByAutoCrystal',true)
    end
    if OpenedDoors == 0 then
        local End = Rooms:FindFirstChild('FirewallEnd')
        local door = End.Entrances:FindFirstChild('LargeRoundDoor')
        while not door.OpenValue.Value and not door:GetAttribute('OpenedByAutoCrystal') and task.wait(0.1) do TeleportLookVector(door:WaitForChild('RootPart',1),math.random(2,6)) end
        door:SetAttribute('OpenedByAutoCrystal',true)
    end
end
SpecialRooms['SearchlightsTramStart'] = function(room)
    GeneratorFix(room:WaitForChild('Interactables'):WaitForChild('PresetGenerator'))
end
SpecialRooms['SearchlightsTramEnd'] = function(room)
    local door = room:WaitForChild('Entrances'):WaitForChild('LargeRoundDoor')
    while not door.OpenValue.Value and not door:GetAttribute('OpenedByAutoCrystal') and task.wait(0.1) do TeleportLookVector(door:WaitForChild('RootPart',1),math.random(6,12)) end
    door:SetAttribute('OpenedByAutoCrystal',true)
end
SpecialRooms['SearchlightsEncounter'] = function(room)
    FixBossMachine(room)
end
--最终运行设置
local RoomsAdded;RoomsAdded = Rooms.ChildAdded:Connect(function(room)
    local Name = room.Name
    if Name == 'PipeBoardPuzzle1' then
        Warn('L Room,play again.')
        Events.PlayAgain:FireServer()
    elseif Name == 'SearchlightsEncounter' then
        local suc,bigdoor; repeat
            suc,bigdoor = pcall(function() return room.Interactables.EntranceDoor.BigDoor end)
        until suc
        repeat task.wait() until bigdoor:FindFirstChild('OpenValue') and bigdoor.OpenValue.Value
        task.wait(15)
        for _,Generator in pairs(room.Interactables:GetChildren()) do
            if Generator.Name ~= 'PresetGenerator' then continue end
            GeneratorFix(Generator)
        end
    elseif Name == 'SearchlightsEnding' then
        --room.Triggers.Lever1.Highlight
    end
end)
--运行Task
local RunTask = task.spawn(function()
    while IsRunning and task.wait() do 
        workspace.Camera.FieldOfView = 120
        if NeedToStop then coroutine.yield() end
        OpenNextDoor() 
    end
end)

local EntityDetector = workspace.ChildAdded:Connect(function(entity) -- 关于实体
    if table.find(entityNames, entity.Name) then
        Warn('检测到'..entity.Name)
        if entity.Name == "Pandemonium" then -- 删除z367
            task.wait(0.1)
            entity:Destroy()
            return
        end
        repeat task.wait() until GetDistance(entity, HumanoidRootPart) <= 80 or not entity or not IsRunning
        if not entity or not IsRunning then return end
        NeedToStop = true
        local OldCF = HumanoidRootPart.CFrame
        repeat HumanoidRootPart.CFrame = CFrame.new(0,10000,0); task.wait(1) until not entity.Parent or not IsRunning
        NeedToStop = false
        HumanoidRootPart.CFrame = OldCF
        if RunTask then coroutine.resume(RunTask) end
    end
end)
--删除Eyefestation
local EyefestationInsts = {'Eyefestation','EnragedEyefestation','EyefestationGaze','EnragedEyefestation'}
local EyefestationDeleter = workspace.DescendantAdded:Connect(function(inst) -- 其他
    if table.find(EyefestationInsts,inst.Name) then inst:Destroy() end
end)

local BF = Instance.new('BindableFunction')
BF.OnInvoke = function() 
    task.cancel(RunTask)
    task.cancel(CheckStuckTime)
    EntityDetector:Disconnect()
    EyefestationDeleter:Disconnect()
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