local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService('Players')
local StarterGui = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")

local RemotesFolder = ReplicatedStorage:FindFirstChild('RemotesFolder')
if not RemotesFolder then
    repeat RemotesFolder = ReplicatedStorage:FindFirstChild('RemotesFolder'); task.wait() until RemotesFolder
end

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

if game.PlaceId == 6516141723 then
    Notify('Rejoining rooms...')
    RemotesFolder:WaitForChild('CreateElevator'):FireServer({
        FriendsOnly = true,
        MaxPlayers = 1,
        Mods = {},
        Destination = 'Rooms',
        Settings = {}
    }); return
end

if game.PlaceId ~= 6839171747 then Notify('Incorrect Place'); return end

local executor = identifyexecutor and tostring(identifyexecutor())
local executor_BlackList = {
    ['Xeno'] = {'fireproximityprompt'}
}

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')

local MainUI = LocalPlayer.PlayerGui:WaitForChild('MainUI')
local Main_Game = MainUI.Initiator.Main_Game
local LatestRoom = ReplicatedStorage.GameData.LatestRoom
local Key_BlackList = {Enum.KeyCode.A,Enum.KeyCode.W,Enum.KeyCode.S,Enum.KeyCode.D}
local loots = {'GoldPile','StardustPickup'}
local CheckPlayerMove,PlayerDied --Stop events
local Stardusts,GoldPiles = {},{}
local Waypoints
local isStuck = false
local IsRunning = true
local FinalCD = 0

if workspace:FindFirstChild('AutoRooms_PathFindPartsFolder') then workspace.AutoRooms_PathFindPartsFolder:Destroy() end
local Folder = Instance.new("Folder")
Folder.Parent = workspace
Folder.Name = "AutoRooms_PathFindPartsFolder"

local function PrefixWarn(message,...)
    if type(message) ~= 'string' then return warn('[PrefixWarn] Expect string,got',type(message)) end
    if ... then for _,str in pairs({...}) do message = message..' '..tostring(str) end end
    return warn('[Auto Rooms] '..message)
end

local function SetCamera(bool)
    local currentState = Main_Game.Camera.Enabled
    Main_Game.Camera.Enabled = bool
    if bool == true and currentState == false and Character:FindFirstChild('Head') and Character.Head:WaitForChild('PointLight',1) then Character.Head.PointLight:Destroy() end
end

local function CurrentRoom()
    return workspace.CurrentRooms[LatestRoom.Value]
end

local function CurrentDoor()
    return CurrentRoom():FindFirstChild('Door')
end

local function GoldPicked()
    return ReplicatedStorage.GameStats:FindFirstChild('Player_'..LocalPlayer.Name).Total.GoldPicked.Value
end

local function DistanceFromFloor(Part)
    if not Part or not Part:IsA('BasePart') then 
        warn('[DistanceFromFloor] Expert BasePart,got',Part and Part.ClassName or 'nil.Using fallback to avoid error...')
        if Part:IsA('Model') then Part = Part.PrimaryPart else return HumanoidRootPart.Position end
    end

    local NoCharRaycastParam = RaycastParams.new()
    NoCharRaycastParam.FilterType = Enum.RaycastFilterType.Exclude
    NoCharRaycastParam.FilterDescendantsInstances = {Character}
    
    local raycast = workspace:Raycast(Part.Position,Vector3.new(Part.Position.X,-1000,Part.Position.Z), NoCharRaycastParam)
    if not raycast then return Part.Position end
    return Part.Position - Vector3.new(0,raycast.Distance,0) or Part.Position
end

local function GetEntity()
    return workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
end

local function InteractPrompt(Path,prompt)
    if typeof(Path) ~= 'Instance' or not Path:IsA("BasePart") then warn("[InteractPrompt]:BasePart expected, got " .. typeof(Path)); return end
    if typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then warn("[InteractPrompt]:ProximityPrompt expected, got " .. typeof(prompt)); return end

    if (HumanoidRootPart.Position - Path.Position).Magnitude > 18 then return end

    if not table.find(executor_BlackList[executor],'fireproximityprompt') then --no need to use fallback firepp
        fireproximityprompt(prompt); return 
    end

    SetCamera(false)
    workspace.CurrentCamera.FieldOfView = 120
    workspace.CurrentCamera.CFrame = CFrame.lookAt(HumanoidRootPart.Position,Path.Position)
    prompt.Enabled = true
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12

    prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
end

local function IsLoot(loot) return loot and table.find(loots,loot.Name) end

