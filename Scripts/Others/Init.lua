--------------------------------------------------Checker
if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))() end
if not ESPLibrary then ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))() end--lib
if not RQHub then warn('Checklist not success,return.') return end
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
--------------------------------------------------Other important 
LocalPlayer = Players.LocalPlayer
Character = LocalPlayer.Character
LocalPlayer.CharacterAdded:Connect(function(newchar) char = newchar end)
--------------------------------------------------ESP
local CurrentEspSetting = RQHub['ESPSetting']
local ESPElements = {}

function AddESP(ESPConfig)
    if not ESPConfig.inst then return end
    ESPConfig.value = ESPConfig.value or true
    ESPConfig.Type = ESPConfig.Type or "Highlight"

    local ESPElement = ESPLibrary:Add({
        Name = ESPConfig.inst.Name,
        Model = ESPConfig.inst,
        Color = CurrentEspSetting['Color'],
        MaxDistance = inf,
        TextSize = CurrentEspSetting['TextSize'],
        ESPType = ESPConfig.Type
    })
    table.insert(ESPElements,ESPElement)
    repeat task.wait() until not ESPConfig.value or not OrionLib:IsRunning()
    table.remove(ESPElements,table.find(ESPElements,ESPElement))
    ESPElement:Destroy()
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
    Value = Value or true
    local event = signal:Connect(func)
    repeat task.wait() until not OrionLib:IsRunning() or not Value
    event:Disconnect()
end