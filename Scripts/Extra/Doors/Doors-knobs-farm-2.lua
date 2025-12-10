function TableVisualization(Table)
	if type(Table) ~= 'table' then return end
	warn('table可视化输出:')
	local function forTable(ForTable,arg)
		arg = arg or ''
		for i,v in pairs(ForTable) do
			if type(v) == 'table' then print(arg..'[\''..tostring(i)..'\']') forTable(v,arg..'∣')
			else print(arg..'[\''..tostring(i)..'\'] -> '..tostring(v)) end
		end
	end
	forTable(Table)
end


local function Notity(Text)
    local NotifyTable = {
        Title = 'Doors knobs farm',
        Text = Text,
        Duration = 5
    }
            
    game:GetService('StarterGui'):SetCore('SendNotification',NotifyTable)
end

if game.PlaceId ~= 6839171747 then return Notity('Init failed!') end
if type(replicatesignal) ~= 'function' then return Notity('Init failed!') end

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local RootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')

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

local function TeleportPlayer(Position)
    if not RootPart or type(Position) ~= 'vector' then return end
    if RootPart then RootPart.CFrame = CFrame.new(Position) end
end

local function ReStatistics()
    replicatesignal(LocalPlayer.Kill)
    game:GetService("ReplicatedStorage").RemotesFolder.Statistics:FireServer()
end

local HighestPercent,HighestLoots = 0,{}

local function CheckRoom(room)
    if room.Name == '0' or not room:IsA('Model') then return end
    local LootItems = {}

    for _,Item in pairs(room:GetDescendants()) do
        if not Item:IsA('Model') or not Item:GetAttribute('LootPercent') then continue end
        if Item.Name ~= 'ChestBoxLocked' then LootItems[Item] = Item:GetAttribute('LootPercent') end
    end

    local HighLoots = {}

    for k,v in pairs(LootItems) do
        HighestPercent = math.max(HighestPercent,v)
        if v < HighestPercent then continue end
        HighLoots[k] = k:GetAttribute('LootPercent')
    end
    
    for HighLoots,HighPercent in pairs(HighLoots) do if HighPercent >= HighestPercent then table.insert(HighestLoots,HighLoots) end end

    for _,HighestLoot in pairs(HighestLoots) do Instance.new('Highlight',HighestLoot) end
    TeleportPlayer(HighestLoots[1].PrimaryPart.Position)
end

for _,room in pairs(workspace.CurrentRooms:GetChildren()) do CheckRoom(room) end
LocalPlayer.CharacterAdded:Connect(ReStatistics)

antiafk(); ReStatistics()