local function GetLoot(Loot)--Need to teleport manually
    Loot = Loot:IsA('Model') and Loot or Loot:FindFirstAncestorOfClass('Model')
    if not Loot or not IsLoot(Loot) then return end

    local path = Loot:FindFirstChild('Hitbox') or Loot:FindFirstChild('Main')
    local prompt = Loot:FindFirstChild('LootPrompt') or Loot:FindFirstChild('ModulePrompt')
    local LootTable = Loot.Name == 'StardustPickup' and Stardusts or GoldPiles
    SetCamera(false)

    local timeout = 10

    task.spawn(function() repeat task.wait(1); timeout = timeout - 1 until timeout <= 0  end)

    repeat InteractPrompt(path,prompt); task.wait() until
    not Loot or not Loot.Parent or not path or not prompt or timeout < 0
    
    if table.find(LootTable,Loot) then table.remove(LootTable,table.find(LootTable,Loot)) end

    SetCamera(true)
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
            Closest = locker.Base
        end
    end
    
    for _,locker in pairs(workspace.CurrentRooms:GetDescendants()) do
        if not locker or not locker.Parent then continue end
        if locker.Name ~= "Rooms_Locker" then continue end
        CheckLocker(locker)
    end
    
    return Closest
end

local function getPath(ForceToDoor)
    if ForceToDoor then 
        Stardusts,GoldPiles = {},{}
        return CurrentDoor():WaitForChild('Door') 
    end

    local Path
    if GetEntity() and GetEntity().Main.Position.Y > -4 then Path = getLocker()
    elseif Stardusts[1] and not isStuck then Path = Stardusts[1].PrimaryPart
    elseif GoldPiles[1] and not isStuck then Path = GoldPiles[1].PrimaryPart
    else Path = CurrentDoor():WaitForChild('Door') end
    return Path
end

local function pathFallback(path,Destination,times)
    times = (times and times < 5) and times + 1 or 1
    if not Destination or not Destination.Parent then Destination = getPath() end
    if not IsRunning then return end

    PrefixWarn('Path got',tostring(path.Status)..',using fallback.')
    PrefixWarn('Destination:',Destination)
    PrefixWarn('Destination position:',tostring(Destination.Position:Ceil()))
    
    repeat task.wait() until not IsHiding()

    path:ComputeAsync(HumanoidRootPart.Position,times < 5 and Destination.Position - Vector3.new(0,times,0) or Destination.Position)

    if path.Status == Enum.PathStatus.NoPath then
        if times < 5 then
            Character.Humanoid:MoveTo(Destination.Position); task.wait(2)
            HumanoidRootPart.CFrame = Destination.CFrame; task.wait(0.5)
        else Stardusts,GoldPiles = {},{} end

        repeat task.wait() until not IsHiding()
        return (Destination and Destination.Parent) and pathFallback(path,Destination,times)
    end
    return path:GetWaypoints()
end

local function DisPlayWaypoints(Waypoints)
    for _, Waypoint in ipairs(Waypoints) do
        local part = Instance.new("Part")
        part.Size = Vector3.new(1,1,1)
        part.Position = Waypoint.Position
        part.Shape = "Cylinder"
        part.Color = Color3.new(1,0,0)
        part.Rotation = Vector3.new(0,0,90)
        part.Material = "SmoothPlastic"
        part.Anchored = true
        part.CanCollide = false
        part.Parent = Folder
        Instance.new('Highlight',part)
    end
end

local function gotoPath()
    PrefixWarn('gotoPath is called')
    Waypoints = nil
    local Destination = getPath() or getPath(true)
    PrefixWarn('Destination:',tostring(Destination),tostring(Destination.Parent))
    Folder:ClearAllChildren()

    repeat task.wait() until not IsHiding()
    
    local path = PathfindingService:CreatePath({
        WaypointSpacing = 2,
        AgentHeight = 4,
        AgentRadius = 1.5,
        AgentCanJump = false
    })
    if not Destination then return PrefixWarn('No Destination!') end

    if not Destination:FindFirstChild('PathfindingModifier') then
        Instance.new('PathfindingModifier',Destination).PassThrough = true
    end

    path:ComputeAsync(DistanceFromFloor(HumanoidRootPart),DistanceFromFloor(Destination))
    Waypoints = path:GetWaypoints()
    
    if path.Status == Enum.PathStatus.NoPath then Waypoints = pathFallback(path,Destination) end
    if not Waypoints then return PrefixWarn('No waypoints!') end

    DisPlayWaypoints(Waypoints)
    
    for _, Waypoint in ipairs(Waypoints) do
        if GetEntity() and Destination ~= getLocker() then break end
        repeat task.wait() until not IsHiding()
        
        Character.Humanoid:MoveTo(Waypoint.Position)
        local suc = Character.Humanoid.MoveToFinished:Wait()
        
        CurrentDoor().ClientOpen:FireServer()

        if not suc and not IsHiding() and Destination == getPath() then 
            PrefixWarn('Maybe you\'re stuck,trying again...')
            HumanoidRootPart.CFrame = Destination.CFrame; task.wait(1); break 
        end
    end
end

local function ExitFromLocker()
    RemotesFolder.CamLock:FireServer()
    SetCamera(true)
    repeat task.wait() until not IsHiding()
    gotoPath()
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

