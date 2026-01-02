-- DuplicationAmount = Number
-- AccountToDuplicateTo = USER_NAME
-- AntiLag = Boolean

repeat task.wait() until game:IsLoaded()

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService('TextChatService')
local Players = game:GetService("Players")
--// Function
function Notify(text,duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Revive Dupe Helper",
        Text = text,
        Duration = duration or 5
    })
end

if game.PlaceId ~= 6516141723 then Notify('Please execute in doors lobby.'); return end
if not AccountToDuplicateTo then Notify('Please enter the account\'s name that dupe revives to.'); return end

--// Player Variables
local LocalPlayer = Players.LocalPlayer

--// Game Data
local RevivesVal = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Revives.RevivesVal

--// Communication
local Communication = TextChatService.TextChannels.RBXGeneral
local PacketPrefix = 'Doors_Dupe_Revive_Command'
local function SendPacket(packet)
    Communication:SendAsync("", PacketPrefix..tostring(packet))
end

--// Remote
local RemotesFolder = ReplicatedStorage.RemotesFolder
local ObtainGiftedRevive = RemotesFolder.ObtainGiftedRevive
local ReviveFriend = RemotesFolder.ReviveFriend

--// Constants
local IsMainAccount = LocalPlayer.Name == AccountToDuplicateTo
local DuplicationCount = DuplicationAmount or 5000
local AntiLag = if AntiLag then AntiLag else true
local Title = "Revive Dupe Helper" .. (IsMainAccount and '(Main Account)' or '(Alt Account)')

ObtainGiftedRevive.OnClientInvoke = function(...) return true end

if AntiLag and RemotesFolder:FindFirstChild('Caption') then RemotesFolder.Caption:Destroy() end--Basic AntiLag

if IsMainAccount then
    TextChatService.MessageReceived:Connect(function(message: TextChatMessage)
        local packetData = message.Metadata
        local textSource = message.TextSource
    
        if
            not packetData or not textSource or
            packetData:sub(1, #PacketPrefix) ~= PacketPrefix or
            textSource.UserId == LocalPlayer.UserId
        then return end
        
        loadstring(packetData:sub(#PacketPrefix + 1))()
    end)    
    Notify("Init finish."); return 
end
SendPacket('Notify(\'Get alt account.\nName:' ..LocalPlayer.Name.. '\',10)')
if RevivesVal.Value <= 0 then
    SendPacket('game:GetService(\'ReplicatedStorage\').RemotesFolder.ReviveFriend:FireServer(\''..LocalPlayer.Name..'\')')
    setclipboard("game:GetService('ReplicatedStorage').RemotesFolder.ReviveFriend:FireServer('" .. LocalPlayer.Name .. "')")
    Notify('Waiting for a Revive...',30)
    repeat task.wait() until RevivesVal.Value > 0
end

if AntiLag then--Extra AntiLag
    local WhiteList_RemotesFolder = {'ObtainGiftedRevive','ReviveFriend'}
    for _,item in pairs(ReplicatedStorage:GetChildren()) do if item.Name ~= 'RemotesFolder' then item:Destroy() end end
    for _,item in pairs(RemotesFolder:GetChildren()) do if not table.find(WhiteList_RemotesFolder,item.Name) then item:Destroy() end end
end
    
for i = 1, 3 do Notify(`Duping in {4 - i} seconds...`,1) task.wait(1) end

for i = 1, DuplicationCount do ReviveFriend:FireServer(AccountToDuplicateTo) end

Notify('Duping completed!',5)