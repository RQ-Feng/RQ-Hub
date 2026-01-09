--------------------------------------------------Checker
if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))() end
if not ESPLibrary then ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))() end
if not RQHub then RQHub = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/baseHub_table.lua'))() end
if not ExecutorChecker then ExecutorChecker = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/Utills/ExecutorChecker.lua'))() end
if not Window then Window = OrionLib:MakeWindow({
    IntroText = "RQHub-Alt",
    Name = 'RQHub | Alt window',
    SaveConfig = false
}) end
--------------------------------------------------Services
cloneref = type(cloneref) == 'function' and cloneref or function(...) return ... end

Services = setmetatable({}, {
    __index = function(self, name)
        local success, cache = pcall(function() return cloneref(game:GetService(name)) end)
        if success then rawset(self, name, cache) return cache
        else error("Invalid Roblox Service: " .. tostring(name)) end
    end
})

CoreGui = Services.CoreGui
Players = Services.Players
UserInputService = Services.UserInputService
TweenService = Services.TweenService
HttpService = Services.HttpService
MarketplaceService = Services.MarketplaceService
RunService = Services.RunService
TeleportService = Services.TeleportService
StarterGui = Services.StarterGui
GuiService = Services.GuiService
Lighting = Services.Lighting
ContextActionService = Services.ContextActionService
ReplicatedStorage = Services.ReplicatedStorage
GroupService = Services.GroupService
PathService = Services.PathfindingService
SoundService = Services.SoundService
Teams = Services.Teams
StarterPlayer = Services.StarterPlayer
InsertService = Services.InsertService
ChatService = Services.Chat
ProximityPromptService = Services.ProximityPromptService
ContentProvider = Services.ContentProvider
StatsService = Services.Stats
MaterialService = Services.MaterialService
AvatarEditorService = Services.AvatarEditorService
TextService = Services.TextService
TextChatService = Services.TextChatService
CaptureService = Services.CaptureService
VoiceChatService = Services.VoiceChatService
--------------------------------------------------Other important things
--[[ --PlaceInfo important table
{
	["Created"] = "Create time",
	["Updated"] = "Update time",
	["Name"] = "place name",
	["Description"] = "place description",
	["Creator"] =  {
		["CreatorTargetId"] = Creator id,
		["CreatorType"] = "User or Group",
		["HasVerifiedBadge"] = false,
		["Name"] = "creator name"
	},
	["ContentRatingTypeId"] = <is this game 13+?>,
	["IconImageAssetId"] = place icon ig,
}
]]
GameId,PlaceId = game.GameId,game.PlaceId
PlaceInfo = MarketplaceService:GetProductInfoAsync(PlaceId,Enum.InfoType.Asset)
PlaceName,PlaceDescription = PlaceInfo.Name,PlaceInfo.Description
PlaceIcon,PlaceCreator = PlaceInfo.IconImageAssetId,PlaceInfo.Creator['Name']

local function SetCharVars(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end

LocalPlayer = Players.LocalPlayer
LocalPlayer.CharacterAdded:Connect(SetCharVars)

if not LocalPlayer.Character then--Get character
    OrionLib:MakeNotification({
        Name = 'Character',
        Content = '等待Character中',
        Image = 'rbxassetid://7733658504',
        Time = 5
    })
    SetCharVars(LocalPlayer.CharacterAdded:Wait())
    OrionLib:MakeNotification({
        Name = 'Character',
        Content = 'Character已加载',
        Image = 'rbxassetid://7733715400',
        Time = 2
    })
else SetCharVars(LocalPlayer.Character) end

exec_name = identifyexecutor and identifyexecutor() or 'L_exec'
--------------------------------------------------ESP
local CurrentEspSetting = RQHub['ESPSetting']
local ESPElements = {}

function AddESP(ESPConfig)
    if not ESPConfig.inst then return end
    ESPConfig.value = ESPConfig.value or {['Value'] = true}
    ESPConfig.Type = ESPConfig.Type or "Highlight"
    ESPConfig.Color = ESPConfig.Color or CurrentEspSetting['Color']
    ESPConfig.Name = ESPConfig.Name or ESPConfig.inst.Name

    local ESPElement = ESPLibrary:Add({
        Name = ESPConfig.Name,
        Model = ESPConfig.inst,
        Color = ESPConfig.Color,
        MaxDistance = inf,
        TextSize = CurrentEspSetting['TextSize'],
        ESPType = ESPConfig.Type
    })

    table.insert(ESPElements,ESPElement)
    task.spawn(function()
        repeat task.wait() until not ESPConfig.value.Value or not ESPElement or not OrionLib:IsRunning()
        table.remove(ESPElements,table.find(ESPElements,ESPElement))
        if ESPElement then ESPElement:Destroy() end
    end)
    return ESPElement
end

function RefreshESP()
    for _,ESPElement in pairs(ESPElements) do
        for i,value in pairs(CurrentEspSetting) do
            ESPElement.CurrentSettings[i] = value
        end
    end
end
--------------------------------------------------Other functions
function AddConnection(signal,func,Value)
    Value = Value or {['Value'] = true}
    local event;event = signal:Connect(func)
    task.spawn(function() repeat task.wait() until not OrionLib:IsRunning() or not Value.Value; if event then event:Disconnect() end end)
    return event
end

if not ExecutorChecker['fireproximityprompt'] then
    function fireproximityprompt(prompt: ProximityPrompt)
        if not prompt:IsA("ProximityPrompt") then return error("ProximityPrompt expected, got " .. typeof(prompt)) end
    
        local originalEnabled = prompt.Enabled
        local originalHold = prompt.HoldDuration
        local originalLineOfSight = prompt.RequiresLineOfSight
        
        prompt.Enabled = true
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0

        prompt:InputHoldEnd()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputHoldEnd()

        prompt.Enabled = originalEnabled
        prompt.HoldDuration = originalHold
        prompt.RequiresLineOfSight = originalLineOfSight
    end
end

function SetPrompt(prompt,Distance)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = Distance or prompt.MaxActivationDistance
    end
end

function BetterPrompt(Distance,value)
    for _,prompt in pairs(workspace:GetDescendants()) do SetPrompt(prompt) end
    AddConnection(workspace.DescendantAdded,function(prompt)
        SetPrompt(prompt,Distance)
    end,value)
end

function FullBrightLite(Value)
    if not Value then return end
    local list = {Lighting.Ambient,Lighting.ColorShift_Bottom,Lighting.ColorShift_Top}
    local white,black = Color3.new(1, 1, 1),Color3.new(0, 0, 0)
    if Value.Value then for _,item in pairs(list) do item = white;AddConnection(Lighting.Changed,function() item = white end,Value) end
    else for _,item in pairs(list) do item = black end end
end