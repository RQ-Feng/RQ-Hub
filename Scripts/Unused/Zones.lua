-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- https://lua.expert/
local t = {}
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

t.RoomPointer = Instance.new("ObjectValue")
t.AmbienceMuted = false
t.AmbienceFolder = game.Workspace.GameplayFolder.Ambience

local function AddSound(p1, p2) --[[ AddSound | Line: 12 | Upvalues: t (copy), ReplicatedStorage (copy), TweenService (copy) ]]
	if t.AmbienceFolder:FindFirstChild(p1) then
		return
	end

	local v1 = ReplicatedStorage.Sounds.Ambience:FindFirstChild(p1) or ReplicatedStorage.Events.AmbienceSound:InvokeServer(p1)

	v1.Parent = ReplicatedStorage.Sounds.Ambience

	local v2 = v1:Clone()

	if v2:FindFirstChild("Fadein") then
		v2.Parent = t.AmbienceFolder

		local Fadein = v2.Fadein

		Fadein:Play()
		Fadein.Ended:Connect(function() --[[ Line: 29 | Upvalues: v2 (ref) ]]
			v2:Play()
		end)
	else
		v2.Volume = 0
		v2.Parent = t.AmbienceFolder
		TweenService:Create(v2, TweenInfo.new(4, Enum.EasingStyle.Quint), {
			Volume = ReplicatedStorage.Sounds.Ambience[p1].Volume
		}):Play()
		v2:Play()
	end

	return v2
end

local function StopSound(p1) --[[ StopSound | Line: 49 | Upvalues: t (copy), TweenService (copy) ]]
	local v1 = t.AmbienceFolder:FindFirstChild(p1)

	if not v1 then
		return
	end

	v1.Parent = t.AmbienceFolder.Parent

	if v1:FindFirstChild("Fadeout") then
		if v1:FindFirstChild("Fadein") then
			v1.Fadein:Stop()
		end

		v1.Volume = 0

		local v2 = v1.Fadeout:Clone()

		v2.Parent = t.AmbienceFolder
		v2:Play()

		if v2.IsLoaded then
			v1:Destroy()
			game.Debris:AddItem(v2, v2.TimeLength + 5)
		else
			v2.Loaded:Connect(function() --[[ Line: 68 | Upvalues: v1 (copy), v2 (copy) ]]
				v1:Destroy()
				game.Debris:AddItem(v2, v2.TimeLength + 5)
			end)
		end
	else
		if v1:FindFirstChild("Fadein") then
			TweenService:Create(v1.Fadein, TweenInfo.new(2, Enum.EasingStyle.Linear), {
				Volume = 0
			}):Play()
		end

		TweenService:Create(v1, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			Volume = 0
		}):Play()
		game.Debris:AddItem(v1, 2)
	end

	task.wait(1)
end

t.CustomAmbienceSound = nil
t.ShopTheme = 1
t.ShopThemes = {
	4,
	4,
	4,
	1
}

local function f1(p1) --[[ Line: 106 ]]
	local sum = 0

	for i, v in ipairs(p1) do
		sum = sum + v
	end

	local v1 = math.random(1, sum)
	local sum2 = 0

	for i, v in ipairs(p1) do
		sum2 = sum2 + v

		if v1 <= sum2 then
			return i
		end
	end
end

