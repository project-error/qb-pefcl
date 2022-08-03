RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
	TriggerServerEvent("qb-pefcl:server:UnloadPlayer")
end)

RegisterNetEvent("pefcl:newDefaultAccountBalance", function(balance)
	TriggerServerEvent("qb-pefcl:server:SyncMoney")
end)