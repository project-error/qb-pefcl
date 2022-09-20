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

local function loadPlayer(src, citizenid, name)
	exports.pefcl:loadPlayer(src, {
		source = src,
		identifier = citizenid,
		name = name
	})
end

local function UniqueAccounts(player)
	local citizenid = player.PlayerData.citizenid
	local playerSrc = player.PlayerData.source
	local PlayerJob = player.PlayerData.job
	if Config.BusinessAccounts[PlayerJob.name] then
		if not exports.pefcl:getUniqueAccount(playerSrc, PlayerJob.name).data then
			local data = {
				name = tostring(Config.BusinessAccounts[PlayerJob.name].AccountName), 
				type = 'shared', 
				identifier = PlayerJob.name
			}
			exports.pefcl:createUniqueAccount(playerSrc, data)
		end
	end
	local accounts = exports.pefcl:getAccounts(playerSrc).data
	for k,v in pairs(accounts) do
		if Config.BusinessAccounts[v.ownerIdentifier] and v.ownerIdentifier == PlayerJob.name then
			local role = false
			if PlayerJob.grade.level >= Config.BusinessAccounts[v.ownerIdentifier].AdminRole then
				role = 'admin'
			elseif PlayerJob.grade.level >= Config.BusinessAccounts[v.ownerIdentifier].ContributorRole then
				role = 'contributor'
			end
			if not role then
				local data1 = {
					userIdentifier = citizenid,
					accountIdentifier = v.ownerIdentifier,
				}
				exports.pefcl:removeUserFromUniqueAccount(playerSrc, data1)
			elseif v.role ~= role then
				local data1 = {
					userIdentifier = citizenid,
					accountIdentifier = v.ownerIdentifier,
				}
				exports.pefcl:removeUserFromUniqueAccount(playerSrc, data1)
				if Config.BusinessAccounts[PlayerJob.name] then
					local role = false
					if PlayerJob.grade.level >= Config.BusinessAccounts[PlayerJob.name].AdminRole then
						role = 'admin'
					elseif PlayerJob.grade.level >= Config.BusinessAccounts[PlayerJob.name].ContributorRole then
						role = 'contributor'
					end
					if role then
						local data = {
							role = role,
							accountIdentifier = PlayerJob.name,
							userIdentifier = citizenid,
							source = playerSrc
						}
						exports.pefcl:addUserToUniqueAccount(playerSrc, data)
					end
				end
			end 
		elseif Config.BusinessAccounts[v.ownerIdentifier] and v.ownerIdentifier ~= PlayerJob.name then
			local data1 = {
				userIdentifier = citizenid,
				accountIdentifier = v.ownerIdentifier,
			}
			exports.pefcl:removeUserFromUniqueAccount(playerSrc, data1)
		elseif Config.BusinessAccounts[PlayerJob.name] and v.ownerIdentifier ~= PlayerJob.name then
			local data1 = {
				userIdentifier = citizenid,
				accountIdentifier = v.ownerIdentifier,
			}
			exports.pefcl:removeUserFromUniqueAccount(playerSrc, data1)
			if Config.BusinessAccounts[PlayerJob.name] then
				local role = false
				if PlayerJob.grade.level >= Config.BusinessAccounts[PlayerJob.name].AdminRole then
					role = 'admin'
				elseif PlayerJob.grade.level >= Config.BusinessAccounts[PlayerJob.name].ContributorRole then
					role = 'contributor'
				end
				if role then
					local data = {
						role = role,
						accountIdentifier = PlayerJob.name,
						userIdentifier = citizenid,
						source = playerSrc
					}
					exports.pefcl:addUserToUniqueAccount(playerSrc, data)
				end
			end
		end
	end
end


local function getCards(source)
	local Player = QBCore.Functions.GetPlayer(source)
	local cards = Player.Functions.GetItemsByName('visa')
	local retval = {}
	if cards then 
		for k, v in pairs(cards) do
			retval[#retval+1] = {
				id = v.info.id,
				holder = v.info.holder,
				number = v.info.number
			}
		end
	end
	return retval