local t2 = {
	Default = {
		Start = function() --[[ Start | Line: 127 ]] end,
		Stop = function() --[[ Stop | Line: 130 ]] end
	},
	Dredge = {
		Start = function() --[[ Start | Line: 136 | Upvalues: AddSound (copy) ]]
			AddSound("DredgeTheme")
		end,
		Stop = function(p1) --[[ Stop | Line: 139 | Upvalues: StopSound (copy) ]]
			StopSound("DredgeTheme")
		end
	},
	OxygenGardens = {
		Start = function() --[[ Start | Line: 151 | Upvalues: AddSound (copy) ]]
			AddSound("OxygenGardensTheme")
		end,
		Stop = function(p1) --[[ Stop | Line: 154 | Upvalues: StopSound (copy) ]]
			StopSound("OxygenGardensTheme")
		end
	},
	Ridge = {
		Start = function() --[[ Start | Line: 165 | Upvalues: ReplicatedStorage (copy), AddSound (copy) ]]
			if ReplicatedStorage.GameSettings.ModifiersRun.Value then
				AddSound("ModifiersRidgeTheme")
			else
				AddSound("RidgeTheme")
			end
		end,
		Stop = function(p1) --[[ Stop | Line: 173 | Upvalues: ReplicatedStorage (copy), StopSound (copy) ]]
			if ReplicatedStorage.GameSettings.ModifiersRun.Value then
				StopSound("ModifiersRidgeTheme")
			else
				StopSound("RidgeTheme")
			end
		end
	}
}
local t3 = {
	Default = {
		Start = function() --[[ Start | Line: 185 | Upvalues: AddSound (copy) ]]
			AddSound("FacilityAmbience")
		end,
		Stop = function() --[[ Stop | Line: 188 | Upvalues: StopSound (copy) ]]
			StopSound("FacilityAmbience")
		end
	},
	River = {
		Start = function() --[[ Start | Line: 193 | Upvalues: AddSound (copy) ]]
			AddSound("River")
		end,
		Stop = function() --[[ Stop | Line: 196 | Upvalues: StopSound (copy) ]]
			StopSound("River")
		end
	},
	Nothing = {
		Start = function() --[[ Start | Line: 201 | Upvalues: AddSound (copy) ]]
			AddSound("Nothing")
		end,
		Stop = function() --[[ Stop | Line: 204 | Upvalues: StopSound (copy) ]]
			StopSound("Nothing")
		end
	},
	BackArea = {
		Start = function() --[[ Start | Line: 209 | Upvalues: AddSound (copy) ]]
			AddSound("BackArea")
		end,
		Stop = function() --[[ Stop | Line: 212 | Upvalues: StopSound (copy) ]]
			StopSound("BackArea")
		end
	},
	Outskirts = {
		Start = function() --[[ Start | Line: 217 | Upvalues: AddSound (copy) ]]
			AddSound("Outskirts")
		end,
		Stop = function() --[[ Stop | Line: 220 | Upvalues: StopSound (copy) ]]
			StopSound("Outskirts")
		end
	},
	Muted = {
		Start = function() --[[ Start | Line: 225 ]] end,
		Stop = function() --[[ Stop | Line: 228 ]] end
	},
	["Shop theme"] = {
		Start = function() --[[ Start | Line: 233 | Upvalues: ReplicatedStorage (copy), AddSound (copy), t (copy), f1 (copy), t2 (copy) ]]
			if ReplicatedStorage.GameSettings.ModifiersRun.Value then
				AddSound("SebShopJazz")

				return
			end

			t.ShopTheme = f1(t.ShopThemes)
			print("theme: " .. t.ShopTheme)

			if t.AmbienceMusic then
				t2[t.AmbienceMusic].Stop()
			end

			AddSound("SebShopTheme" .. t.ShopTheme)
		end,
		Stop = function() --[[ Stop | Line: 247 | Upvalues: ReplicatedStorage (copy), StopSound (copy), t (copy), t2 (copy) ]]
			if ReplicatedStorage.GameSettings.ModifiersRun.Value then
				StopSound("SebShopJazz")

				return
			end

			if t.AmbienceMusic then
				t2[t.AmbienceMusic].Start()
			end

			StopSound("SebShopTheme" .. t.ShopTheme)
		end
	},
	["Deep Sea Ambience"] = {
		Start = function() --[[ Start | Line: 259 | Upvalues: AddSound (copy) ]]
			AddSound("Deep Sea Ambience")
		end,
		Stop = function() --[[ Stop | Line: 262 | Upvalues: StopSound (copy) ]]
			StopSound("Deep Sea Ambience")
		end
	},
	Ridge = {
		Start = function() --[[ Start | Line: 267 | Upvalues: AddSound (copy) ]]
			AddSound("Ridge")
		end,
		Stop = function() --[[ Stop | Line: 270 | Upvalues: StopSound (copy) ]]
			StopSound("Ridge")
		end
	},
	MaintenanceTunnels = {
		Start = function() --[[ Start | Line: 275 | Upvalues: AddSound (copy) ]]
			AddSound("MaintenanceTunnels")
		end,
		Stop = function() --[[ Stop | Line: 278 | Upvalues: StopSound (copy) ]]
			StopSound("MaintenanceTunnels")
		end
	},
	Sewers = {
		Start = function() --[[ Start | Line: 283 | Upvalues: AddSound (copy) ]]
			AddSound("Sewers")
		end,
		Stop = function() --[[ Stop | Line: 286 | Upvalues: StopSound (copy) ]]
			StopSound("Sewers")
		end
	},
	Dredge = {
		Start = function() --[[ Start | Line: 291 | Upvalues: AddSound (copy) ]]
			AddSound("Dredge")
		end,
		Stop = function() --[[ Stop | Line: 294 | Upvalues: StopSound (copy) ]]
			StopSound("Dredge")
		end
	},
	LavaCavern = {
		Start = function() --[[ Start | Line: 299 | Upvalues: AddSound (copy) ]]
			AddSound("LavaCavern")
		end,
		Stop = function() --[[ Stop | Line: 302 | Upvalues: StopSound (copy) ]]
			StopSound("LavaCavern")
		end
	},
	Mantle = {
		Start = function() --[[ Start | Line: 307 | Upvalues: AddSound (copy) ]]
			AddSound("Mantle")
		end,
		Stop = function() --[[ Stop | Line: 310 | Upvalues: StopSound (copy) ]]
			StopSound("Mantle")
		end
	},
	ChainSmokerArea = {
		Start = function() --[[ Start | Line: 315 | Upvalues: AddSound (copy) ]]
			AddSound("ChainsmokerDeathArea")
		end,
		Stop = function() --[[ Stop | Line: 318 | Upvalues: StopSound (copy) ]]
			StopSound("ChainsmokerDeathArea")
		end
	},
	BanlandsWind = {
		Start = function() --[[ Start | Line: 324 | Upvalues: AddSound (copy) ]]
			AddSound("BanlandsWind")
		end,
		Stop = function() --[[ Stop | Line: 327 | Upvalues: StopSound (copy) ]]
			StopSound("BanlandsWind")
		end
	},
	PainterRoom = {
		Start = function() --[[ Start | Line: 333 | Upvalues: AddSound (copy) ]]
			AddSound("PainterRoomMusic")
		end,
		Stop = function() --[[ Stop | Line: 336 | Upvalues: StopSound (copy) ]]
			StopSound("PainterRoomMusic")
		end
	},
	PainterDestroyed = {
		Start = function() --[[ Start | Line: 342 | Upvalues: AddSound (copy) ]]
			AddSound("PainterRoomDestroyedMusic")
		end,
		Stop = function() --[[ Stop | Line: 345 | Upvalues: StopSound (copy) ]]
			StopSound("PainterRoomDestroyedMusic")
		end
	},
	NAVIRoom = {
		Start = function() --[[ Start | Line: 351 | Upvalues: AddSound (copy) ]]
			AddSound("NaviRoom")
		end,
		Stop = function() --[[ Stop | Line: 354 | Upvalues: StopSound (copy) ]]
			StopSound("NaviRoom")
		end
	},
	Firewall = {
		Start = function() --[[ Start | Line: 360 ]] end,
		Stop = function() --[[ Stop | Line: 363 ]] end
	}
}

