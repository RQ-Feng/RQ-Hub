local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService('Players')
local StarterGui = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService('UserInputService')

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

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')
local Humanoid = Character:WaitForChild('Humanoid')

if game.PlaceId == 6516141723 then
    local suc,StardustCostOff; repeat
        suc,StardustCostOff = pcall(function() 
            return LocalPlayer.PlayerGui:WaitForChild('MainUI').LobbyFrame.ChooseFloor.List.Rooms.StardustCostOff.Text 
        end)
    task.wait() until suc
    
    if tonumber(StardustCostOff) and tonumber(StardustCostOff) > 0 then return Notify('Need stardust now bruh',math.huge) end

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

local MainUI = LocalPlayer.PlayerGui:WaitForChild('MainUI')
local Main_Game = MainUI.Initiator.Main_Game
local LatestRoom = ReplicatedStorage.GameData.LatestRoom

local Key_BlackList = {Enum.KeyCode.A,Enum.KeyCode.W,Enum.KeyCode.S,Enum.KeyCode.D}
local loots = {'GoldPile','StardustPickup'}
local Stardusts,GoldPiles = {},{}
local Connections,Highlights = {},{}
local Waypoints
local IsStuck = false
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

local function AddConnection(signal,func)
    local con = signal:Connect(func)
    table.insert(Connections,con)
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
    return workspace:FindFirstChild("A120")
end

local function SetPrompt(prompt)
    if typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then warn("[InteractPrompt]:ProximityPrompt expected, got " .. typeof(prompt)); return end
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

local function IsLoot(loot) return loot and table.find(loots,loot.Name) end

local function GetLoot(Loot)--Need to teleport manually
    Loot = Loot:IsA('Model') and Loot or Loot:FindFirstAncestorOfClass('Model')
    if not Loot or not IsLoot(Loot) then return end

    local path = Loot:FindFirstChild('Hitbox') or Loot:FindFirstChild('Main')
    local prompt = Loot:FindFirstChild('LootPrompt') or Loot:FindFirstChild('ModulePrompt')
    local LootTable = Loot.Name == 'StardustPickup' and Stardusts or GoldPiles

    repeat task.wait() until
    Loot:FindFirstAncestor('Assets') and tonumber(Loot:FindFirstAncestor('Assets').Parent.Name) <= LatestRoom.Value

    repeat InteractPrompt(path,prompt); task.wait() until
    not Loot or not Loot.Parent or not path or not prompt
    
    if table.find(LootTable,Loot) then table.remove(LootTable,table.find(LootTable,Loot)) end
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
    if ForceToDoor then 
        Stardusts,GoldPiles = {},{}
        return LatestRoom.Value == 1000 and CurrentRoom():WaitForChild('RoomsDoor_Exit'):WaitForChild('Door') or CurrentDoor():WaitForChild('Door') 
    end

    local Path
    if GetEntity() and GetEntity().Main.Position.Y > -4 then Path = getLocker()
    elseif Stardusts[1] and not IsStuck then Path = Stardusts[1].PrimaryPart
    elseif GoldPiles[1] and not IsStuck then Path = GoldPiles[1].PrimaryPart
    elseif LatestRoom.Value == 1000 then Path = CurrentRoom():WaitForChild('RoomsDoor_Exit'):WaitForChild('Door')
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
            times = 0
        else
            Stardusts,GoldPiles = {},{} 
            TeleportPlayer(getPath().CFrame)
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

local function gotoPath()
    Waypoints = nil

    local Destination = getPath() or getPath(true)
    if not Destination then return PrefixWarn('No Destination!') end

    Folder:ClearAllChildren()

    repeat task.wait() until not IsHiding()

    if not Destination:FindFirstChild('PathfindingModifier') then
        Instance.new('PathfindingModifier',Destination).PassThrough = true
    end

    local highlight = Destination:FindFirstChild('Highlight') or AddHighlight(Destination,Color3.fromRGB(85, 255, 127))

    path:ComputeAsync(DistanceFromFloor(HumanoidRootPart),DistanceFromFloor(Destination))
    Waypoints = path:GetWaypoints()
    
    if path.Status == Enum.PathStatus.NoPath then Waypoints = pathFallback(path,Destination) end
    if not Waypoints then return PrefixWarn('No waypoints!') end

    DisPlayWaypoints(Waypoints)
    
    for _, Waypoint in ipairs(Waypoints) do
        if GetEntity() and Destination ~= getLocker() then break end
        if not IsRunning then break end
        
        if Waypoint.Action == Enum.PathWaypointAction.Jump or IsStuck then Jump() end
        Humanoid:MoveTo(Waypoint.Position); local MoveSuccess = Humanoid.MoveToFinished:Wait()

        if not MoveSuccess and not IsHiding() then 
            PrefixWarn('Maybe you\'re stuck,trying again...')
            TeleportPlayer(Destination.CFrame)
            IsStuck = true
            task.wait(1); break 
        end
        IsStuck = false
        repeat task.wait() until not IsHiding()
    end
    if highlight then highlight:Destroy() end
