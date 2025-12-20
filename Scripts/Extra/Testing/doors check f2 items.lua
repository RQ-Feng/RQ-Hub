repeat wait() until workspace.CurrentRooms and workspace.CurrentRooms:FindFirstChild('1')
local bool,Tnum,Lnum = false,0,0

local function addnum(inst,num)
    Instance.new('Highlight',inst)
    bool = true; return num + 1
end

for _,v in pairs(workspace.CurrentRooms:GetDescendants()) do
    if v.Name == 'Toolbox_Locked' then Tnum = addnum(v,Tnum) end
    if v.Name == 'Locker_Small_Locked' then Lnum = addnum(v,Lnum) end
end
warn('Item:',bool,Tnum,Lnum)
if not bool or Tnum + Lnum <= 1 then game.ReplicatedStorage.RemotesFolder.PlayAgain:FireServer() end