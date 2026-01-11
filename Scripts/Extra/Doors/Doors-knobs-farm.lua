local LobbyPlaceId,_GamePlaceId,DoorsGameId = 6516141723,6839171747,2440500124
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
local executor = identifyexecutor and tostring(identifyexecutor())
local StatisticsEvent,ReStatisticsEvent
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
local GameData = ReplicatedStorage:WaitForChild("GameData")

local executor_BlackList = {
    ['Xeno'] = 'fireproximityprompt'
}

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
    Notify('重进中...')

    local default = {
        "LightsOut",
        "Gloombat",
        "NoGuidingLight",
        "PlayerCrouchSlow",
        "PlayerSlowHealth",
        "TimothyMore",
        "DupeMost",
        "NoKeySound",
        "LeastHidingSpots",
        "ScreechFaster",
        "Fog",
        "HideTime",
        "FigureFaster",
        "ItemSpawnNone",
        "Jammin"
    }

    local fallback = {
        'Gloombat',
        'NoGuidingLight',
        'TimothyMore',
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
            Destination = 'Mines',
            Settings = {}
        })
        task.wait(1.2)--Wait for cooldown
    end

    CreateElevator(default)--150%
    CreateElevator(fallback)--120%
    CreateElevator({})--Final fallback--0%
    return
end

repeat task.wait() until game:GetService("ReplicatedFirst")._Loaded.Value--Wait for game loaded

if #Players:GetPlayers() > 1 then Notify('无法在多人游戏中使用',10); return end

--Interact things
local MainUI = WaitChild(LocalPlayer.PlayerGui,'MainUI')

local CameraScript,MovementScript; repeat --Waiting for scripts
    _suc,CameraScript,MovementScript = pcall(function() 
        CameraScript = MainUI.Initiator.Main_Game.Camera
        MovementScript = MainUI.Initiator.Main_Game.Movement
        return CameraScript,MovementScript
    end); task.wait()
until CameraScript and MovementScript

--Interact
local function BetterPrompt(prompt)
    if typeof(prompt) ~= 'Instance' or not prompt:IsA("ProximityPrompt") then warn("[BetterPrompt]:ProximityPrompt expected, got " .. typeof(prompt)); return end

    if not executor_BlackList[executor] or not executor_BlackList[executor]['fireproximityprompt'] then --no need to use fallback firepp
        fireproximityprompt(prompt); return 
    end
    
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

    if not executor_BlackList[executor] or not executor_BlackList[executor]['fireproximityprompt'] then --no need to use fallback firepp
        fireproximityprompt(interactPrompt); return 
    end
    CameraScript.Enabled = false
    workspace.CurrentCamera.FieldOfView = 120
    workspace.CurrentCamera.CFrame = CFrame.lookAt(HumanoidRootPart.Position,targetPart.Position)
    BetterPrompt(interactPrompt)
end
--Important things getter
local function LatestRoom()
    return GameData.LatestRoom.Value
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

local function GetGoldPile(GoldPile)--Need to teleport manually
    print(GoldPile,GoldPile.Parent)
    if not GoldPile or GoldPile.Name ~= 'GoldPile' then return end
    warn(GoldPile,GoldPile.Parent)
    local Hitbox = WaitChild(GoldPile,'Hitbox')
    local LootPrompt = WaitChild(GoldPile,'LootPrompt')
    repeat LookToInteract(Hitbox,LootPrompt); task.wait() until not GoldPile or not GoldPile.Parent
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

local function NotifyRejoin()
    if StatisticsEvent then StatisticsEvent:Disconnect() end
    for i = 1,3 do
        Notify(i ~= 1 and '再次尝试重开...' or '重开中...',10)
        RemotesFolder.PlayAgain:FireServer()
        task.wait(10)
    end
end

local function GetLootHolder(Loot)
    if not Loot or not Loot:IsA('Model') then return true end
    return Loot:FindFirstChild('LootHolder')
end

