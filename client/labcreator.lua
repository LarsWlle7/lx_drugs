local DefaultCurrentCreation = {
    teleport_to = nil,
    teleport_from = nil,
    managelab_loc = nil,
    storage_size = 10,
    buyprice = 1000,
    produce_loc = nil,
    process_loc = nil,
    location_label = "No interior specified yet.",
    prevTPLocation = nil
}

local CurrentCreation = DefaultCurrentCreation

local function OpenLabcreatorLocationMenu(labs) --//TODO: Fix color if selected
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "labcreator_setlocation", {
        title = Config.Locales["LABCREATOR_TITLE"],
        elements = labs,
        align = "top-right",
    }, function(data, menu)
        CurrentCreation.teleport_to = data.current.location
        CurrentCreation.location_label = data.current.label
        if CurrentCreation.prevTPLocation == nil then
            CurrentCreation.prevTPLocation = GetEntityCoords(GetPlayerPed(-1))
        end
        SetEntityCoords(GetPlayerPed(-1), data.current.location.x, data.current.location.y, data.current.location.z)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

local function OpenLabcreatorMaxStorage()
    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "labcreator_setmaxstorage", {
        title = Config.Locales["LABCREATOR_TITLE"],
    }, function(data, menu)
        local value = tonumber(data.value)
        if value == "fail" then return end
        CurrentCreation.storage_size = value
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

local function OpenLabcreatorSetBuyprice()
    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "labcreator_setbuyprice", {
        title = Config.Locales["LABCREATOR_TITLE"],
    }, function(data, menu)
        local value = tonumber(data.value)
        if value == "fail" then return end
        CurrentCreation.buyprice = value
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

local function DrawInformationText(x, y, text, align)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.5, 0.5)
	SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextJustification(align or 1)
    AddTextComponentString(text)
    DrawText(x, y)
end

if Config.EnableLabCreator then
    RegisterCommand("labcreator", function(source)
        local isMenuOpen = true
        ESX.TriggerServerCallback("lx_drugs:labcreator:getData", function(cdata)
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "labcreator", {
                title = Config.Locales["LABCREATOR_TITLE"],
                elements = {
                    { label = Config.Locales["LABCREATOR_SET_LOCATION"], action = "SETLOCATION" },
                    { label = Config.Locales["LABCREATOR_SET_TELEPORTFROM"], action = "SETTELEPORTFROM" },
                    { label = Config.Locales["LABCREATOR_SET_MANAGELOC"], action = "SETMANAGELOC" },
                    { label = Config.Locales["LABCREATOR_SET_STORAGEMAX"], action = "SETSTORAGEMAX" },
                    { label = Config.Locales["LABCREATOR_SET_BUYPRICE"], action = "SETBUYPRICE" },
                    { label = Config.Locales["LABCREATOR_SET_PROCESS"], action = "SETPROCESS" },
                    { label = Config.Locales["LABCREATOR_SET_PRODUCE"], action = "SETPRODUCE" },
                    { label = Config.Locales["LABCREATOR_CONFIRM"], action = "CONFIRM" },
                },
                align = "top-right"
            }, function(data, menu)
                if data.current.action == "SETLOCATION" then
                    OpenLabcreatorLocationMenu(cdata)
                elseif data.current.action == "SETTELEPORTFROM" then
                    CurrentCreation.teleport_from = GetEntityCoords(GetPlayerPed(-1))
                elseif data.current.action == "SETMANAGELOC" then
                    CurrentCreation.managelab_loc = GetEntityCoords(GetPlayerPed(-1))
                elseif data.current.action == "SETSTORAGEMAX" then
                    OpenLabcreatorMaxStorage()
                elseif data.current.action == "SETBUYPRICE" then
                    OpenLabcreatorSetBuyprice()
                elseif data.current.action == "SETPROCESS" then
                    CurrentCreation.process_loc = GetEntityCoords(GetPlayerPed(-1))
                elseif data.current.action == "SETPRODUCE" then
                    CurrentCreation.produce_loc = GetEntityCoords(GetPlayerPed(-1))
                elseif data.current.action == "CONFIRM" then
                    ESX.TriggerServerCallback("lx_drugs:labcreator:createLab", function(data)
                        Labs = data
                        CurrentCreation = DefaultCurrentCreation
                        isMenuOpen = false
                        menu.close()
                        SetEntityCoords(GetPlayerPed(-1), CurrentCreation.prevTPLocation)
                    end, CurrentCreation)
                end
            end, function(data, menu)
                CurrentCreation = DefaultCurrentCreation
                isMenuOpen = false
                menu.close()
                SetEntityCoords(GetPlayerPed(-1), CurrentCreation.prevTPLocation)
            end)
        end)
        while isMenuOpen do
            Citizen.Wait(2)
            if CurrentCreation.teleport_from ~= nil then
                local x, y, z = table.unpack(CurrentCreation.teleport_from)
                if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) <= 10 then
                    DrawMarker(1, x, y, z - 1, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 22, 160, 133, 255, false, false, 2, false, nil, nil, false)
                    Draw3DText(x, y, z - 0.75, Config.Locales["LABCREATOR_TELEPORTFROM"])
                end
            end
            if CurrentCreation.managelab_loc ~= nil then
                local x, y, z = table.unpack(CurrentCreation.managelab_loc)
                if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) <= 10 then
                    DrawMarker(1, x, y, z - 1, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 22, 160, 133, 255, false, false, 2, false, nil, nil, false)
                    Draw3DText(x, y, z - 0.75, Config.Locales["LABCREATOR_MANAGELOC"])
                end
            end
            if CurrentCreation.process_loc ~= nil then
                local x, y, z = table.unpack(CurrentCreation.process_loc)
                if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) <= 10 then
                    DrawMarker(1, x, y, z - 1, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 22, 160, 133, 255, false, false, 2, false, nil, nil, false)
                    Draw3DText(x, y, z - 0.75, Config.Locales["LABCREATOR_PROCESS"])
                end
            end
            if CurrentCreation.produce_loc ~= nil then
                local x, y, z = table.unpack(CurrentCreation.produce_loc)
                if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) <= 10 then
                    DrawMarker(1, x, y, z - 1, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 22, 160, 133, 255, false, false, 2, false, nil, nil, false)
                    Draw3DText(x, y, z - 0.75, Config.Locales["LABCREATOR_PRODUCE"])
                end
            end
            ESX.ShowHelpNotification(
                "~h~Price:~h~ ~g~" .. Config.Locales["CURRENCY"] .. CurrentCreation.buyprice .. "\n~w~"
                .. "~h~Storage size:~h~ ~g~" .. CurrentCreation.storage_size .. " items\n~w~"
                .. "~h~Location:~h~ ~g~" .. CurrentCreation.location_label .. "\n~w~", true
            )
        end
    end) 
end