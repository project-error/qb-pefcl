<h1 align="center">qb-pefcl</h1>

**This is a compatibility resource that enables PEFCL to function properly with QBCore. Please ensure that you have the latest version
of PEFCL and QBCore installed**
**Note this currently only works on PEFCL develop branch**

## Installation Steps:

1. Download this repository and place it in the `resources` directory
2. Add `ensure qb-pefcl` to your `server.cfg` (Start this resource after `QBCore` and `PEFCL` have been started)
3. Navigate to the `config.json` in `PEFCL` and change the following settings:
   - Under `frameworkIntegration`
     - `enabled`: `true`
     - `resource`: `qb-pefcl`
   - Under `target`
     - `type`: `"qb-target"`
     - `enabled`: `true`
4. Navigate to `qb-core\server\player.lua` and replace those functions:

   - self.Functions.AddMoney =>

     ```lua
         function self.Functions.AddMoney(moneytype, amount, reason)
             reason = reason or 'unknown'
             moneytype = moneytype:lower()
             amount = tonumber(amount)
             if amount < 0 then return end
             if moneytype == 'bank' then
                 local data = {}
                 data.amount = amount
                 data.message = reason
                 exports.pefcl:addBankBalance(self.PlayerData.source, data)
             else
                 if not self.PlayerData.money[moneytype] then return false end
                 self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount
             end

             if not self.Offline then
                 self.Functions.UpdatePlayerData()
                 if amount > 100000 then
                     TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
                 else
                     TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
                 end
                 TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
             end

             return true
       end
     ```

   - self.Functions.RemoveMoney =>

     ```lua
           function self.Functions.RemoveMoney(moneytype, amount, reason)
             reason = reason or 'unknown'
             moneytype = moneytype:lower()
             amount = tonumber(amount)
             if amount < 0 then return end
             if not self.PlayerData.money[moneytype] then return false end
             for _, mtype in pairs(QBCore.Config.Money.DontAllowMinus) do
                 if mtype == moneytype then
                     if (self.PlayerData.money[moneytype] - amount) < 0 then
                         return false
                     end
                 end
                 if moneytype == 'bank' then
                     if (exports.pefcl:getDefaultAccountBalance(self.PlayerData.source).data - amount) < 0 then
                         return false
                     end
                 end
             end
             if moneytype == 'bank' then
                 local data = {}
                 data.amount = amount
                 data.message = reason
                 exports.pefcl:removeBankBalance(self.PlayerData.source, data)
             else
                 self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount
             end
             if not self.Offline then
                 self.Functions.UpdatePlayerData()
                 if amount > 100000 then
                     TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
                 else
                     TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
                 end
                 TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
                 if moneytype == 'bank' then
                     TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
                 end
             end

             return true
           end
     ```

   - self.Functions.SetMoney =>

     ```lua
         function self.Functions.SetMoney(moneytype, amount, reason)
             moneytype = moneytype:lower()
             amount = tonumber(amount)
             if amount < 0 then return false end
             if moneytype == 'bank' then
                 local data = {}
                 data.amount = amount
                 exports.pefcl:setBankBalance(self.PlayerData.source, data)
                 self.PlayerData.money[moneytype] = exports.pefcl:getDefaultAccountBalance(self.PlayerData.source).data or 0
             else
                 if not self.PlayerData.money[moneytype] then return false end
                 self.PlayerData.money[moneytype] = amount
             end

             if not self.Offline then
                 self.Functions.UpdatePlayerData()
                 TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype])
             end

             return true
         end
     ```

   - self.Functions.GetMoney =>

     ```lua
         function self.Functions.GetMoney(moneytype)
             if not moneytype then return false end
             moneytype = moneytype:lower()
             if moneytype == 'bank' then
                 self.PlayerData.money[moneytype] = exports.pefcl:getDefaultAccountBalance(self.PlayerData.source).data or 0
                 return exports.pefcl:getDefaultAccountBalance(self.PlayerData.source).data
             end
             return self.PlayerData.money[moneytype]
         end
     ```

5. Navigate to `qb-core\server\player.lua` and add the following function:
    ```lua
        function self.Functions.SyncMoney() 
                local money = exports.pefcl:getDefaultAccountBalance(self.PlayerData.source).data
                self.PlayerData.money['bank'] = money
            if not self.Offline then
                self.Functions.UpdatePlayerData()
            end
        end
    ```
