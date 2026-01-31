local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService('Players')
local StarterGui = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService('UserInputService')

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
		cfgTable['Callback'].OnInvoke = ButtonsCfg['Callback'] or function() end
    end
			
    local suc,_err
    repeat
        suc,_err = pcall(function()
            StarterGui:SetCore('SendNotification',cfgTable)
        end)
        if not suc then warn(_err) end; task.wait(0.1)
    until suc
end

repeat task.wait() until game:IsLoaded()
if game.PlaceId ~= 6839171747 then Notify('Incorrect place'); return end

local RemotesFolder = ReplicatedStorage:WaitForChild('RemotesFolder')

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')
local Humanoid = Character:WaitForChild('Humanoid')

local Connections = {}
local function AddConnection(signal,func)
    local con = signal:Connect(func)
    table.insert(Connections,con)
    return con
end

local CurrentFloor = ReplicatedStorage:WaitForChild('GameData'):WaitForChild('Floor').Value
if CurrentFloor ~= 'Rooms' then Notify('Incorrect floor'); return end

local executor = identifyexecutor and tostring(identifyexecutor())
local executor_BlackList = {
    ['Xeno'] = {'fireproximityprompt'}
}

local MainUI = LocalPlayer.PlayerGui:WaitForChild('MainUI')
local Main_Game = MainUI.Initiator.Main_Game
local LatestRoom = ReplicatedStorage.GameData.LatestRoom

local Key_BlackList = {Enum.KeyCode.A,Enum.KeyCode.W,Enum.KeyCode.S,Enum.KeyCode.D}
local Highlights = {}
local IsRunning = true
local FinalCD = 0

if workspace:FindFirstChild('AutoRooms_PathFindPartsFolder') then workspace.AutoRooms_PathFindPartsFolder:Destroy() end
local Folder = Instance.new("Folder")
Folder.Parent = workspace
Folder.Name = "AutoRooms_PathFindPartsFolder"

local path = PathfindingService:CreatePath({
    WaypointSpacing = 3,
    AgentHeight = 3,
    AgentRadius = 1.5,
    AgentCanJump = true,
    Costs = {Basalt = math.huge}
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = ScreenGui
TextLabel.Text = "Room: "..LatestRoom.Value
TextLabel.Size = UDim2.new(0,350,0,100)
TextLabel.TextSize = 48
TextLabel.TextStrokeColor3 = Color3.new(1,1,1)
TextLabel.TextStrokeTransparency = 0
TextLabel.BackgroundTransparency = 1

local function PrefixWarn(...)
    if not ... then return warn('[PrefixWarn] Expect string,got nil.') end
    local strs,message = {...},''
    for _,str in pairs(strs) do message = message..(str == strs[1] and '' or ' ')..tostring(str) end
    return warn('[Auto Rooms] '..message)
end

local function AddHighlight(inst,color3)
    if not inst then return end
    local highlight = Instance.new('Highlight')
    highlight.FillColor = color3
    highlight.FillTransparency = 0.6
    highlight.Parent = inst
    table.insert(Highlights,highlight)
    return highlight
end

local function TeleportPlayer(pos)
    local posType = typeof(pos)
    if posType ~= 'Vector3' and posType ~= 'CFrame' then return end

    repeat task.wait() until not workspace:FindFirstChild('A60')

    pos = posType == 'Vector3' and CFrame.new(pos) or pos
    if HumanoidRootPart then HumanoidRootPart.CFrame = pos end
end

local function CurrentRoom()
    return workspace.CurrentRooms[LatestRoom.Value]
end

local function CurrentDoor()
    return CurrentRoom():WaitForChild('Door')
end

local function GetEntity()
    return workspace:FindFirstChild("A120")
end

local function SetPrompt(prompt)
    if not prompt or typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then return end
    prompt.Enabled = true
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 16
end

local function InteractPrompt(Path,prompt)
    if typeof(Path) ~= 'Instance' or not Path:IsA("BasePart") then warn("[InteractPrompt]:BasePart expected, got " .. typeof(Path)); return end
    if typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then warn("[InteractPrompt]:ProximityPrompt expected, got " .. typeof(prompt)); return end

    if (HumanoidRootPart.Position - Path.Position).Magnitude > 18 then return end

    if not table.find(executor_BlackList[executor],'fireproximityprompt') then --no need to use fallback firepp
        fireproximityprompt(prompt); return 
    end

    SetPrompt(prompt)
    prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
end

local function IsHiding() return Character:GetAttribute('Hiding') end

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
    local Path
    if ForceToDoor then Path = CurrentDoor():WaitForChild('Door')
    elseif GetEntity() and GetEntity().Main.Position.Y > -4 then Path = getLocker()
    else Path = CurrentDoor():WaitForChild('Door') end
    return Path
end

local function pathFallback(path,Destination,times)
    times = (times and times < 5) and times + 1 or 1
    if not IsRunning then return end

    PrefixWarn('Path got',tostring(path.Status)..',using fallback.')
    
    repeat task.wait() until not IsHiding()

    if not Destination then Destination = getPath() end
    local _suc,gotoPosition = pcall(function() return times < 5 and Destination.Position - Vector3.new(0,times,0) or Destination.Position end)
    
    path:ComputeAsync(HumanoidRootPart.Position,gotoPosition)

    if path.Status == Enum.PathStatus.NoPath then
        if times < 5 then
            Humanoid:MoveTo(Destination.Position); task.wait(2)
            TeleportPlayer(Destination.CFrame); task.wait(0.5)
        else
            TeleportPlayer(getPath().CFrame)
            times = 0
        end
        repeat task.wait() until not IsHiding()
        return (Destination and Destination.Parent) and pathFallback(path,Destination,times) or pathFallback(path,getPath(),times)
    end
    return path:GetWaypoints()
end

local function DisPlayWaypoints(Waypoints)
    for _, Waypoint in ipairs(Waypoints) do
        local pointColor = Waypoint.Action == Enum.PathWaypointAction.Jump and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 100, 0)
        local part = Instance.new("Part")
        part.Size = Vector3.new(1,1,1)
        part.Position = Waypoint.Position + Vector3.new(0,0.5,0)
        part.Shape = "Cylinder"
        part.Color = pointColor
        part.Rotation = Vector3.new(0,0,90)
        part.Material = "SmoothPlastic"
        part.Anchored = true
        part.CanCollide = false
        part.Parent = Folder
        AddHighlight(part,pointColor)
    end
end

local function Jump()
    repeat task.wait() until not workspace:FindFirstChild('A60')
    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.2)
