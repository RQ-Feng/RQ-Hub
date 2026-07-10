local mods = {"AdminPanel"}
for i = 1,1000 do table.insert(mods,"PurePandemonium") end
game.ReplicatedStorage.Events.CreateLobby:InvokeServer(
    {
        LobbyAccess = "Public",
        LobbySize = 1,
        Gamemode = "Modifiers",
        Modifiers = mods
    }
)