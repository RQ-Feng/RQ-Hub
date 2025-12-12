-- DuplicationAmount = Number
-- AccountToDuplicateTo = USER_NAME
-- AntiSomeLag = Boolean

--// Function
local function Notify(text,duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Title or "Revive Dupe Helper",
        Text = text,
        Duration = duration or 5
    })
end

if game.PlaceId ~= 6516141723 then Notify('Please execute in doors lobby.') return end
if not DuplicationAmount or not AntiSomeLag or not AccountToDuplicateTo then Notify('Please enter the variables.') return end

--// Remote
local RemotesFolder = game:GetService("ReplicatedStorage").RemotesFolder
local ObtainGiftedRevive = RemotesFolder.ObtainGiftedRevive
local ReviveFriend = RemotesFolder.ReviveFriend

--// Player Variables
local LocalPlayer = game:GetService("Players").LocalPlayer

--// Game Data
local RevivesVal = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Revives.RevivesVal

--// Constants
local IsMainAccount = LocalPlayer.Name == AccountToDuplicateTo
local DuplicationCount = DuplicationAmount or 5000
local Title = "Revive Dupe Helper" .. (IsMainAccount and '(Main Account)' or '(Alt Account)')

if AntiSomeLag then game:GetService("ReplicatedStorage").RemotesFolder.Caption:Destroy() end

ObtainGiftedRevive.OnClientInvoke = function(...) return true end

if IsMainAccount then Notify("Init finish.") return end

if RevivesVal.Value <= 0 then
    Notify('Waiting for a Revive...',30)
    setclipboard("game:GetService('ReplicatedStorage').RemotesFolder.ReviveFriend:FireServer('" .. LocalPlayer.Name .. "')")
    repeat task.wait() until RevivesVal.Value > 0
end
    
for i = 1, 3 do Notify(`Duping in {4 - i} seconds...`,1) task.wait(1) end

for i = 1, DuplicationCount do ReviveFriend:FireServer(AccountToDuplicateTo) end

Notify('Duping completed!',5)