local QBCore = exports["qb-core"]:GetCoreObject()

local function addCash(src, amount)
	local Player = QBCore.Functions.GetPlayer(src)
	Player.Functions.AddMoney("cash", amount)
end

local function removeCash(src, amount)
	local Player = QBCore.Functions.GetPlayer(src)
	Player.Functions.RemoveMoney("cash", amount)
end

local function getCash(src)
	local Player = QBCore.Functions.GetPlayer(src)
	return Player.PlayerData.money["cash"] or 0
end

exports("addCash", addCash)
exports("removeCash", removeCash)
exports("getCash", getCash)

AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
	if not player then
		return
	end
	local citizenid = player.PlayerData.citizenid
	local charInfo = player.PlayerData.charinfo
	local playerSrc = player.PlayerData.source
	exports.pefcl:loadPlayer(playerSrc, {
		source = playerSrc,
		identifier = citizenid,
		name = charInfo.firstname .. " " .. charInfo.lastname,
	})
	player.Functions.SyncMoney()
end)

RegisterNetEvent("qb-pefcl:server:UnloadPlayer", function(source)
	local src = source
	exports.pefcl:unloadPlayer(src)
end)

RegisterNetEvent("qb-pefcl:server:SyncMoney", function(source)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	player.Functions.SyncMoney()
end)

AddEventHandler("onServerResourceStart", function(resName)
	if resName ~= GetCurrentResourceName() then
		return
	end

	local players = QBCore.Functions.GetQBPlayers()

	for _, v in pairs(players) do
		exports.pefcl:loadPlayer(v.PlayerData.source, {
			source = v.PlayerData.source,
			identifier = v.PlayerData.citizenid,
			name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
		})
		v.Functions.SyncMoney()
	end
end)