t.AmbiencePreset = "Default"
t.AmbienceMusic = "Default"
t.Main = nil
t.List = {}
t.Pointers = {}
t.CurrentRoom = nil
function t.init(p1) --[[ Line: 380 | Upvalues: t (copy), ReplicatedStorage (copy), t3 (copy) ]]
	t.Main = p1

	local function addZone(p1) --[[ addZone | Line: 383 | Upvalues: t (ref) ]]
		task.spawn(function() --[[ Line: 386 | Upvalues: p1 (copy), t (ref) ]]
			local Enter = p1:WaitForChild("Enter")

			repeat
				task.wait()
			until Enter.Value

			local v1 = Enter.Value
			local v2 = script:FindFirstChild(p1.Name):Clone()

			v2.Parent = v1
			v2:PivotTo(p1.CollisionPart:GetPivot() * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(4, 0, 0))
			t.Pointers[v2] = v1
			table.insert(t.List, v2)
		end)
		task.spawn(function() --[[ Line: 400 | Upvalues: p1 (copy), t (ref) ]]
			local Exit = p1:WaitForChild("Exit")

			repeat
				task.wait()
			until Exit.Value

			local v1 = Exit.Value
			local v2 = script:FindFirstChild(p1.Name):Clone()

			v2.Parent = v1
			v2:PivotTo(p1.CollisionPart:GetPivot() * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(-4, 0, 0))
			t.Pointers[v2] = v1
			table.insert(t.List, v2)
		end)
	end

	for k, v in pairs(game.Workspace.GameplayFolder.Interactions:GetChildren()) do
		if v.Name == "NormalDoor" and v:GetAttribute("ProgressDoor") then
			addZone(v)
		end
	end

	local t2 = { "BigDoor", "NormalDoor", "DoubleDoor", "GraveyardGate", "CryptDoor", "LargeRoundDoor", "DoubleDoorSewer" }

	local function findDoor(p1) --[[ findDoor | Line: 432 | Upvalues: t2 (copy), addZone (copy) ]]
		local Entrances = p1:WaitForChild("Entrances", 1)

		if not p1:FindFirstChild("Entrances") then
			return
		end

		if not Entrances then
			return
		end

		local v1

		repeat
			v1 = Entrances:FindFirstChildOfClass("Model")
			task.wait()
		until v1

		local v2 = v1

		for k, v in pairs(t2) do
			local v3 = p1.Entrances:FindFirstChild(v)

			v2 = v3

			if v3 then
				break
			end
		end

		if not v2 then
			return
		end

		addZone(v2)
	end

	game.Workspace.GameplayFolder.Rooms.ChildAdded:Connect(function(p1) --[[ Line: 447 | Upvalues: findDoor (copy) ]]
		p1:WaitForChild("Entrances", 3)

		if not p1:FindFirstChild("Entrances") then
			return
		end

		findDoor(p1)
	end)

	for k, v in pairs(game.Workspace.GameplayFolder.Rooms:GetChildren()) do
		task.spawn(function() --[[ Line: 455 | Upvalues: findDoor (copy), v (copy) ]]
			findDoor(v)
		end)
	end

	game.Workspace.GameplayFolder.Rooms.ChildRemoved:Connect(function(p1) --[[ Line: 460 | Upvalues: t (ref) ]]
		for k, v in pairs(t.Pointers) do
			if v == p1 then
				t[k] = nil
			end
		end
	end)
	game["Run Service"]:BindToRenderStep("roomDetection", 205, function() --[[ Line: 468 | Upvalues: p1 (copy), t (ref), ReplicatedStorage (ref) ]]
		if p1.PlayerDead or not (p1.Root and p1.Root.Parent) then
			return
		end

		if #t.List == 0 then
			return
		end

		local v1 = RaycastParams.new()

		v1.FilterType = Enum.RaycastFilterType.Include
		v1.FilterDescendantsInstances = t.List

		local v2 = workspace:Raycast(p1.Root.Position, Vector3.new(0, -21, 0), v1)

		if v2 then
			local v3 = v2.Instance

			if not t.Pointers[v3] then
				task.spawn(function() --[[ Line: 482 | Upvalues: t (ref), v3 (ref) ]]
					for k, v in pairs(t.List) do
						if v == v3 then
							table.remove(t.List, k)
							v3:Destroy()

							return
						end
					end
				end)
			else
				local v4 = t.Pointers[v3]

				if t.CurrentRoom ~= v4 then
					local t2 = {}

					t2.Ambience = v4:GetAttribute("Ambience") or v4:GetAttribute("RoomFamily")
					t2.AmbienceMusic = v4:GetAttribute("AmbienceMusic") or v4:GetAttribute("RoomFamily")
					t2.RoomType = v4:GetAttribute("RoomType")
					t.ChangeZone(t2, v4)
					ReplicatedStorage.Events.ZoneChange:FireServer(v4)
				end
			end
		end
	end)
	t3.Default.Start()
	ReplicatedStorage.Events.ChangeSpeed.OnClientEvent:Connect(function(p1) --[[ Line: 507 ]] end)
	ReplicatedStorage.Events.Ambience.OnClientEvent:Connect(function(p1) --[[ Line: 512 | Upvalues: t (ref) ]]
		t.ChangeZone(p1)
	end)
	ReplicatedStorage.Events.ServerZoneChange.OnClientEvent:Connect(function(p1, p2) --[[ Line: 517 | Upvalues: t (ref) ]]
		t.ChangeZone(p1, p2)
	end)
