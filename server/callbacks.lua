local PlayersRequestedLabData = {}
local RecentPlayersProduced = {}
local RecentPlayersProcessed = {}

ESX.RegisterServerCallback("lx_drugs:FetchLabsFromServer", function(source, cb)
    if table.contains(PlayersRequestedLabData, source) then return DropPlayer(source, "You've tried to request data multiple times while this is not allowed.") end
    cb(CachedLabs or {})
end)

ESX.RegisterServerCallback("lx_drugs:EnterLab", function(source, cb, id)
    if table.contains(PlayersInLabs, {id = id, source = source}) then return DropPlayer(source, "Already in lab.") end
    local otherPlayers = Lab:GetPlayersInLab(id)
    PlayersInLabs[source] = {source = source, id = id}
    cb(otherPlayers)
end)

ESX.RegisterServerCallback("lx_drugs:ExitLab", function(source, cb, id)
    if not table.contains(PlayersInLabs, {id = id, source = source}) then return DropPlayer(source, "Not in lab") end
    local otherPlayers = Lab:GetPlayersInLab(id)
    PlayersInLabs[source] = nil
    cb(otherPlayers)
end)

ESX.RegisterServerCallback("lx_drugs:ProducedItem", function(source, cb)
    if RecentPlayersProduced[source] then return DropPlayer(source, "Producing drugs in lab too fast.") end
    RecentPlayersProduced[source] = true
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.canCarryItem(Config.Items[1], 1) then
        xPlayer.addInventoryItem(Config.Items[1], 1)
    else
        TriggerClientEvent("chat:addMessage", source, {template = Config.Locales["CANT_CARRY"]})
    end
    Citizen.SetTimeout(Config.Delays.producing / 500, function()
        RecentPlayersProduced[source] = false 
    end)
end)

ESX.RegisterServerCallback("lx_drugs:ProcessedItem", function(source, cb)
    if RecentPlayersProcessed[source] then return DropPlayer(source, "Processing drugs in lab too fast.") end
    RecentPlayersProcessed[source] = true
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getInventoryItem(Config.Items[1]).count < Config.MinNormalRequiredForProcessing then
        TriggerClientEvent("chat:addMessage", source, {template = Config.Locales["NOT_ENOUGH_INGREDIENTS"]})
        return
    end
    if xPlayer.canCarryItem(Config.Items[2], 1) then
        xPlayer.removeInventoryItem(Config.Items[1], Config.MinNormalRequiredForProcessing)
        xPlayer.addInventoryItem(Config.Items[2], 1)
    else
        TriggerClientEvent("chat:addMessage", source, {template = Config.Locales["CANT_CARRY"]})
    end
    Citizen.SetTimeout(Config.Delays.producing / 500, function()
        RecentPlayersProcessed[source] = false 
    end)
end)

ESX.RegisterServerCallback("lx_drugs:ChangeCode", function(source, cb, id, code)
    local lab, index = Lab:GetLabDataById(id)
    if not lab or not index or not code then return end
    if tonumber(code) == "fail" then return end
    if lab.owner ~= GetPlayerIdentifier(source, 0) then return TriggerClientEvent("chat:addMessage", source, {template = Config.Locales["INVALID_PERMISSIONS"]}) end
    MySQL.query.await("UPDATE `druglabs` SET `code` = ? WHERE `id` = ?", {code, id})
    CachedLabs[index].code = code --//TODO: Validate if owner
    cb(CachedLabs or {}) -- Syncing
end)

ESX.RegisterServerCallback("lx_drugs:BuyLab", function(source, cb, id)
    local lab, index = Lab:GetLabDataById(id)
    if not lab or not index then return end
    if string.len(lab.owner) > 0 then return DropPlayer(source, "Tried to buy lab that is already owned.") end
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getAccount(Config.RequiredAccountToBuy).money < lab.price then return TriggerClientEvent("chat:addMessage", source, {template = Config.Locales["LACKING_BUDGET"]}) end
    xPlayer.removeAccountMoney(Config.RequiredAccountToBuy, lab.price)
    local identifier = GetPlayerIdentifier(source, 0)
    local code = math.floor(math.random(111, 999))
    MySQL.query.await("UPDATE `druglabs` SET `owner` = ? WHERE `id` = ?", {identifier, id})
    MySQL.query.await("UPDATE `druglabs` SET `code` = ? WHERE `id` = ?", {code, id})
    TriggerClientEvent("chat:addMessage", source, {template = string.format(Config.Locales["BOUGHT_LAB"], code)})
    FetchLabInformation()
    cb(CachedLabs or {}) -- syncing
end)

ESX.RegisterServerCallback("lx_drugs:GetInventoryItems", function(source, cb)
    local ESX = exports["es_extended"]:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(source)
    local inv = xPlayer.getInventory(true)
    local elements = {}
    for i, k in pairs(inv) do
        table.insert(elements, {
            label = ESX.GetItemLabel(i) .. " (x" .. k .. ")",
            value = k,
            item = i
        })
    end
    cb(elements)	
end)

ESX.RegisterServerCallback("lx_drugs:GetLabInventoryItems", function(source, cb, id)
    local ESX = exports["es_extended"]:getSharedObject()
    local lab = Lab:GetLabDataById(id)
    if not lab then return end
    local inv = lab.storage_data
    local xPlayer = ESX.GetPlayerFromId(source)
    local elements = {}
    for i, k in pairs(inv) do
        table.insert(elements, {
            label = ESX.GetItemLabel(i) .. " (x" .. k .. ")",
            value = k,
            item = i
        })
    end
    cb(elements)	
end)

ESX.RegisterServerCallback("lx_drugs:DepositItem", function(source, cb, id, item, count) 
    local lab, index = Lab:GetLabDataById(id)
    if not lab or not index then return end
    if not Lab:DoesInventoryHaveSpaceToAdd(lab, item, count) then
        TriggerClientEvent("chat:addMessage", source, {template = Config.Locales["NOT_ENOUGH_SPACE"]})
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, count)
    Lab:AddItemToStorage(lab, item, count)
    cb(CachedLabs[index].storage_data)
end)

ESX.RegisterServerCallback("lx_drugs:TakeItem", function(source, cb, id, item, count) 
    local lab, index = Lab:GetLabDataById(id)
    if not lab or not index then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, count)
    Lab:RemoveItemFromStorage(lab, item, count)
    cb(CachedLabs[index].storage_data)
end)