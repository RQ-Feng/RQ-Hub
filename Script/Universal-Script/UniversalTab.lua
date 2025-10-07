Tabs['UI Settings'] = Window:AddTab('设置')
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('菜单')
MenuGroup:AddButton({
    Text = '关闭界面',
    DoubleClick = true,
    Func = function()
        Library:Unload()
    end
})
MenuGroup:AddToggle('KeybindVisible', {
    Text = '键位显示',
    Default = true,
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Linoria鼠标",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end
})
MenuGroup:AddLabel('菜单按键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = '菜单键'
})
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(function()
    if WatermarkConnection then
        WatermarkConnection:Disconnect()
    end
    Library.Unloaded = true
    print('已关闭!')
end)
Library.KeybindFrame.Visible = true
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('CFHub/Theme')
SaveManager:SetFolder('CFHub/' .. ScriptPath("/") and not game_not_support or'CFHub/Universal')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
local MenuInfo = Tabs['UI Settings']:AddRightGroupbox('信息')
MenuInfo:AddLabel('欢迎!' .. game.Players.LocalPlayer.Name)
MenuInfo:AddLabel('您的注入器:' .. identifyexecutor())
MenuInfo:AddLabel('当前游戏:' .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
MenuInfo:AddLabel('游戏ID为:' .. game.GameId)
MenuInfo:AddLabel('位置ID为:' .. game.PlaceId)