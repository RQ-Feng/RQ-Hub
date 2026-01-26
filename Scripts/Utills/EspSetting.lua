local checklist = {OrionLib,ESPLibrary,RQHub}; if not checklist[3] then return end

local ESPSettingTabs = {}
task.spawn(function()
	repeat task.wait() until OrionLib.MainWindows[1]

	local GlobalESPSetting = ESPLibrary.GlobalConfig
	local CurrentEspSetting = RQHub['ESPSetting']

    local MainWindows = OrionLib.MainWindows
	for _,MainWindow in pairs(MainWindows) do
		if ESPSettingTabs[table.find(MainWindows,MainWindow)] then continue end

		local ESPSetting = MainWindow:MakeTab({
			Name = "ESP设置",
			Icon = "rbxassetid://4483345998"
		})
		ESPSetting:AddToggle({
			Name = "忽略角色",
			Flag = 'ESPIgnoreCharacter',
			Default = false,
			Save = true,
			Callback = function(value) GlobalESPSetting['IgnoreCharacter'] = value end
		})
		ESPSetting:AddToggle({
			Name = "彩虹特效",
			Flag = 'ESPRainbow',
			Default = true,
			Save = true,
			Callback = function(value) GlobalESPSetting['Rainbow'] = value end
		})
		ESPSetting:AddToggle({
			Name = "距离显示",
			Default = true,
			Flag = 'ESPDistance',
			Save = true,
			Callback = function(value) GlobalESPSetting['Distance'] = value end
		})
		ESPSetting:AddDropdown({
			Name = "字体",
			Save = true,
			Flag = 'Font',
			Default = "RobotoCondensed",
			Options = {
				'RobotoCondensed',
				'Code',
                'SourceSansSemibold',
				'Cartoon',
                'FredokaOne'
			},
			Callback = function(font) GlobalESPSetting['Font'] = Enum.Font[font] end   
		})		
		ESPSetting:AddSlider({
			Name = "文字大小",
    		Save = true,
			Flag = 'FontSize',
			Min = 15,
			Max = 50,
			Default = 17,
			Color = Color3.fromRGB(85, 170, 127),
			Increment = 1,
			ValueName = "",
			Callback = function(value) CurrentEspSetting['TextSize'] = value if RefreshESP then RefreshESP() end end
		})
		ESPSetting:AddToggle({
			Name = "箭头显示",
			Flag = 'ESPArrows',
			Default = false,
			Save = true,
			Callback = function(value) GlobalESPSetting['Arrows'] = value end
		})
		ESPSetting:AddToggle({
			Name = "追踪线",
			Flag = 'ESPTracers',
			Default = false,
			Save = true,
			Callback = function(value) GlobalESPSetting['Tracers'] = value end
		})

		table.insert(ESPSettingTabs,table.find(MainWindows,MainWindow),ESPSetting)
	end
end)