local LatestRoomChanged = LatestRoom.Changed:Connect(function(value)
    TextLabel.Text = "Room: "..math.clamp(value, 1,1000)
    FinalCD = 0
    if LatestRoom.Value == 1000 then
        Folder:ClearAllChildren()

        local Sound = Instance.new("Sound")
          Sound.SoundId = "rbxassetid://4590662766"
          Sound.Parent = game:GetService("SoundService")
          Sound.Volume = 5
          Sound:Play()

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "提示";
            Text = "已到达A-1000";
            Icon = "rbxassetid://14250466898";
            Duration = 5;
        })
        return
    end
end)

task.spawn(function() --Fuck u A90
    local A90_RemoteEvent = ReplicatedStorage.RemotesFolder:FindFirstChild("A90")
    if not A90_RemoteEvent then return end
    A90_RemoteEvent:Destroy()
    warn('Stupid A90 GO AWAY')
end)

task.spawn(function() --Fuck u USELESS COLLISION
    local Collision = Character:FindFirstChild('Collision')
    local function NoClip()
        Collision.CollisionGroup = "PlayerCrouching"
        Collision.CollisionCrouch.CollisionGroup = "PlayerCrouching"
        Collision.CanCollide = false
        Collision.CollisionCrouch.CanCollide = false
        --CollisionPart.CanCollide = false
    end; NoClip()
    Collision:GetPropertyChangedSignal("CanCollide"):Connect(NoClip)
    --CollisionPart:GetPropertyChangedSignal("CanCollide"):Connect(NoClip)
    warn('Stupid Collision GO AWAY')
end)

local AutoGetLoot = game:GetService('ProximityPromptService').PromptShown:Connect(function(prompt)
    GetLoot(prompt:FindFirstAncestorOfClass('Model'))
end)

local ChildAdded = workspace.CurrentRooms.DescendantAdded:Connect(function(room)--not work right now
    for _,inst in pairs(CurrentRoom():GetDescendants()) do
        if inst.Name == 'GoldPile' and inst:GetAttribute('GoldValue') >= 50 and GoldPicked() < 10000 then table.insert(GoldPiles,inst)
        elseif inst.Name == 'StardustPickup' then table.insert(Stardusts,inst)
        end
    end
end)

local Reconnecter = game:GetService("GuiService").ErrorMessageChanged:Connect(function(info)--Reconnecter 
    if info ~= 'Lost connection to the game server, please reconnect' then return PrefixWarn(info) end--Yeah hard code idc
	warn('Seems like u got a disconnect,reconnecting...')
    for tried = 1,5 do 
        warn('Trying reconnect,attempt(s):'..tried)
        TeleportService:Teleport(6516141723,LocalPlayer)
        task.wait(5)--timeout
    end
    warn('gone😢')
end)

local function Stop(GoLobby)
    PrefixWarn('Stop running now.')
    SetCamera(true)
    ChildAdded:Disconnect()
    LatestRoomChanged:Disconnect()
    CheckPlayerMove:Disconnect()
    PlayerDied:Disconnect()
    AutoGetLoot:Disconnect()

    ScreenGui:Destroy()
    Folder:Destroy()
    IsRunning = false
    if not GoLobby then return end
    RemotesFolder.Statistics:FireServer()
    task.wait()
    RemotesFolder.Lobby:FireServer()
    task.wait(3)
    TeleportService:Teleport(6516141723,LocalPlayer)
end

task.spawn(function() --Auto rejoin when the awful stuck wastes 2m
    repeat FinalCD = FinalCD + 1
        if math.fmod(FinalCD,30) == 0 and FinalCD ~= 0 then task.spawn(gotoPath) end
    task.wait(1) until FinalCD == 80 or not IsRunning
    if not IsRunning then return end
    PrefixWarn('Awful stuck.Auto rejoin.')
    Stop(true)
end)

PlayerDied = RemotesFolder.PlayerDied.OnClientEvent:Once(Stop)

CheckPlayerMove = game:GetService('UserInputService').InputBegan:Connect(function(InputObject,state)
    if InputObject.UserInputType ~= Enum.UserInputType.Keyboard or state == true then return end
    if not table.find(Key_BlackList,InputObject.KeyCode) then return end
    Stop()
end)

task.spawn(function()
    while IsRunning do 
        task.wait() --Avoid lag crash
        Main_Game.Movement.Enabled = false
        Character.Humanoid.AutoRotate = true
        Character.Humanoid.WalkSpeed = 21
        local Path = getPath()
    
        if GetEntity() then
            if not Path or not Path:FindFirstAncestor('Rooms_Locker') or GetEntity().Main.Position.Y <= -4 then continue end
    
            if (HumanoidRootPart.Position - Path.Position).Magnitude < 15 and not IsHiding() then
                InteractPrompt(Path,Path.Parent.HidePrompt)
            elseif GetEntity().Main.Position.Y < - 4 and IsHiding() then ExitFromLocker() end
            
        elseif IsHiding() then ExitFromLocker() end
        
        if Path and (HumanoidRootPart.Position - Path.Position).Magnitude <= 12 then GetLoot(Path) end
    end
end)

while IsRunning do task.wait(); gotoPath() end