end

local function ExitFromLocker()
    repeat RemotesFolder.CamLock:FireServer(); task.wait() until not IsHiding()
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

local function Stop(GoLobby)
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

    if not GoLobby then return end
    RemotesFolder.Statistics:FireServer()
    task.wait()
    RemotesFolder.Lobby:FireServer()
    task.wait(3)
    TeleportService:Teleport(6516141723,LocalPlayer)
end

antiafk()

AddConnection(game:GetService('ProximityPromptService').PromptShown,GetLoot)
AddConnection(RemotesFolder.PlayerDied.OnClientEvent,Stop)
AddConnection(RemotesFolder.Statistics.OnClientEvent,Stop)
AddConnection(LatestRoom.Changed,function(value)
    local room = CurrentRoom()
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
    if room:GetAttribute('RawName'):find('Rooms_Catwalk') then
        local function CheckItems(Parent,instName,func)
            AddConnection(Parent.ChildAdded,function(inst)
                if inst.Name == instName then func(inst) end
            end)
            for _,inst in pairs(Parent:GetChildren()) do
                if inst.Name == instName then func(inst) end
            end
        end
        CheckItems(room:WaitForChild('Parts'),'Steps',function(Steps)
            CheckItems(Steps,'Floor',function(floor) floor:Destroy() end)
        end)
    end
end)
AddConnection(workspace.CurrentRooms.DescendantAdded,function(inst)
    if inst.Name == 'GoldPile' and inst:GetAttribute('GoldValue') >= 100 and GoldPicked() < 10000 then table.insert(GoldPiles,inst)
    elseif inst.Name == 'StardustPickup' then table.insert(Stardusts,inst)
    elseif inst:IsA('ProximityPrompt') then SetPrompt(inst)
    end
end)
AddConnection(game:GetService("GuiService").ErrorMessageChanged,function(info)--Reconnecter 
    if info ~= 'Lost connection to the game server, please reconnect' then return PrefixWarn(info) end--Yeah hard code idc
	warn('Seems like u got a disconnect,reconnecting...')
    for tried = 1,5 do 
        warn('Trying reconnect,attempt(s):'..tried)
        TeleportService:Teleport(6516141723,LocalPlayer)
        task.wait(5)--timeout
    end
    warn('gone😢')
end)
AddConnection(game:GetService('UserInputService').InputBegan,function(InputObject,state)
    if InputObject.UserInputType ~= Enum.UserInputType.Keyboard or state == true then return end
    if not table.find(Key_BlackList,InputObject.KeyCode) then return end
    Stop()
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

task.spawn(function() --Auto rejoin when the awful stuck wastes 2m
    repeat FinalCD = FinalCD + 1
        if math.fmod(FinalCD,30) == 0 and FinalCD ~= 0 then task.spawn(gotoPath) end
    task.wait(1) until FinalCD == 80 or not IsRunning
    if not IsRunning then return end
    PrefixWarn('Awful stuck.Auto rejoin.')
    Stop(true)
end)

task.spawn(function() --Where's my HumanoidRootPart?
    repeat task.wait() until not HumanoidRootPart or not Character:FindFirstChild('HumanoidRootPart')
    Stop(true)
end)

task.spawn(function() --Other while do things
    while IsRunning do 
        task.wait() --Avoid lag crash
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
        
        if Path and (HumanoidRootPart.Position - Path.Position).Magnitude <= 16 then GetLoot(Path) end

        if LatestRoom.Value == 1000 then 
            local door = CurrentRoom():WaitForChild('RoomsDoor_Exit'):WaitForChild('Door')
            InteractPrompt(door,door:WaitForChild('EnterPrompt'))
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
        Camera.CFrame = CFrame.lookAt(HumanoidRootPart.CFrame.Position + Vector3.new(0, 12, 0),HumanoidRootPart.CFrame.Position - Vector3.new(0, 1, 0))

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        task.wait()
    end
end)

PrefixWarn('Start running now.')
while IsRunning do task.wait(); gotoPath() end