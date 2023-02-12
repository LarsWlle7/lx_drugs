local labs = {
    { label = "Clubhouse 1", ipl = "bkr_biker_interior_placement_interior_0_biker_dlc_int_01_milo", location = vector3(1120.9476, -3152.4744, -37.0628) },
    { label = "Clubhouse 2", ipl = "bkr_biker_interior_placement_interior_0_biker_dlc_int_02_milo", location = vector3(997.1760, -3157.9822, -38.9072) },
    { label = "Warehouse 1", ipl = "bkr_biker_interior_placement_interior_4_biker_dlc_int_ware01_milo", location = vector3(996.8550, -3200.7363, -36.3937) },
    { label = "Warehouse 2", ipl = "bkr_biker_interior_placement_interior_3_biker_dlc_int_ware02_milo", location = vector3(1066.2970, -3183.4924, -39.1635) },
    { label = "Warehouse 3", ipl = "bkr_biker_interior_placement_interior_4_biker_dlc_int_ware03_milo", location = vector3(1088.6547, -3187.7241, -38.9935) },
    { label = "Warehouse 4", ipl = "bkr_biker_interior_placement_interior_4_biker_dlc_int_ware04_milo", location = vector3(1138.1892, -3198.9189, -39.6657) },
    { label = "Warehouse 5", ipl = "bkr_biker_interior_placement_interior_4_biker_dlc_int_ware05_milo", location = vector3(1173.5332, -3196.6755, -39.0080) },
    { label = "Warehouse Small", ipl = "ex_exec_warehouse_placement_interior_1_int_warehouse_s_dlc_milo", location = vector3(1087.3448, -3099.3655, -39.0000) },
    { label = "Warehouse Medium", ipl = "ex_exec_warehouse_placement_interior_0_int_warehouse_m_dlc_milo", location = vector3(1048.0400, -3097.1079, -38.9999) },
    { label = "Warehouse Large", ipl = "ex_exec_warehouse_placement_interior_2_int_warehouse_l_dlc_milo", location = vector3(997.7145, -3092.0906, -38.9999) },
    -- { label = "Torture room (no collisions)", ipl = "", location = vector3(135.0919, -2203.2837, 7.3091) },
}

ESX.RegisterServerCallback("lx_drugs:labcreator:getData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == Config.LabCreatorMinGroup then
        cb(labs)
    end
end)

ESX.RegisterServerCallback("lx_drugs:labcreator:createLab", function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= Config.LabCreatorMinGroup then return DropPlayer(source, "Invalid permissions.") end
    if not Lab:IsValidLabData(data) then return print("^7[^1ERROR^7] Invalid lab data submitted") end
    local data = Lab:CreatorDataToDBData(data)
    MySQL.query.await("INSERT INTO `druglabs` (`id`, `teleport_from`, `teleport_to`, `code`, `storage_size`, `storage_data`, `produce_location`, `process_location`, `managelab_location`, `buyprice`, `owner`) VALUES (NULL, ?, ?, '', ?, '[]', ?, ?, ?, ?, '')", {
        json.encode(data.teleport_from), 
        json.encode(data.teleport_to),
        data.storage_size,
        json.encode(data.produce_loc),
        json.encode(data.process_loc),
        json.encode(data.managelab_loc),
        data.buyprice
    })
    FetchLabInformation()
    cb(CachedLabs)
end)