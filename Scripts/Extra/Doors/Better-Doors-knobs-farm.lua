local LobbyPlaceId,_GamePlaceId,DoorsGameId = 6516141723,6839171747,2440500124
if game.GameId ~= DoorsGameId then warn('Incorrect game'); return end

warn('Knobs farm is loaded!')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ByAutoRejoin,TryingReconnect = false,false
local StopFarming = false
local executor = identifyexecutor and tostring(identifyexecutor())
local StatisticsEvent,ReStatisticsEvent
local CurrentGetKnobs = 0

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

Notify('已加载',5)
--Character

local function SetCharVars(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(SetCharVars)
if not LocalPlayer.Character then--Get character
    Notify('等待Character中',5)
    SetCharVars(LocalPlayer.CharacterAdded:Wait())
    Notify('Character已加载',5)
else SetCharVars(LocalPlayer.Character) end

local RemotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")
local GameData = ReplicatedStorage:WaitForChild("GameData")

local executor_BlackList = {
    ['Xeno'] = 'fireproximityprompt'
}

--Basic functions
local function WaitChild(Parent,instName)
    if typeof(Parent) ~= 'Instance' or type(instName) ~= 'string' then return end
    local Cache
    repeat Cache = Parent:WaitForChild(instName,0.1) until Cache
    return Cache
end

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

--Farmer
warn('Start farming...')

StatisticsEvent = RemotesFolder.Statistics.OnClientEvent:Connect(function(table)
    warn('Got Statistics-knobs:',table['Knobs'][3])
    local GotKnobs = table['Knobs'][3]
    
    if GotKnobs == 0 then 
        Notify('无法获取knobs.\n自动重开.'); StopFarming = true
        if not ByAutoRejoin then NotifyRejoin(); return end
        return
     end

    CurrentGetKnobs = CurrentGetKnobs + GotKnobs

    local notifyStr = ('目前共获取 %d 个knobs.'):format(CurrentGetKnobs)
    
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
    repeat task.wait() until MainUI:FindFirstChild('ItemShop') and MainUI:FindFirstChild('ItemShop').Visible
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


if GameData.Floor.Value ~= 'Mines' then return Notify('不支持此Floor.') end
    
local GoldVal = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal
local Loots = {'Locker_Small','OldWoodenTable','Toolbox','Toolbox_Locked','Locker_Small_Locked'}

local function ReStatistics()
    warn('ReStatistics...')
    local realdied = false
    RemotesFolder:FindFirstChild("PlayerDied").OnClientEvent:Once(function() realdied = true end)
    repeat task.wait(0.1)
        if replicatesignal then replicatesignal(LocalPlayer.Kill) 
        else
            repeat task.wait() until Humanoid
            Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
    until realdied or StopFarming
    RemotesFolder.Statistics:FireServer()
end

local WhitelistRemotes = {'Statistics','PlayAgain','Lobby','PreRunShop','PlayerDied'}

local function AntiLag()
    LocalPlayer.PlayerGui:Destroy()
    for _,remote in pairs(RemotesFolder:GetChildren()) do
        if table.find(WhitelistRemotes,remote.Name) then continue end
        remote:Destroy()
    end
end

local function InitFarm()
    local AntiLagChose = false
    task.spawn(function() task.wait(30); AntiLagChose = true end)
    Notify('是否启用AntiLag\n(游戏GUI将会消失)',30,{
        Button1 = '是',
        Button2 = '否',
        Callback = function(choice)
            AntiLagChose = true
            if choice == '是' then AntiLag() end
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
            InitFarm()
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

CameraScript.Enabled = true

Notify('(测试)手动点击以开始farm',math.huge,{
    Button1 = '开始',
    Button2 = '取消',
    Callback = function(choice)
        if choice ~= '开始' then StatisticsEvent:Disconnect(); return end
        InitFarm()
    end
})