end

local function gotoPath(ForceDestination)
    local Waypoints
    Folder:ClearAllChildren()

    repeat task.wait() until not IsHiding()

    local Destination = ForceDestination or getPath() or getPath(true)
    if not Destination then return PrefixWarn('No Destination!') end

    if not CurrentDoor():FindFirstChild('PathfindingModifier') then
        Instance.new('PathfindingModifier',CurrentDoor()).PassThrough = true
    end
    if not Destination:FindFirstChild('PathfindingModifier') then
        Instance.new('PathfindingModifier',Destination).PassThrough = true
    end

    local highlight = Destination:FindFirstChild('Highlight') or AddHighlight(Destination,Color3.fromRGB(85, 255, 127))

    path:ComputeAsync(HumanoidRootPart.Position,Destination.Position)
    Waypoints = path:GetWaypoints()
    
    if path.Status == Enum.PathStatus.NoPath then Waypoints = pathFallback(path,Destination) end
    if not Waypoints then return PrefixWarn('No waypoints!') end

    DisPlayWaypoints(Waypoints)

    for _, Waypoint in ipairs(Waypoints) do--Walk
        if not IsRunning or not Destination or not Destination.Parent then break end
        if GetEntity() and (IsHiding() or Destination ~= getLocker()) then break end
        repeat task.wait() until not IsHiding()
        if Waypoint.Action == Enum.PathWaypointAction.Jump then Jump() end
        Humanoid:MoveTo(Waypoint.Position); local MoveSuccess = Humanoid.MoveToFinished:Wait()
    
        if not MoveSuccess and not IsHiding() and (HumanoidRootPart.Position - Waypoint.Position).Magnitude <= 10 then
            PrefixWarn('Maybe you\'re stuck,trying again...')
            TeleportPlayer(Destination.CFrame)
            task.wait(1); Jump(); break 
        end
    end
    
    if highlight then highlight:Destroy() end
end

local function ExitFromLocker()
    repeat RemotesFolder.CamLock:FireServer(); task.wait() until not IsHiding()
end

local function antiafk()
    if getconnections then
        for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
            if connection["Disable"] then connection["Disable"](connection)
            elseif connection["Disconnect"] then connection["Disconnect"](connection) end
        end
    end
    local VirtualUser = game:GetService('VirtualUser')
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

function StopAutoRooms(Info)
    PrefixWarn('Stop running now.')
    IsRunning = false
    for _,con in pairs(Connections) do con:Disconnect() end
    for _,hl in pairs(Highlights) do hl:Destroy() end

    Main_Game.Camera.Enabled = true
    if Character:FindFirstChild('Head') then
        local light = Character.Head:WaitForChild('PointLight') 
        if light then light:Destroy() end
    end

    ScreenGui:Destroy()
    Folder:Destroy()
    if Humanoid then Humanoid.WalkSpeed = 21 end
    RemotesFolder.Crouch:FireServer(true)

    if not Info then return end
    
    local ExitReason = (Info == 'Moved' and 'Player moved.')
    or (Info == 'Done' and 'Reached A-1000.')
    or (Info == 'Awfulstuck' and 'Awful stuck.')
    or (not Character:GetAttribute('Alive') and 'Died to '..Character:GetAttribute('DeathCause'))
    or (Info['Knobs'] and 'Statistics,got '..Info['Knobs'][3]..' knob(s).')

    Notify('Stop running.Reason:\n'..ExitReason,math.huge,{
        Button1 = ((Info ~= 'Moved' and Info ~= 'Done') and 'Damn '  or '') ..'okay'
    })
