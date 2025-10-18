others = Window:MakeTab({
    Name = "其他",
    Icon = "rbxassetid://4483345998"
})
others:AddLabel("此服务器上的游戏ID为:" .. game.GameId)
others:AddLabel("此服务器位置ID为:" .. game.PlaceId)
others:AddLabel("此服务器上的游戏版本为:version_" .. game.PlaceVersion)
others:AddParagraph("此服务器UUID为:", game.JobId)