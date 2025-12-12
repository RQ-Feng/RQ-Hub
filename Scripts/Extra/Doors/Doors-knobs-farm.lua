local LobbyPlaceId,GamePlaceId,DoorsGameId = 6516141723,6839171747,2440500124
if game.GameId ~= DoorsGameId then warn('Incorrect game'); return end

warn('Knobs farm is loaded!')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ByAutoRejoin,TryingReconnect = false,false
local StopFarming,Statisticsed,Voided = false,false,false
local FastMode = (replicatesignal and type(replicatesignal) == 'function') and true or false
local CurrentGetKnobs; if FastMode then CurrentGetKnobs = 0 end
local StartTime,FarmTimeOut = os.clock(),os.clock()

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
    Text = '已加载',
    Duration = 5
})
--Character
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

if game.PlaceId == LobbyPlaceId then--Rejoin the game in the lobby
    warn('In lobby,teleporting to game...')
    Notify('Rejoining the game...')

    local default = {
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

    local fallback = {
        'Gloombat',
        'NoGuidingLight',
        'TimothyMore',
        'ScreechLight',
        'ScreechFast',
        'RushFaster',
        'NoKeySound',
        'LeastHidingSpots',
        'Fog',
        'EyesMore',
        'HideTime',
        'LightsLeast',
        'ItemSpawnNone',
        'DupeMore',
        'PlayerDamageMore'
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
        task.wait(1.2)--Wait for cooldown
    end

    CreateElevator(default)--150%
    CreateElevator(fallback)--125%
    CreateElevator({})--Final fallback--0%
    return
end

repeat task.wait() until game:GetService("ReplicatedFirst")._Loaded.Value--Wait for game loaded

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

Notify('是否清除累计记录?',30,{
	Button1 = '是',
	Button2 = '否',
	Callback = function(choice)
		if choice ~= '是' then return end
        cfg = defaultCfg; saveCfg()
	end
})

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
    if GoldPile.Name ~= 'GoldPile' then return end
    local Hitbox = WaitChild(GoldPile,'Hitbox')
    local LootPrompt = WaitChild(GoldPile,'LootPrompt')
    repeat 
        TeleportPlayer(Hitbox.CFrame)
        LookToInteract(Hitbox,LootPrompt) 
        task.wait() 
    until not GoldPile or not GoldPile.Parent    
    CameraScript.Enabled = true
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

local function GetLootSpawned(Loot)
    if not Loot or not Loot:IsA('Model') then return false end
    return Loot:FindFirstChild('LootHolder') and true or false
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

--Farmer
warn('Start farming...')
warn(FastMode and 'W' or 'L','exploit')

RemotesFolder.Statistics.OnClientEvent:Connect(function(table)
    local GotKnobs = table['Knobs'][3]
    local farmtime = math.floor(os.clock() - StartTime)
    local notifyStr = (FastMode and '目前共获取 %d 个knobs.' or '共获取 %d 个knobs,共用时 %d 秒.\n此次用时 %d 秒.')
    :format((FastMode and CurrentGetKnobs or cfg['AllFarmknobs']),cfg['AllFarmTime'],farmtime)

    if not FastMode then 
        Statisticsed = true
        cfg['AllFarmTime'] = cfg['AllFarmTime'] + farmtime
        cfg['AllFarmknobs'] = cfg['AllFarmknobs'] + GotKnobs
        saveCfg()
    else CurrentGetKnobs = CurrentGetKnobs + GotKnobs end
    
    Notify(notifyStr,1.5)
end)

task.spawn(function() --Fuck u Jam
    local Jam = MainUI.Initiator.Main_Game.Health.Jam
    if Jam then Jam.Volume = 0 end
    StarterGui.MainUI.Initiator.Main_Game.Health.Jam:Destroy()
    game:GetService("SoundService").Main.Jamming:Destroy()
	warn(Jam and 'Stupid Jam GO AWAY' or 'Ok there\'s not Jam')
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

if FastMode then 
    local HighestLoots,HighestPercent = {},0
    local GoldVal = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal

    local function ReStatistics()
        replicatesignal(LocalPlayer.Kill)
        RemotesFolder.Statistics:FireServer()
    end
    
    local function InitFastFarm()
        Notify('点击选择行为',math.huge,{
            Button1 = '重开',
            Button2 = '返回大厅',
            Callback = function(choice)
                local Remote = choice == '重开' and RemotesFolder.PlayAgain or RemotesFolder.Lobby
                Notify(choice..'中...',10)
                Remote:FireServer()
            end
        })
        LocalPlayer.CharacterAdded:Connect(ReStatistics)
        antiafk(); ReStatistics()
    end

    if GoldVal.Value ~= 0 then Notify('已自动开始farm.',10); InitFastFarm(); return end

    local function CheckLoot(Loot,Percent)
        if not Loot:GetAttribute('LoadModule') then HighestLoots[Loot] = {}
        else
            local Parent = table.find(HighestLoots,Loot.Parent)
            if Parent then table.insert(HighestLoots[Parent],Loot)
            else return Loot end
        end
    end

    local function OpenLoot(Loot)
        local Childs = Loot:GetChildren()
        if #Childs == 0 then return end

        for _,child in pairs(Childs) do
            if not child:IsA('ProximityPrompt') then continue end
            
            task.spawn(function() repeat LookToInteract(child:FindFirstAncestorWhichIsA('Model').PrimaryPart,child); task.wait() until GetLootSpawned(Loot) end)
        end
    end

    local function CheckRoom(room)
        if room.Name == '0' or not room:IsA('Model') then return end

        local LootItems = {}
    
        for _,Item in pairs(room:GetDescendants()) do
            if not Item:IsA('Model') or not Item:GetAttribute('LootPercent') or Item.Name == 'ChestBoxLocked' then continue end
            LootItems[Item] = Item:GetAttribute('LootPercent')
            HighestPercent = math.max(HighestPercent,Item:GetAttribute('LootPercent'))
        end
    
        for Loot,Percent in pairs(LootItems) do
            if Percent < HighestPercent then continue end
            local LootReturn = CheckLoot(Loot,Percent)
            if LootReturn then return LootReturn end
        end

        local SelectedLoot

        for Loot,Child in pairs(HighestLoots) do
            if not Child[1] or Child[1]:GetAttribute('LootPercent') < HighestPercent then continue end
            SelectedLoot = Loot; break
        end

        return SelectedLoot
    end

    local SelectedLoot = CheckRoom(workspace.CurrentRooms['1'])
    
    if SelectedLoot then
        TeleportPlayer(SelectedLoot.PrimaryPart.CFrame)
        RemotesFolder.PreRunShop:FireServer()
        for _,Loot in pairs(SelectedLoot:GetChildren()) do OpenLoot(Loot) end
        Notify('手动点击以开始farm',math.huge,{
            Button1 = '开始',
            Button2 = '取消',
            Callback = function(choice)
                if choice ~= '开始' then return end
                InitFastFarm()
            end
        })
        return
    else warn('L seed,trying to use slowMode...') end
end
--L SlowMode
if not ReplicatedStorage.GameData.PreRun.Value then warn('bruh u can\'t use slowmode rn'); Notify('请在开局前执行',10); return end

RemotesFolder:FindFirstChild("UseEnemyModule").OnClientEvent:Connect(function(entity)--HOW DARE U VOID AND RUSH
    if entity ~= 'Void' then return end
    task.wait(1.5); warn('HOW DARE U VOID')
    RemotesFolder.PreRunShop:FireServer(); CameraScript.Enabled = true; Voided = true

    repeat until workspace:FindFirstChild('RushMoving') or CurrentDoor():WaitForChild('Lock',0.1)
    warn(workspace:FindFirstChild('RushMoving') and 'Oh no rush is coming,RUN!' or 'I hate the lock bruh'); StopFarming = true
end)

RemotesFolder:FindFirstChild("PlayerDied").OnClientEvent:Connect(function()--What?
    warn('HOW BRO'); Statistics(); StopFarming = true
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