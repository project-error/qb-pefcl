RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
	TriggerServerEvent("qb-pefcl:server:UnloadPlayer")
end)

RegisterNetEvent("pefcl:newTransactionBroadcast", function(transaction)
	if transaction.toAccount.isDefault or transaction.fromAccount.isDefault then
		TriggerServerEvent("qb-pefcl:server:SyncMoney")
	end
end)