end
function t.ChangeZone(p1, p2) --[[ Line: 524 | Upvalues: t (copy), t3 (copy), t2 (copy) ]]
	t.CurrentRoom = p2
	print("Room Name:", t.CurrentRoom)

	if p2 then
		t.RoomPointer.Value = p2
	end

	if not t3[p1.Ambience] then
		p1.Ambience = "Default"
	end

	if not t2[p1.AmbienceMusic] then
		p1.AmbienceMusic = "Default"
	end

	if p2 then
		task.spawn(function() --[[ Line: 547 | Upvalues: t (ref), p2 (copy) ]]
			repeat
				task.wait()
			until t.Main.LoadedIn

			t.Main.Swimming.TrackWaterPart(p2:WaitForChild("WaterPart", 0.1), p2:GetAttribute("Submerged"))
		end)
	end

	if p1.Ambience ~= t.AmbiencePreset then
		local AmbiencePreset = t.AmbiencePreset

		t.AmbiencePreset = p1.Ambience
		t3[AmbiencePreset].Stop()

		if t.AmbiencePreset ~= p1.Ambience then
			return
		end

		t3[t.AmbiencePreset].Start()
	end

	if t.Main.Data.GameSettings.MuteAmbienceMusic.Value < 1 then
		if p1.RoomType == "BufferStart" or p1.RoomType == "BufferEnd" then
			local AmbienceMusic = t.AmbienceMusic

			t.AmbienceMusic = "Default"
			t2[AmbienceMusic].Stop(p1.RoomType)
		else
			if t.AmbienceMusic == p1.AmbienceMusic then
				return
			end

			local AmbienceMusic = t.AmbienceMusic

			t.AmbienceMusic = p1.AmbienceMusic
			t2[AmbienceMusic].Stop(p1.RoomType)
		end

		if t.AmbienceMusic == p1.AmbienceMusic then
			t2[t.AmbienceMusic].Start()
		end

		return
	end

	if t.AmbienceMusic == "Default" then
		return
	end

	local AmbienceMusic = t.AmbienceMusic

	t.AmbienceMusic = "Default"
	t2[AmbienceMusic].Stop(p1.RoomType)

	if t.AmbienceMusic ~= p1.AmbienceMusic then
		return
	end

	t2[t.AmbienceMusic].Start()
