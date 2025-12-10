warn('Knobs farm is loaded!')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LobbyPlaceId,GamePlaceId,DoorsGameId = 6516141723,6839171747,2440500124
local ByAutoRejoin,StopFarming,TryingReconnect,Statisticsed,Voided = false,false,false,false,false
local StartTime,FarmTimeOut = os.clock(),os.clock()

if game.GameId ~= DoorsGameId then warn('Incorrect game'); return end

game:GetService("GuiService").ErrorMessageChanged:Connect(function(info)--Reconnecter
    if TryingReconnect or info ~= 'Lost connection to the game server, please reconnect' then return end--Yeah hard code idc
	warn('Seems like u got a disconnect,reconnecting...')
    for tried = 1,5 do 
        warn('Trying reconnect,attempt(s):'..tried)
        TeleportService:Teleport(LobbyPlaceId,LocalPlayer)
        task.wait(5)--timeout
    end
    warn('gone😢')
end)

StarterGui:SetCore('SendNotification',{
    Title = 'Doors knobs farm',
    Text = 'Loaded!',
    Duration = 5
})

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local RemotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")

--Config
local defaultCfg = {
    ['AllFarmknobs'] = 0,
    ['AllFarmTime'] = 0
}

local cfgName = 'doors_knobs_farm_cfg.json'

local suc,cfg = pcall(function()
    local cfg = HttpService:JSONDecode(readfile(cfgName)) 
    for k,v in pairs(defaultCfg) do if cfg[k] and type(cfg[k]) == type(v) then continue else error('Bad json') end end
    return cfg
end)

if not suc then 
    warn('[DEBUG]loading cfg is not success:'..cfg)
    writefile(cfgName,HttpService:JSONEncode(defaultCfg))
    cfg = defaultCfg
end

--Basic functions
local function WaitChild(Parent,instName)
    if typeof(Parent) ~= 'Instance' or type(instName) ~= 'string' then return end
    local Cache
    repeat Cache = Parent:WaitForChild(instName,0.1) until Cache
    return Cache
end

local function WaitInstance(instPath)
    if type(instPath) ~= 'string' then return end
    local Cache
    repeat _suc,Cache = Parent:WaitForChild(instName,0.1) until Cache
    return Cache
end

