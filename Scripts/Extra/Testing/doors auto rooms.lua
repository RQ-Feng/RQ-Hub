local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService('Players')
local StarterGui = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")

local function Notify(Text,Duration,ButtonsCfg)
    local cfgTable = {
        Title = 'Doors auto rooms',
        Text = Text,
        Duration = Duration or 5
	}

    if ButtonsCfg then
        if type(ButtonsCfg) ~= 'table' then return end
        cfgTable['Callback'] = Instance.new('BindableFunction')        
		cfgTable['Button1'] = ButtonsCfg['Button1']
		cfgTable['Button2'] = ButtonsCfg['Button2']
		if type(ButtonsCfg['Callback']) ~= 'function' then return end
		cfgTable['Callback'].OnInvoke = (ButtonsCfg['Callback'])
    end
			
    StarterGui:SetCore('SendNotification',cfgTable)
end

if game.PlaceId ~= 6839171747 or ReplicatedStorage.GameData.Floor.Value ~= "Rooms" then Notify('Incorrect Place'); return end

local executor = identifyexecutor and tostring(identifyexecutor())
local executor_BlackList = {
    ['Xeno'] = {'fireproximityprompt'}
}

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character.HumanoidRootPart
local MainUI = LocalPlayer.PlayerGui.MainUI
local Main_Game = MainUI.Initiator.Main_Game
local Stardusts,GoldPiles = {},{}
local ChoseLocker,ChoseDoor
local isStuck = false
local IsRunning = true

local function LatestRoom()
    return ReplicatedStorage.GameData.LatestRoom.Value
end

local function CurrentRoom()
    return workspace.CurrentRooms[LatestRoom()]
end

local function CurrentDoor()
    return CurrentRoom():FindFirstChild('Door')
end

local function GoldPicked()
    return ReplicatedStorage.GameStats:FindFirstChild('Player_'..LocalPlayer.Name).Total.GoldPicked.Value
end

local function DistanceFromFloor(Part)
    if not Part:IsA('BasePart') then return end

    local NoCharRaycastParam = RaycastParams.new()
    NoCharRaycastParam.FilterType = Enum.RaycastFilterType.Exclude
    NoCharRaycastParam.FilterDescendantsInstances = {Character}
    
    local raycast = workspace:Raycast(Part.Position,Vector3.new(Part.Position.X,-1000,Part.Position.Z), NoCharRaycastParam)
    if not raycast then return end
    return Part.Position - Vector3.new(0,raycast.Distance, 0)
end

local function GetEntity()
    return workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
end

local function InteractPrompt(Path,prompt)
    if typeof(Path) ~= 'Instance' or not Path:IsA("BasePart") then warn("[InteractPrompt]:BasePart expected, got " .. Path.ClassName); return end
    if typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then warn("[InteractPrompt]:ProximityPrompt expected, got " .. typeof(prompt)); return end

    if (HumanoidRootPart.Position - Path.Position).Magnitude > 18 then return end

    if not table.find(executor_BlackList[executor],'fireproximityprompt') then --no need to use fallback firepp
        fireproximityprompt(prompt); return 
    end

    Main_Game.Camera.Enabled = false
    workspace.CurrentCamera.FieldOfView = 120
    workspace.CurrentCamera.CFrame = CFrame.lookAt(HumanoidRootPart.Position,Path.Position)
    prompt.Enabled = true
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12

    prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
end

local function GetLoot(Loot)--Need to teleport manually
    warn('[GetLoot] got signal.Loot:'..tostring(Loot))
    local loots = {'GoldPile','StardustPickup'}
    if not Loot or not table.find(loots,Loot.Name) then return end
    local path = Loot.Name == 'GoldPile' and Loot:FindFirstChild('Hitbox') or Loot:FindFirstChild('Main')
    local prompt = Loot.Name == 'GoldPile' and Loot:FindFirstChild('LootPrompt') or Loot:FindFirstChild('ModulePrompt')
    local LootTable = Loot.Name == 'GoldPile' and GoldPiles or Stardusts

    local timeout = 10

    task.spawn(function() 
        repeat task.wait(1); timeout = timeout - 1 until timeout <= 0 
    end)

    repeat InteractPrompt(path,prompt); warn('[GetLoot] Interacting:'..tostring(prompt)); task.wait() until
    not Loot or not Loot.Parent or not path or not prompt or timeout < 0
    if table.find(LootTable,Loot) then table.remove(LootTable,table.find(LootTable,Loot)) end
    Main_Game.Camera.Enabled = true
end

local function IsHiding()
    return Character:GetAttribute('Hiding')
end

local function getLocker()
    local Closest

    local function CheckLocker(locker)
        if not locker:FindFirstChild("Door") or locker:FindFirstChild("HiddenPlayer").Value then return end
        if locker.Door.Position.Y <= -3 then return end-- Prevents going to the lower lockers in the room with the bridge 
        if not Closest then Closest = locker.Door
        elseif (HumanoidRootPart.Position - locker.Door.Position).Magnitude < (Closest.Position - HumanoidRootPart.Position).Magnitude then 
            Closest = locker.Door
        end
    end
    
    for _,locker in pairs(workspace.CurrentRooms:GetDescendants()) do
        if not locker or not locker.Parent then continue end
        if locker.Name ~= "Rooms_Locker" then continue end
        CheckLocker(locker)
    end
    
    return Closest