end
function t.SwitchAmbience(p1) --[[ Line: 590 | Upvalues: t3 (copy), t (copy) ]]
	if not t3[p1.Ambience] then
		p1.Ambience = "Default"
	end

	if p1.Ambience == t.AmbiencePreset then
		return
	end

	local AmbiencePreset = t.AmbiencePreset

	t.AmbiencePreset = p1.Ambience
	t3[AmbiencePreset].Stop()

	if t.AmbiencePreset ~= p1.Ambience then
		return
	end

	t3[t.AmbiencePreset].Start()
end
function t.Mute() --[[ Line: 605 | Upvalues: t (copy) ]]
	t.AmbienceFolder.Parent = nil
end
function t.Unmute() --[[ Line: 609 | Upvalues: t (copy) ]]
	t.AmbienceFolder.Parent = game.Workspace
end
function t.CustomAmbience(p1) --[[ Line: 613 | Upvalues: t (copy), t3 (copy) ]]
	task.spawn(function() --[[ Line: 614 | Upvalues: p1 (copy), t (ref), t3 (ref) ]]
		if p1 then
			t.CustomAmbienceSound = p1
			t3[t.AmbiencePreset].Stop()
			print(p1)

			if not (t.CustomAmbienceSound and t3[t.CustomAmbienceSound]) then
				return
			end

			t3[t.CustomAmbienceSound].Start()
		else
			if t.CustomAmbienceSound then
				t3[t.CustomAmbienceSound].Stop()
			end

			t3[t.AmbiencePreset].Start()
		end
	end)
end

return t