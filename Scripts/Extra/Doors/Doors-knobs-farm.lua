local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LobbyPlaceId = 6516141723

local cfgName = 'doors_knobs_farm_cfg.json'
if not isfile(cfgName) then writefile(cfgName,'') end

local defaultCfg = {
    ["AutoFarm"] = true,
    ['LatestExitReason'] = '',
}

local cfg = HttpService:JSONDecode(readfile(cfgName)) or defaultCfg

if not game.GameId ~= 2440500124 or cfg['LatestExitReason'] == 'Manage' then
    game:GetService('CoreGui'):SetCore('SendNotification', {
        Title = "Knob farm",
        Text = "已关闭",
        Duration = 5
    })
    return
end

local function CurrentDoor()
    return workspace.CurrentRooms[game:GetService("ReplicatedStorage").GameData.LatestRoom.Value]:FindFirstChild('Door')
end

local function TeleportPlayer(Vector3Pos)
    if HumanoidRootPart then HumanoidRootPart.CFrame = CFrame.new(Vector3Pos) end
end

repeat
    if CurrentDoor() then TeleportPlayer(CurrentDoor().Position) end
    task.wait(0.1) 
until CurrentDoor():WaitForChild('Lock',5)

ReplicatedStorage.RemotesFolder.Statistics:FireServer()
ReplicatedStorage.RemotesFolder.PlayAgain:FireServer()

queue_on_teleport('loadstring("https://raw.githubusercontent.com/RQ-Feng/roblox-script/refs/heads/main/By-myself/Doors-knobs-farm.lua")()')

game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    cfg['LatestExitReason'] = 'GotError'
	writefile(cfgName, HttpService:JSONEncode(cfg))
    TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

game:GetService("Players").PlayerRemoving:Connect(function()
    cfg['LatestExitReason'] = 'Manage'
    writefile(cfgName, HttpService:JSONEncode(cfg))
end)