end

local function getPath()
    local Path
    if GetEntity() and GetEntity().Main.Position.Y > -4 then Path = getLocker()
    elseif Stardusts[1] and not isStuck then Path = Stardusts[1].PrimaryPart
    elseif GoldPiles[1] and not isStuck then Path = GoldPiles[1].PrimaryPart
    else Path = CurrentDoor().Door end
    return Path
end

local function antiafk()
    if getconnections then
        for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
            if connection["Disable"] then connection["Disable"](connection)
            elseif connection["Disconnect"] then connection["Disconnect"](connection) end
        end
    else
        local VirtualUser = game:GetService('VirtualUser')
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = ScreenGui

TextLabel.Size = UDim2.new(0,350,0,100)
TextLabel.TextSize = 48
TextLabel.TextStrokeColor3 = Color3.new(1,1,1)
TextLabel.TextStrokeTransparency = 0
TextLabel.BackgroundTransparency = 1

antiafk()

if workspace:FindFirstChild('PathFindPartsFolder') then workspace.PathFindPartsFolder:Destroy() end
local Folder = Instance.new("Folder")
Folder.Parent = workspace
Folder.Name = "PathFindPartsFolder"

if Main_Game.RemoteListener.Modules:FindFirstChild("A90") then
   Main_Game.RemoteListener.Modules.A90.Name = "lol" -- Fuck you A90
end

Main_Game.Movement.Enabled = false

local RenderStepped = game:GetService("RunService").RenderStepped:Connect(function()
    HumanoidRootPart.CanCollide = false
    Character.Collision.CanCollide = false
    Character.Humanoid.AutoRotate = true
    Character.Humanoid.WalkSpeed = 21

    local Path = getPath()
    if not Path then return end
    
    if GetEntity() then
        if Path.Parent.Name ~= "Rooms_Locker" or GetEntity().Main.Position.Y <= -4 then return end

        if (LocalPlayer.Character.HumanoidRootPart.Position - Path.Position).Magnitude < 12 then
            if LocalPlayer.Character.HumanoidRootPart.Anchored == false then
                InteractPrompt(Path,Path.Parent.HidePrompt)
            end
        end

        if GetEntity().Main.Position.Y < -4 and IsHiding() then
            ReplicatedStorage.RemotesFolder.CamLock:FireServer()
            Main_Game.Camera.Enabled = true
        end
    elseif IsHiding() then ReplicatedStorage.RemotesFolder.CamLock:FireServer()
    elseif Stardusts[1] then GetLoot(Stardusts[1])
    elseif GoldPiles[1] then GetLoot(GoldPiles[1])
    end
end)

local ChildAdded = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    if not room:IsA('Model') then return end
    if CurrentRoom().Name == tostring(tonumber(room.Name) - 1) then return end

    for _,inst in pairs(CurrentRoom():GetDescendants()) do
        if inst.Name == 'GoldPile' and GoldPicked() < 10000 then table.insert(GoldPiles,inst)
        elseif inst.Name == 'StardustPickup' then table.insert(Stardusts,inst)
        end
    end
end)

task.spawn(function()
    ReplicatedStorage.RemotesFolder.PlayerDied.OnClientEvent:Once(function()
        warn('Auto stop running.')
        RenderStepped:Disconnect()
        ChildAdded:Disconnect()
        Folder:Destroy()
        IsRunning = false
    end)
end)

while true and IsRunning do
    local Destination = getPath()
    local path = PathfindingService:CreatePath({ WaypointSpacing = 5, AgentRadius = 1.2, AgentCanJump = false })
    path:ComputeAsync(DistanceFromFloor(HumanoidRootPart),DistanceFromFloor(Destination))
    local Waypoints = path:GetWaypoints()

    if path.Status == Enum.PathStatus.NoPath then 
        warn('NoPath error!Fallback using.')
        Character.Humanoid:MoveTo(getPath().Position)
        Character.Humanoid.MoveToFinished:Wait()
        task.wait(); continue
    end

    Folder:ClearAllChildren()

    for _, Waypoint in ipairs(Waypoints) do
        local part = Instance.new("Part")
        part.Size = Vector3.new(1,1,1)
        part.Position = Waypoint.Position
        part.Shape = "Cylinder"
        part.Rotation = Vector3.new(0,0,90)
        part.Material = "SmoothPlastic"
        part.Anchored = true
        part.CanCollide = false
        part.Parent = Folder
    end

    repeat task.wait() until not HumanoidRootPart.Anchored

    for _, Waypoint in ipairs(Waypoints) do
        Character.Humanoid:MoveTo(Waypoint.Position)
        local suc = Character.Humanoid.MoveToFinished:Wait()
        if not suc then task.wait(); break end
        CurrentDoor().ClientOpen:FireServer()
    end
end