local function OpenLoot(Loot)
    for _,prompt in pairs(Loot:GetDescendants()) do
        if not prompt:IsA('ProximityPrompt') then continue end
        local promptModel = prompt:FindFirstAncestorWhichIsA('Model')
        while not GetLootHolder(promptModel) do
            LookToInteract(promptModel.PrimaryPart,prompt)
            task.wait() 
        end; prompt.Enabled = false
    end
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
            ByAutoRejoin = false
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
warn(FastMode and 'W' or 'L','executor:',executor or '<this executor EVEN can\'t use identifyexecutor,so L.>')

Notify('是否清除累计记录?',30,{
	Button1 = '是',
	Button2 = '否',
	Callback = function(choice)
		if choice ~= '是' then return end
        cfg = defaultCfg; saveCfg()
	end
})

StatisticsEvent = RemotesFolder.Statistics.OnClientEvent:Connect(function(table)
    warn('Got Statistics-knobs:',table['Knobs'][3])
    local GotKnobs = table['Knobs'][3]
    local farmtime = math.floor(os.clock() - StartTime)
    
    if GotKnobs == 0 and FastMode then 
        Notify('无法获取knobs.\n自动重开.'); StopFarming = true
        if not ByAutoRejoin then NotifyRejoin(); return end
        return
     end

    if not FastMode then 
        Statisticsed = true
        cfg['AllFarmTime'] = cfg['AllFarmTime'] + farmtime
        cfg['AllFarmknobs'] = cfg['AllFarmknobs'] + GotKnobs
        saveCfg()
    else CurrentGetKnobs = CurrentGetKnobs + GotKnobs end

    local notifyStr = (FastMode and '目前共获取 %d 个knobs.' or '共获取 %d 个knobs,共用时 %d 秒.\n此次用时 %d 秒.')
    :format((FastMode and CurrentGetKnobs or cfg['AllFarmknobs']),cfg['AllFarmTime'],farmtime)
    
    Notify(notifyStr,1)
end)