end

antiafk()

AddConnection(RemotesFolder.PlayerDied.OnClientEvent,StopAutoRooms)
AddConnection(RemotesFolder.Statistics.OnClientEvent,StopAutoRooms)
AddConnection(game:GetService("GuiService").ErrorMessageChanged,StopAutoRooms)
AddConnection(workspace.CurrentRooms.DescendantAdded,SetPrompt)
AddConnection(game:GetService('ProximityPromptService').PromptShown,function(Loot)
    Loot = Loot:IsA('Model') and Loot or Loot:FindFirstAncestorOfClass('Model')
    if not Loot or not table.find({'GoldPile','StardustPickup'},Loot.Name) then return end

    local path = Loot:FindFirstChild('Hitbox') or Loot:FindFirstChild('Main')
    local prompt = Loot:FindFirstChild('LootPrompt') or Loot:FindFirstChild('ModulePrompt')

    repeat task.wait() until
    Loot:FindFirstAncestor('Assets') and tonumber(Loot:FindFirstAncestor('Assets').Parent.Name) <= LatestRoom.Value

    repeat InteractPrompt(path,prompt); task.wait() until
    not Loot or not Loot.Parent or not path or not prompt or not IsRunning
end)
AddConnection(LatestRoom.Changed,function(value)
    local room = CurrentRoom()
    TextLabel.Text = "Room: "..math.clamp(value, 1,1000)
    FinalCD = 0
    if LatestRoom.Value == 1000 then
        Folder:ClearAllChildren()
        Notify('已到达A-1000',math.huge)
        StopAutoRooms('Done')
    end
    if room:GetAttribute('RawName'):find('Rooms_Catwalk') then
        local Parts = room:WaitForChild('Parts')
        AddConnection(Parts.DescendantAdded,function(floor)
            if floor.Name == 'Floor' then floor:Destroy() end
        end)
        for _,floor in pairs(Parts:GetChildren()) do
            if floor.Name == 'Floor' then floor:Destroy() end
        end
    end
end)
AddConnection(game:GetService('UserInputService').InputBegan,function(InputObject,state)
    if InputObject.UserInputType ~= Enum.UserInputType.Keyboard or state == true then return end
    if table.find(Key_BlackList,InputObject.KeyCode) then StopAutoRooms('Moved') end
end)

task.spawn(function() --Fuck u A90
    local A90_RemoteEvent = ReplicatedStorage.RemotesFolder:FindFirstChild("A90")
    if not A90_RemoteEvent then return end
    A90_RemoteEvent:Destroy()
end)

task.spawn(function() --Fuck u USELESS COLLISION
    local Collision = Character:WaitForChild('Collision')
    local function NoClip()
        Collision.CollisionGroup = "PlayerCrouching"
        Collision.CollisionCrouch.CollisionGroup = "PlayerCrouching"
        Collision.CanCollide = false
        Collision.CollisionCrouch.CanCollide = false
        --CollisionPart.CanCollide = false
    end; NoClip()
    AddConnection(Collision:GetPropertyChangedSignal("CanCollide"),NoClip)
end)

task.spawn(function() --Auto stop when the awful stuck wastes 2m
    repeat FinalCD = FinalCD + 1
        if math.fmod(FinalCD,30) == 0 and FinalCD ~= 0 then task.spawn(gotoPath) end
    task.wait(1) until FinalCD == 80 or not IsRunning
    if not IsRunning then return end
    PrefixWarn('Awful stuck bro...')
    StopAutoRooms('Awfulstuck')
end)

task.spawn(function() --Other while do things
    while IsRunning do task.wait() --Avoid lag crash
        local Path = getPath()

        if GetEntity() then
            if not Path or not Path:FindFirstAncestor('Rooms_Locker') then continue end
            if (HumanoidRootPart.Position - Path.Position).Magnitude < 16 and not IsHiding() then
                InteractPrompt(Path,Path.Parent.HidePrompt)
            elseif GetEntity().Main.Position.Y < - 4 and IsHiding() then ExitFromLocker() end
        else
            if IsHiding() then ExitFromLocker() end
            CurrentDoor():WaitForChild('ClientOpen'):FireServer()
        end
    end
end)

task.spawn(function() --Player setter
    while IsRunning do
        Humanoid.HipHeight = 0.1
        RemotesFolder.Crouch:FireServer(true)

        Main_Game.Movement.Enabled = false
        Main_Game.Camera.Enabled = false

        Humanoid.AutoRotate = true
        Humanoid.WalkSpeed = 21.5
        Humanoid.UseJumpPower = false
        Humanoid.JumpHeight = 10
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)

        local Camera = workspace.CurrentCamera
        Camera.FieldOfView = 120
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.lookAt(HumanoidRootPart.CFrame.Position + Vector3.new(0, 12, 0),HumanoidRootPart.CFrame.Position)

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        task.wait()
    end
end)

PrefixWarn('Start running now.')
task.spawn(function() while IsRunning do task.wait(); gotoPath() end end)