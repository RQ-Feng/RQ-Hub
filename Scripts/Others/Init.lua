local checklist = {OrionLib,ESPLibrary,RQHub}; if #checklist ~= 3 then warn('Checklist not success,return.') return end
--------------------------------------------------Services
cloneref = type(cloneref) == 'function' and cloneref or function(...) return ... end
print('cloneref state')
Services = setmetatable({}, {
    __index = function(self, name)
        local success, cache = pcall(function() return cloneref(game:GetService(name)) end)
        if success then rawset(self, name, cache) return cache
        else error("Invalid Roblox Service: " .. tostring(name)) end
    end
})
print('Services metatable')
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
print('All services')
--------------------------------------------------ESP
local CurrentEspSetting = RQHub['ESPSetting']
local ESPElements = {}
print('Esp funcs')
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
print('Init:I\'m done!')
