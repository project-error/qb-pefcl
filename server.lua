local QBCore = exports['qb-core']:GetCoreObject()

local function addCash(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', amount)
end

local function removeCash(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney('cash', amount)
end

local function getCash(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.money["cash"] or 0
end

exports("addCash", addCash)
exports("removeCash", removeCash)
exports("getCash", getCash)

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local citizenid = player.PlayerData.citizenid
    local charInfo = player.PlayerData.charinfo
    local playerSrc = player.PlayerData.source
    exports.pefcl:loadPlayer({
        source = playerSrc,
        identifier = citizenid,
        name = charInfo.firstname.." "..charInfo.lastname,
      })
end)

AddEventHandler('QBCore:Client:OnPlayerUnload', function(src)
    exports.pefcl:unloadPlayer(src)
end)