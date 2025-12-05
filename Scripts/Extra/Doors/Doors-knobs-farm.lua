warn('Knobs farm is loaded!')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local LobbyPlaceId,GamePlaceId,DoorsGameId = 6516141723,6839171747,2440500124
local ByAutoRejoin,StopFarming,TryingReconnect = false,false,false
local ForcedStatisticsThread

--Config
local defaultCfg = {
    ['Latestknobs'] = 0
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
			
    game:GetService('StarterGui'):SetCore('SendNotification',cfgTable)
end

local function saveCfg() writefile(cfgName, HttpService:JSONEncode(cfg)) end

local function TeleportPlayer(TeleportCFrame)
    if HumanoidRootPart then HumanoidRootPart.CFrame = CFrame.new(TeleportCFrame.Position) end
end

local function Statistics()
    if ForcedStatisticsThread and type(ForcedStatisticsThread) == 'thread' then coroutine.close(ForcedStatisticsThread) end
    RemotesFolder.Statistics:FireServer()
    RemotesFolder.PlayAgain:FireServer()
    ByAutoRejoin = true
end

Notify('是否清除累计Knobs记录?',30,{
	Button1 = '是',
	Button2 = '否',
	Callback = function(choice)
		if choice ~= '是' then return end
        cfg['Latestknobs'] = 0
        saveCfg()
	end
})
if game.GameId ~= DoorsGameId then warn('Incorrect game') return end
--Interact things
local MainUI = WaitChild(LocalPlayer.PlayerGui,'MainUI')
local DoorsCameraScript = game.PlaceId == GamePlaceId and MainUI.Initiator.Main_Game.Camera

local function BetterPrompt(prompt)
    if typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then return error("ProximityPrompt expected, got " .. typeof(prompt)) end
    
    prompt.Enabled = true
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12

    if fireproximityprompt then fireproximityprompt(prompt) else prompt:InputHoldBegin() end
end

local function LookToInteract(targetPart,interactPrompt)
    if not targetPart or not interactPrompt or not Character then return end
    if not targetPart:IsA('BasePart') or not interactPrompt:IsA('ProximityPrompt') then return end
    DoorsCameraScript.Enabled = false
    workspace.CurrentCamera.CFrame = CFrame.lookAt(Character:FindFirstChild('Head').Position,targetPart.Position)
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

game:GetService("GuiService").ErrorMessageChanged:Connect(function(info)
    if TryingReconnect or info == 'Lost connection to the game server.please reconnect' then return end--Yeah hard code idc
	warn('Seems like u got a disconnect,reconnecting...')
    for tried = 1,5 do 
        warn('Trying reconnect,attempt(s):'..tried)
        TeleportService:Teleport(LobbyPlaceId,LocalPlayer)
        task.wait(5)--timeout
    end
    warn('gone😢')
end)

if game.PlaceId == LobbyPlaceId then
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
        'Slippery',
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

warn('Start farming...')

RemotesFolder.Statistics.OnClientEvent:Connect(function(table)
    cfg['Latestknobs'] = cfg['Latestknobs'] + table['Knobs'][3]
    Notify(`共获取 {cfg['Latestknobs']} 个knobs.`)
    saveCfg()
end)

RemotesFolder:FindFirstChild("UseEnemyModule").OnClientEvent:Connect(function(entity)
    if entity == 'Void' then StopFarming = true end
end)

task.spawn(function()
    local ItemShop = WaitChild(MainUI,'ItemShop') 
    repeat task.wait() until MainUI:FindFirstChild('ItemShop').Visible
    MainUI:FindFirstChild('ItemShop').Visible = false 
    warn('Stupid ItemShop ui GO AWAY')
end)

task.spawn(function()
    repeat
        if not CurrentDoor() then return end
        local Assets = WaitChild(CurrentRoom(),'Assets')
        local KeyHitBox;for _,KeyObtain in pairs(Assets:GetDescendants()) do
            if KeyObtain.Name ~= 'KeyObtain' then continue end
            KeyHitBox = WaitChild(KeyObtain,'Hitbox')
            repeat TeleportPlayer(KeyHitBox.CFrame)
                pcall(function()
                    if KeyObtain.Parent.Name == 'DrawerContainer' then 
                        local Knobs = WaitChild(KeyObtain.Parent,'Knobs')
                        LookToInteract(Knobs,Knobs:WaitForChild('ActivateEventPrompt',0.1))
                    else LookToInteract(KeyHitBox:WaitForChild('KeyHitBox',0.1),KeyObtain:WaitForChild('ModulePrompt',0.1)) end
                end)
            until Character:WaitForChild('Key',0.1) or LocalPlayer.Backpack:WaitForChild('Key',0.1)
            break
        end
    
        repeat
            if not CurrentDoor() then return end
            local door = CurrentDoor()
            TeleportPlayer(door.Door.CFrame)
            pcall(function()  
                if KeyHitBox then
                    local Lock = WaitChild(door,'Lock')
                    LookToInteract(Lock,Lock:WaitForChild('UnlockPrompt',0.1))
                else door.ClientOpen:FireServer() end
            end)
            task.wait(0.1)
        until door:GetAttribute('Opened')
        DoorsCameraScript.Enabled = true
        KeyHitBox = nil
    until StopFarming
end)

task.spawn(function() repeat task.wait() until StopFarming Statistics() end)

--Forced Statistics
ForcedStatisticsThread = coroutine.create(function()
    task.wait(20)
    warn('Bro I think ur stuck.Statistics now')
    Statistics()
end)
coroutine.resume(ForcedStatisticsThread)