local function Notify(Text,Duration,ButtonsCfg)
    local cfgTable = {
        Title = 'Doors knobs farm',
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

local function saveCfg() writefile(cfgName, HttpService:JSONEncode(cfg)) end

local function TeleportPlayer(TeleportCFrame)
    if not HumanoidRootPart or typeof(TeleportCFrame) ~= 'CFrame' then return end
    HumanoidRootPart.CFrame = CFrame.new(TeleportCFrame.Position)
end

Notify('是否清除累计记录?',30,{
	Button1 = '是',
	Button2 = '否',
	Callback = function(choice)
		if choice ~= '是' then return end
        cfg = defaultCfg; saveCfg()
	end
})

if game.PlaceId == LobbyPlaceId then--Rejoin the game in the lobby
    warn('In lobby,teleporting to game...')
    Notify('Rejoining the game...')
    local defaultMods = {
        'LightsOut',
        'Gloombat',
        'NoGuidingLight',
        'PlayerCrouchSlow',
        'PlayerSlowHealth',
        'TimothyMore',
        'DupeMost',
        'LeastHidingSpots',
        'Fog',
        'HideTime',
        'FigureFaster',
        'HideLevel2',
        'ScreechFaster',
        'ItemSpawnNone',
        'Jammin',
    }
    
    local function CreateElevator(mod)
        if type(mod) ~= 'table' then return end
        RemotesFolder.CreateElevator:FireServer({
            FriendsOnly = true,
            MaxPlayers = 1,
            Mods = mod,
            Destination = 'Hotel',
            Settings = {}
        })
    end

    CreateElevator(defaultMods)
    task.wait(1.2)
    CreateElevator({})
    return
end

--Interact things
local MainUI = WaitChild(LocalPlayer.PlayerGui,'MainUI')

local CameraScript,MovementScript; repeat --Waiting for scripts
    _suc,CameraScript,MovementScript = pcall(function() 
        CameraScript = MainUI.Initiator.Main_Game.Camera
        MovementScript = MainUI.Initiator.Main_Game.Movement
        return CameraScript,MovementScript
    end); task.wait()
until CameraScript and MovementScript

MovementScript.Enabled = false

--Interact
local function BetterPrompt(prompt)
    if typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then warn("[BetterPrompt]:ProximityPrompt expected, got " .. typeof(prompt)); return end
    
    prompt.Enabled = true
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12

    prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
end

local function LookToInteract(targetPart,interactPrompt)
    if not Character then return warn('[LookToInteract]:Character got nil') end
    if not targetPart or not interactPrompt then return warn('[LookToInteract]:'..(not targetPart and 'BasePart' or 'ProximityPrompt'),'expected, got nil') end
    if not targetPart:IsA('BasePart') or not interactPrompt:IsA('ProximityPrompt') then return 
        warn('[LookToInteract]:'..targetPart:IsA('BasePart') and 'BasePart' or 'ProximityPrompt','expected, got '
        ..targetPart:IsA('BasePart') and typeof(targetPart) or typeof(interactPrompt))
    end

    CameraScript.Enabled = false
    workspace.CurrentCamera.FieldOfView = 120
    workspace.CurrentCamera.CFrame = CFrame.lookAt(HumanoidRootPart.Position,targetPart.Position)
    BetterPrompt(interactPrompt)
end
--Important things getter
local function LatestRoom()
    return ReplicatedStorage.GameData.LatestRoom.Value
end

local function CurrentRoom()
    return workspace.CurrentRooms[LatestRoom()]
end

local function CurrentDoor()
    return CurrentRoom():FindFirstChild('Door')
end

local function CheckBackpackKey()
    return Character:FindFirstChild('Key') or LocalPlayer.Backpack:FindFirstChild('Key')
end
--Other functions
local function GetKey(KeyObtain)
    if KeyObtain.Name ~= 'KeyObtain' then return end
    local KeyHitBox = WaitChild(KeyObtain,'Hitbox')
                    
    while not CheckBackpackKey() and KeyObtain and KeyObtain.Parent do
        TeleportPlayer(KeyHitBox.CFrame)

        if KeyObtain.Parent and KeyObtain.Parent.Name == 'DrawerContainer' then 
            local Knobs = WaitChild(KeyObtain.Parent,'Knobs')
            LookToInteract(Knobs,Knobs:WaitForChild('ActivateEventPrompt',0.1))
        else LookToInteract(KeyHitBox,KeyObtain:WaitForChild('ModulePrompt',0.1)) end
        task.wait()
    end
    if CheckBackpackKey() then warn('Got key:',CheckBackpackKey().Name) else warn('Got key failed.') end
end

local function GetGoldPile(GoldPile)
    local Hitbox = WaitChild(GoldPile,'Hitbox')
    local LootPrompt = WaitChild(GoldPile,'LootPrompt')
    repeat 
        TeleportPlayer(Hitbox.CFrame)
        LookToInteract(Hitbox,LootPrompt) 
        task.wait() 
    until not GoldPile or not GoldPile.Parent    
    CameraScript.Enabled = true
end

local function Statistics()
    RemotesFolder.Statistics:FireServer()
    RemotesFolder.PlayAgain:FireServer()
    ByAutoRejoin = true
    Notify('是否停止重开?',3,{
        Button1 = '是',
        Button2 = '否',
        Callback = function(choice)
            if choice ~= '是' then return end
            RemotesFolder.PlayAgain:FireServer()
            Notify('是否返回大厅?',30,{
                Button1 = '是',
                Button2 = '否',
                Callback = function(choice)
                    if choice ~= '是' then return end
                    RemotesFolder.Lobby:FireServer()
                end
            })
        end
    })
end

warn('Start farming...')

RemotesFolder.Statistics.OnClientEvent:Connect(function(table)
    Statisticsed = true
    local farmtime = math.floor(os.clock() - StartTime)
    cfg['AllFarmknobs'] = cfg['AllFarmknobs'] + table['Knobs'][3]
    cfg['AllFarmTime'] = cfg['AllFarmTime'] + farmtime
    Notify(`共获取 {cfg['AllFarmknobs']} 个knobs,共用时 {cfg['AllFarmTime']} 秒.\n此次用时 {farmtime} 秒.`)
    saveCfg()
end)

RemotesFolder:FindFirstChild("UseEnemyModule").OnClientEvent:Connect(function(entity)--HOW DARE U VOID AND RUSH
    if entity ~= 'Void' then return end
    task.wait(2); warn('HOW DARE U VOID')
    RemotesFolder.PreRunShop:FireServer(); CameraScript.Enabled = true; Voided = true

    repeat until workspace:FindFirstChild('RushMoving') or CurrentDoor():WaitForChild('Lock',0.1)
    warn(workspace:FindFirstChild('RushMoving') and 'Oh no rush is coming,RUN!' or 'I hate the lock bruh'); StopFarming = true
end)

RemotesFolder:FindFirstChild("PlayerDied").OnClientEvent:Connect(function()--HOW DARE U VOID AND RUSH
    warn('HOW BRO'); Statistics(); StopFarming = true
end)

task.spawn(function() --Fuck u Jam
    local Jam = MainUI.Initiator.Main_Game.Health.Jam
    if Jam then Jam.Volume = 0 end
    repeat task.wait() until Jam.IsPlaying; Jam:Stop(); warn('Stupid Jam GO AWAY')
end)

task.spawn(function() --Fuck u ItemShop UI
    local ItemShop = WaitChild(MainUI,'ItemShop') 
    repeat task.wait() until MainUI:FindFirstChild('ItemShop').Visible
    MainUI:FindFirstChild('ItemShop').Visible = false 
    warn('Stupid ItemShop ui GO AWAY')
end)

task.spawn(function() --Fuck u USELESS COLLISION
    local Collision = Character:FindFirstChild('Collision')
    local CollisionPart = Character:FindFirstChild('CollisionPart')
    local function NoClip()
        Collision.CollisionGroup = "PlayerCrouching"
        Collision.CollisionCrouch.CollisionGroup = "PlayerCrouching"
        CollisionPart.CollisionGroup = "PlayerCrouching"
        Collision.CanCollide = false
        Collision.CollisionCrouch.CanCollide = false
        --CollisionPart.CanCollide = false
    end; NoClip()
    Collision:GetPropertyChangedSignal("CanCollide"):Connect(NoClip)
    --CollisionPart:GetPropertyChangedSignal("CanCollide"):Connect(NoClip)
    warn('Stupid Collision GO AWAY')
end)

task.spawn(function() --Fuck u Screech
    local ScreechRE = WaitChild(RemotesFolder,'Screech') 
    ScreechRE.Name = '_Screech'
    warn('Stupid Screech GO AWAY')
end)

task.spawn(function()--Open doors loop
    repeat task.wait() until Character
    repeat
        local Assets = WaitChild(CurrentRoom(),'Assets')
        local door = CurrentDoor()

        local function GetDoorLockedPart()
            local Lock = door:WaitForChild('Lock',0.1)
            return (Lock and Lock.Parent ~= nil) and Lock or nil
        end

        for _,Item in pairs(Assets:GetDescendants()) do
            if Item.Name == 'GoldPile' then warn(Item); GetGoldPile(Item) end
            if Item.Name == 'KeyObtain' and GetDoorLockedPart() and not CheckBackpackKey() then GetKey(Item) end
        end
        
        if Voided then 
            local clone = Character:FindFirstChild('_CollisionPart')
            if not clone then clone = Character:FindFirstChild('CollisionPart'):Clone() end
            clone.Name = '_CollisionPart'
            clone.Anchored = false
            clone.Parent = Character
            clone.CanCollide = false

            MovementScript.Enabled = false 
            task.spawn(function()
                local CurrentTime = os.clock(); repeat
                    clone.Massless = not clone.Massless; task.wait(0.22)
                    door:FindFirstChild('ClientOpen'):FireServer()
                until door:GetAttribute('Opened') or StopFarming or os.clock() - CurrentTime >= 3
            end)

            Character:SetAttribute('SpeedBoost',50)
            Humanoid:MoveTo(door.Door.CFrame.Position)

            task.wait(3); clone.Massless = true
        end

        repeat
            if door:GetAttribute('Opened') or StopFarming then break end
            TeleportPlayer(door.Door.CFrame)
            if GetDoorLockedPart() then LookToInteract(GetDoorLockedPart(),GetDoorLockedPart():WaitForChild('UnlockPrompt',0.1)) 
            else door:FindFirstChild('ClientOpen'):FireServer() end
            task.wait()
        until door:GetAttribute('Opened') or StopFarming

        warn(StopFarming and 'Final latest' or 'Latest','Room:',LatestRoom())
        FarmTimeOut = os.clock()
        CameraScript.Enabled = true
        task.wait()
    until StopFarming
end)

task.spawn(function() repeat task.wait() until StopFarming; if not Statisticsed then Statistics() end end)--Wait for statistics

task.spawn(function()--Forced Statistics
    FarmTimeOut = os.clock()
    repeat task.wait() until os.clock() - FarmTimeOut >= 10
    if ByAutoRejoin then return end
    warn('Bro I think ur stuck.Statistics now')
    Statistics()
    CameraScript.Enabled = true
    MovementScript.Enabled = true 
end)




-- local PathfindingService = game:GetService("PathfindingService")

-- -- This model contains a start, end and three paths between the player can walk on: Snow, Metal and LeafyGrass
-- local startPosition = workspace.RQ_Feng.HumanoidRootPart.Position
-- local finishPosition = workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].RoomExit.Position