task.spawn(function() --Fuck u Jam
    local Jam = MainUI.Initiator.Main_Game.Health.Jam
    if Jam then Jam.Volume = 0 end
    pcall(function(...)
        game:GetService("SoundService").Main.Jamming:Destroy()
        StarterGui.MainUI.Initiator.Main_Game.Health.Jam:Destroy()
    end)
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
    if GameData.Floor.Value ~= 'Mines' then return Notify('不支持此Floor.') end
    
    local GoldVal = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal
    local Loots = {'Locker_Small','OldWoodenTable','Toolbox','Toolbox_Locked','Locker_Small_Locked'}

    local function ReStatistics()
        replicatesignal(LocalPlayer.Kill)
        RemotesFolder.Statistics:FireServer()
    end

    local WhitelistRemotes = {'Statistics','PlayAgain','Lobby','PreRunShop'}

    local function FastMode_AntiLag()
        LocalPlayer.PlayerGui:Destroy()
        for _,remote in pairs(RemotesFolder:GetChildren()) do
            if table.find(WhitelistRemotes,remote.Name) then continue end
            remote:Destroy()
        end
    end
    
    local function InitFastFarm()
        local AntiLagChose = false
        task.spawn(function() task.wait(30); AntiLagChose = true end)
        Notify('是否启用AntiLag\n(游戏GUI将会消失)',30,{
            Button1 = '是',
            Button2 = '否',
            Callback = function(choice)
                AntiLagChose = true
                if choice ~= '是' then return end
                FastMode_AntiLag()
            end
        })
        repeat task.wait() until AntiLagChose
        local GoldPicked = ReplicatedStorage.GameStats:FindFirstChild('Player_' .. LocalPlayer.Name).Total.GoldPicked
        Notify('当前金币:' .. GoldPicked.Value .. '\n点击选择行为',math.huge,{
            Button1 = '重开',
            Button2 = '返回大厅',
            Callback = function(choice)
                local Remote = choice == '重开' and RemotesFolder.PlayAgain or RemotesFolder.Lobby
                Notify(choice..'中...',10)
                StopFarming = true
                if ReStatisticsEvent then ReStatisticsEvent:Disconnect() end
                Remote:FireServer()
            end
        })
        ReStatisticsEvent = LocalPlayer.CharacterAdded:Connect(ReStatistics)
        antiafk(); ReStatistics()
    end

    if GoldVal.Value ~= 0 then 
        Notify('手动点击以开始farm',math.huge,{
            Button1 = '开始',
            Button2 = '取消',
            Callback = function(choice)
                if choice ~= '开始' then StatisticsEvent:Disconnect(); return end
                InitFastFarm()
            end
        }); return 
    end

    if not GameData.PreRun.Value or LatestRoom() ~= 0 then warn('bruh u can\'t use slowmode rn')
        Notify('请在开局前执行',60,{
            Button1 = '重开',
            Button2 = '取消',
            Callback = function(choice) if choice == '重开' then NotifyRejoin(); return else StatisticsEvent:Disconnect() end end
        }); return
    end

    -- local Tnum,Lnum = 0,0
    -- local function addnum(inst,num) Instance.new('Highlight',inst); return num + 1 end
    -- for _,item in pairs(CurrentRoom():GetDescendants()) do
    --     if item.Name == 'Toolbox_Locked' then Tnum = addnum(item,Tnum) end
    --     if item.Name == 'Locker_Small_Locked' then Lnum = addnum(item,Lnum) end
    -- end
    -- if Tnum + Lnum <= 1 then warn('L seed,replaying...'); NotifyRejoin(); return end


    --ActivateEventPrompt
    
    TeleportPlayer(CFrame.new(CurrentDoor():FindFirstChild('Collision').Position  + Vector3.new(82,-10,-80)))
    --RemotesFolder.PreRunShop:FireServer({'Lockpick'},false)
    RemotesFolder.PreRunShop:FireServer({},false)

    while GameData.PreRun.Value do
        if (workspace.CurrentRooms["0"].StarterElevator.ElevatorCar.ElevatorRoot.Position - HumanoidRootPart.Position).Magnitude < 12 then
            TeleportPlayer(CFrame.new(Vector3.new(330,-13,-280)))
        end; task.wait()
    end
    
    local GoldPiles = {}
    for _,Loot in pairs(workspace.CurrentRooms['1']:WaitForChild('Assets'):GetChildren()) do--Extra gold gainer
        local Name = Loot.Name
        if not table.find(Loots,Name) or (Loot.PrimaryPart.Position - HumanoidRootPart.Position).Magnitude > 20 then continue end
        OpenLoot(Loot); task.spawn(function()
            if Loot:WaitForChild('GoldPile',5) then table.insert(GoldPiles,Loot.GoldPile) end
        end)
    end
    task.wait(1)
    for _,gold in pairs(GoldPiles) do GetGoldPile(gold) end

    for _,Loot in pairs(workspace.CurrentRooms['0']:WaitForChild('Assets'):GetChildren()) do--Normal gold gainer
        local Name = Loot.Name
        if not table.find(Loots,Name) then continue end
    end

    CameraScript.Enabled = true

    Notify('(测试)手动点击以开始farm',math.huge,{
        Button1 = '开始',
        Button2 = '取消',
        Callback = function(choice)
            if choice ~= '开始' then StatisticsEvent:Disconnect(); return end
            InitFastFarm()
        end
    })
    return
end
--L SlowMode
if not GameData.PreRun.Value then 
    warn('bruh u can\'t use slowmode rn')
    Notify('请在开局前执行',math.huge,{
        Button1 = '重开',
        Button2 = '取消',
        Callback = function(choice) if choice == '重开' then NotifyRejoin(); return else StatisticsEvent:Disconnect() end end
    }); return
end
MovementScript.Enabled = false

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

task.spawn(function()--Open doors loop - fallback
    repeat task.wait() until Character
    repeat
        local Assets = WaitChild(CurrentRoom(),'Assets')
        local door = CurrentDoor()

        local function GetDoorLockedPart()
            local Lock = door:WaitForChild('Lock',0.1)
            return (Lock and Lock.Parent ~= nil) and Lock or nil
        end

        for _,Item in pairs(Assets:GetDescendants()) do
            if Item.Name == 'GoldPile' then TeleportPlayer(Item.CFrame); GetGoldPile(Item) end
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