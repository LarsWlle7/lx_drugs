ESX = exports["es_extended"]:getSharedObject()
CachedLabs = {}
PlayersInLabs = {} -- {id: number, source: number}
Lab = {}

function FetchLabInformation()
    local data = MySQL.query.await("SELECT * FROM `druglabs`")
    local processedData = {}
    for i, k in ipairs(data) do
        local toAppend = {}
        toAppend["teleport_from"] = json.decode(k.teleport_from)
        toAppend["teleport_to"] = json.decode(k.teleport_to)
        toAppend["code"] = k.code
        toAppend["id"] = k.id
        toAppend["storage_size"] = k.storage_size
        toAppend["storage_data"] = json.decode(k.storage_data)
        toAppend["produce_location"] = json.decode(k.produce_location)
        toAppend["process_location"] = json.decode(k.process_location)
        toAppend["managelab_location"] = json.decode(k.managelab_location)
        toAppend["price"] = k.buyprice
        toAppend["owner"] = k.owner
        table.insert(processedData, toAppend)
    end
    CachedLabs = processedData
end


function Lab:GetPlayersInLab(id) --//TODO: Fix playerdropped: remove
    local sources = {}
    for i, k in ipairs(PlayersInLabs) do
        if k.id == id then
            table.insert(sources, k.source)
        end
    end
    return sources
end

function Lab:EnterLab(id, source)
    table.insert(PlayersInLabs, {id = id, source = source})
end

function Lab:GetLabDataById(id)
    for i, k in ipairs(CachedLabs) do
        if k.id == id then return k, i end
    end
    return nil
end

function Lab:AddItemToStorage(lab, item, count)
    local inv = lab.storage_data
    if inv[item] then
        inv[item] = inv[item] + count
    else
        inv[item] = count
    end
    MySQL.query.await("UPDATE `druglabs` SET `storage_data` = ? WHERE `id` = ?", {json.encode(inv), lab.id})
    FetchLabInformation()
end

function Lab:RemoveItemFromStorage(lab, item, count)
    local inv = lab.storage_data
    if inv[item] then
        inv[item] = inv[item] - count
    else
        inv[item] = 0
    end
    MySQL.query.await("UPDATE `druglabs` SET `storage_data` = ? WHERE `id` = ?", {json.encode(inv), lab.id})
    FetchLabInformation()
end

function Lab:IsValidLabData(data)
    return data.teleport_to and type(data.teleport_to) == "table" 
           and data.teleport_from and type(data.teleport_from) == "vector3"
           and data.managelab_loc and type(data.managelab_loc) == "vector3"
           and data.produce_loc and type(data.produce_loc) == "vector3"
           and data.process_loc and type(data.process_loc) == "vector3"
           and data.storage_size and type(data.storage_size) == "number"
           and data.buyprice and type(data.buyprice) == "number"
end

function Lab:CreatorDataToDBData(data)
    return {
        teleport_to = data.teleport_to,
        teleport_from = VectorToObject(data.teleport_from),
        managelab_loc = VectorToObject(data.managelab_loc),
        produce_loc = VectorToObject(data.produce_loc),
        process_loc = VectorToObject(data.process_loc),
        storage_size = data.storage_size,
        storage_data = {},
        buyprice = data.buyprice
    }
end

Citizen.CreateThread(function()
    FetchLabInformation()
end)