-- local path = PathfindingService:CreatePath({
-- 	AgentRadius = 3,
-- 	AgentHeight = 2,
-- 	WaypointSpacing = 4,
-- 	AgentCanJump = false,
-- 	Costs = {
-- 		Wood = math.huge,
-- 		ForceField = math.huge
-- 	},
-- })

-- -- Compute the path
-- local success, errorMessage = pcall(function()
-- 	path:ComputeAsync(startPosition, finishPosition)
-- end)

-- -- Confirm the computation was successful
-- if success and path.Status == Enum.PathStatus.Success then
-- 	-- For each waypoint, create a part to visualize the path
-- 	for _, waypoint in path:GetWaypoints() do
-- 		local part = Instance.new("Part")
-- 		part.Position = waypoint.Position
-- 		part.Size = Vector3.new(0.5, 0.5, 0.5)
-- 		part.Color = Color3.new(1, 0, 1)
-- 		part.Anchored = true
-- 		part.CanCollide = false
-- 		part.Parent = Workspace
-- 		Instance.new("Highlight",part)
-- 		workspace.RQ_Feng.Humanoid:MoveTo(part.Position)
-- 		workspace.RQ_Feng.Humanoid.MoveToFinished:Wait()
-- 		part:Destroy()
-- 	end
-- else
-- 	print(`Path unable to be computed, error: {errorMessage}`)
-- end