end

local function giveCard(source, card)
	local Player = QBCore.Functions.GetPlayer(source)
	local info = {
		id = card.id,
		holder = card.holder,
		number = card.number
	}
	Player.Functions.AddItem('visa', 1, nil, info)
end

local function getBank(source)
	local Player = QBCore.Functions.GetPlayer(source)
	return Player.PlayerData.money["bank"] or 0
end

function GetAccount(account)
	if exports.pefcl:getUniqueAccount(-1, account).data then
    	return exports.pefcl:getBankBalanceByIdentifier(-1, account).data
	else
		return false
	end
end
exports('GetAccount', GetAccount)

function AddMoney(src, account, amount, reason)
	if exports.pefcl:getUniqueAccount(src, account).data then
		local data = {
			identifier = account,
			amount = amount,
			description = reason
		}
		exports.pefcl:addBankBalanceByIdentifier(src, data)
		return true
	else
		return false
	end
end
exports('AddMoney', AddMoney)

function RemoveMoney(account, amount, reason)
	if exports.pefcl:getUniqueAccount(-1, account).data then
		if tonumber(exports.pefcl:getBankBalanceByIdentifier(-1, account).data) >= amount then
			local data = {
				identifier = account,
				amount = amount,
				description = reason
			}
			exports.pefcl:removeBankBalanceByIdentifier(-1, data)
			return true
		else
			return false
		end
	else
		return false
	end
end
exports('RemoveMoney', RemoveMoney)

AddEventHandler(('__cfx_export_qb-management_%s'):format('AddMoney'), function(setCB)
    setCB(AddMoney)
end)

AddEventHandler(('__cfx_export_qb-management_%s'):format('RemoveMoney'), function(setCB)
    setCB(RemoveMoney)
end)

AddEventHandler(('__cfx_export_qb-management_%s'):format('GetAccount'), function(setCB)
    setCB(GetAccount)
end)

exports("getBank", getBank)
exports("addCash", addCash)
exports("removeCash", removeCash)
exports("getCash", getCash)
exports("giveCard", giveCard)
exports("getCards", getCards)

AddEventHandler("QBCore:Server:OnMoneyChange", function(playerSrc, moneyType, amount, action, reason)
	if moneyType ~= "bank" then return end
	if action == "add" then
		exports.pefcl:addBankBalance(playerSrc, { amount = amount, message = reason })	
	end

	if action == "remove" then
		exports.pefcl:removeBankBalance(playerSrc, { amount = amount, message = reason })	
	end

	if action == "set" then
		exports.pefcl:setBankBalance(playerSrc, { amount = amount, message = reason })	
	end	
end)

AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
	if not player then
		return
	end
	local citizenid = player.PlayerData.citizenid
	local charInfo = player.PlayerData.charinfo
	local playerSrc = player.PlayerData.source
	loadPlayer(playerSrc, citizenid, charInfo.firstname .. " " .. charInfo.lastname)
	UniqueAccounts(player)				
	player.Functions.SyncMoney()
end)

RegisterNetEvent("qb-pefcl:server:UnloadPlayer", function()
	exports.pefcl:unloadPlayer(source)
end)

RegisterNetEvent("qb-pefcl:server:SyncMoney", function()
	local player = QBCore.Functions.GetPlayer(source)
	player.Functions.SyncMoney()
end)

RegisterNetEvent("qb-pefcl:server:OnJobUpdate", function(oldJob)
	local player = QBCore.Functions.GetPlayer(source)
	UniqueAccounts(player)
end)

local currentResName = GetCurrentResourceName()

AddEventHandler("onServerResourceStart", function(resName)
	if resName ~= currentResName then return end
	local players = QBCore.Functions.GetQBPlayers()
	if not players or players == nil then
		print("Error loading players, if no players on the server ignore this")
		return
	end
	for _, v in pairs(players) do
		loadPlayer(v.PlayerData.source, v.PlayerData.citizenid, v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname)
		UniqueAccounts(v)
		v.Functions.SyncMoney()
	end
end)
