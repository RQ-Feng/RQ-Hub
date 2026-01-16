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

IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
    ESPConfig.Type = ESPConfig.Type or "Adornment"
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
--------------------------------------------------Notify
local ScreenGui,MainWindow
local NotifyShowPosition
local NotifyHidePosition
local Title,Content

local function MakeNotifyScreenGui()
    local GuiName = 'RQHub_NotifyScreenGui'
    local CurrentNotifyGui = game.CoreGui:FindFirstChild(GuiName)
    if not CurrentNotifyGui then 
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = game.CoreGui
        ScreenGui.Name = GuiName
    
        MainWindow = Instance.new("CanvasGroup")
        MainWindow.GroupTransparency = 1
        MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
        MainWindow.Size = UDim2.new(0.15, 30, 0.1, 20)
        MainWindow.BorderColor3 = Color3.fromRGB(27, 42, 53)
        MainWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        MainWindow.Name = "MainWindow"
        MainWindow.Parent = ScreenGui
        Instance.new("UICorner",MainWindow).CornerRadius = UDim.new(0, 15)
    
        local Frame = Instance.new("Frame")
        Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        Frame.Size = UDim2.new(1, -15, 1, -15)
        Frame.BorderColor3 = Color3.fromRGB(27, 42, 53)
        Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Frame.Name = "Frame"
        Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        Frame.Parent = MainWindow
        Instance.new("UICorner",Frame).CornerRadius = UDim.new(0, 15)
    
        Title = Instance.new("TextLabel")
        Title.LayoutOrder = 0
        Title.RichText = true
        Title.TextScaled = true
        Title.Selectable = false
        Title.Font = Enum.Font.Nunito
        Title.AnchorPoint = Vector2.new(0.5, 0.5)
        Title.Size = UDim2.new(1, 0, 0.35, 0)
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0.5, 0, 0.75, 0)
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Name = "Title"
        Title.Parent = Frame
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = Frame
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 5)
            
        Content = Instance.new("TextLabel")
        Content.Name = "Content"
        Content.Size = UDim2.new(0.85, 0, 0.65, 0)
        Content.LayoutOrder = 1
        Content.AnchorPoint = Vector2.new(0.5, 0.5)
        Content.TextColor3 = Color3.fromRGB(255, 255, 255)
        Content.Font = Enum.Font.Nunito
        Content.RichText = true
        Content.TextScaled = true
        Content.BackgroundTransparency = 1
        Content.Parent = Frame
    else
        ScreenGui = CurrentNotifyGui
        MainWindow = ScreenGui.MainWindow
        local Frame = MainWindow.Frame
        Title,Content = Frame.Title,Frame.Content
    end
    
    MainWindow.Position = UDim2.new(0.5, 0, 0.8, (IsOnMobile and -50 or -100))
    NotifyShowPosition = MainWindow.Position 
    NotifyHidePosition = NotifyShowPosition - UDim2.new(0,0,0,15)
    MainWindow.Position = NotifyHidePosition

    ScreenGui:GetAttributeChangedSignal('Showing'):Connect(function()
        local Showing = ScreenGui:GetAttribute('Showing')
        TweenService:Create(MainWindow,TweenInfo.new(0.2,Enum.EasingStyle.Sine),{
            Position = Showing and NotifyShowPosition or NotifyHidePosition,
            GroupTransparency = Showing and 0.1 or 1
        }):Play()
    end); ScreenGui:SetAttribute('Showing',true)

    return ScreenGui
end

function Notify(NotifyCfg)
    local ControlNotify = {}
    MakeNotifyScreenGui()
    if not NotifyCfg then return end

    function ControlNotify:Set(newCfg)
        ScreenGui:SetAttribute('Showing',true)
        Title.Text = tostring(newCfg['Text'])
        Content.Text = tostring(newCfg['Content'])
    end

    function ControlNotify:Close()
        ScreenGui:SetAttribute('Showing',false)
    end

    NotifyCfg = {
        Text = NotifyCfg['Text'] or 'Text',
        Content = NotifyCfg['Content'] or 'Content'
    }; ControlNotify:Set(NotifyCfg)

    return ControlNotify
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
        if not prompt.Enabled then return end
    
        local originalHold = prompt.HoldDuration
        local originalLineOfSight = prompt.RequiresLineOfSight
        
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0

        prompt:InputHoldEnd()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputHoldEnd()

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

local FullBrightEvent
local OldFBProps = {
    ['Brightness'] = 0,
    ['ClockTime'] = 14,
    ['FogEnd'] = 100000,
    ['GlobalShadows'] = true,
    ['OutdoorAmbient'] = Color3.new(0, 0, 0),
}

local function SetBright(value)
    Lighting.Brightness = value and 2 or OldFBProps['Brightness']
    Lighting.ClockTime = value and 14 or OldFBProps['ClockTime']
    Lighting.FogEnd = value and 100000 or OldFBProps['FogEnd']
    Lighting.GlobalShadows = if value then false else OldFBProps['GlobalShadows']
    Lighting.OutdoorAmbient = value and Color3.new(1, 1, 1) or OldFBProps['OutdoorAmbient'] 
end

function FullBright(Value)
    if not Value then if FullBrightEvent then FullBrightEvent:Disconnect() end; SetBright(false); return end
    for prop,value in pairs(OldFBProps) do Lighting[prop] = value end
    FullBrightEvent = AddConnection(Lighting.Changed,SetBright); SetBright(true)
end
--------------------------------------------------The behavior when OrionLib stop running.
task.spawn(function()
    repeat task.wait() until not OrionLib:IsRunning()
    if ScreenGui then
        ScreenGui:SetAttribute('Showing',false)
        task.wait(0.2)
        ScreenGui:Destroy() 
    end
    SetBright(false)
end)