for _,gener in pairs(workspace.GameplayFolder.Rooms.SearchlightsEndingP.Interactables:GetChildren()) do
    if gener.Name ~= 'PresetGenerator' then continue end
    local Fixed = gener.Fixed
    if Fixed.Value == 100 then continue end
    local rf = gener.RemoteFunction
    local re = gener.RemoteEvent
    local char = game.Players.LocalPlayer.Character
    char:PivotTo(gener.ProxyPart.CFrame)
    wait(0.5)
    gener.RemoteFunction:InvokeServer('')
    wait(0.1)
    repeat
        re:FireServer('fix')
        wait(0.1)
    until Fixed.Value == 100
end