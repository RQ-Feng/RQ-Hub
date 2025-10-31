if not ESPLibrary or not OrionLib then return end

--Need OrionLib
local ESPSettingTabs = {}
task.spawn(function()
	repeat task.wait() until OrionLib and OrionLib.MainWindows[1]
    local MainWindows = OrionLib.MainWindows
	for _,MainWindow in pairs(MainWindows) do
		if ESPSettingTabs[table.find(MainWindows,MainWindow)] then continue end

		local ESPSetting = MainWindow:MakeTab({
			Name = "ESP设置",
			Icon = "rbxassetid://4483345998"
		})
        OrionLib:Add
		-- ESPSetting:AddButton({
		-- 	Name = "关闭UI",
		-- 	Callback = function() OrionLib:Destroy() end
		-- })
		-- local Themes = {
		-- 	['暗色'] = "Dark",
		-- 	['浅色'] = "Light"
		-- }
		-- ESPSetting:AddDropdown({
		-- 	Name = "UI主题",
		-- 	Default = "暗色",
		-- 	Options = {"暗色","浅色"},
		-- 	Callback = function(Value)
		-- 		if not Themes[Value] then return end
		-- 		OrionLib:SetTheme(Themes[Value])
		-- 	end    
		-- })
		-- ESPSetting:AddLabel("此服务器上的游戏ID为:" .. game.GameId)
		-- ESPSetting:AddLabel("此服务器位置ID为:" .. game.PlaceId)
		-- ESPSetting:AddParagraph("此服务器UUID为:", game.JobId)
		-- ESPSetting:AddLabel("此服务器上的游戏版本为:version_" .. game.PlaceVersion)

		table.insert(ESPSettingTabs,table.find(MainWindows,MainWindow),ESPSetting)
	end
end)