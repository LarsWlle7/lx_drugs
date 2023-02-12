ESX = exports["es_extended"]:getSharedObject()
Labs = {}
IsInLab = false
CurrentLabId = -1
CurrentLabData = nil
HasMenuOpen = false

function SpawnAllLabObjects()
    for i, k in ipairs(Config.Props) do
        ESX.Game.SpawnObject(k.model, k.coords, function(object) 
            FreezeEntityPosition(object, true)
            if k.rotation then
                SetEntityRotation(object, k.rotation.x, k.rotation.y, k.rotation.z)
            end
        end)
    end
end

function FetchLabsFromServer()
    ESX.TriggerServerCallback("lx_drugs:FetchLabsFromServer", function(data) 
        Labs = data 
    end)
end

function PromptCodeAndTeleport(id, code, teleport_to, lab)
    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "code_prompt", {
        title = "Code",
    }, function(data, menu)
        if not data.value then return menu.close() end
        if code == data.value then
            menu.close()
            CurrentLabId = id
            IsInLab = true
            CurrentLabData = lab
            SetEntityCoords(GetPlayerPed(-1), teleport_to.x, teleport_to.y, teleport_to.z)
            ESX.TriggerServerCallback("lx_drugs:EnterLab", function(players)
                for _, cid in ipairs(GetActivePlayers()) do
                    local source = GetPlayerServerId(cid)
                    SetEntityInvincible(GetPlayerPed(source), true)
                    --//TODO: Fix you can't hear others
                end
            end, id)
        else
            TriggerEvent("chat:addMessage", {template = Config.Locales["CODE_INVALID"]})
            return
        end

    end, function(data, menu)
        menu.close()
    end)
end

function StartProducing()
    exports["rprogress"]:Custom({
        canCancel = true,
        Duration = Config.Delays.producing,
        Label = Config.Locales["PRODUCING"],
        Animation = {
            animationDictionary = Config.ProduceEmoteDict,
            animationName = Config.ProduceEmoteName
        },
        DisableControls = {
            Mouse = true,
            Player = true,
            Vehicle = true
        },
        onComplete = function(cancelled)
            if cancelled then
                TriggerEvent("chat:addMessage", {template = Config.Locales["ACTION_CANCELLED"]})
                return
            end
            ESX.TriggerServerCallback("lx_drugs:ProducedItem", function() end)
            ClearPedTasks(GetPlayerPed(-1))
        end
    })
    Citizen.Wait(Config.Delays.producing)
end

function StartProcessing()
    exports["rprogress"]:Custom({
        canCancel = true,
        Duration = Config.Delays.processing,
        Label = Config.Locales["PROCESSING"],
        Animation = {
            animationDictionary = Config.ProcessEmoteDict,
            animationName = Config.ProcessEmoteName
        },
        DisableControls = {
            Mouse = true,
            Player = true,
            Vehicle = true
        },
        onComplete = function(cancelled)
            if cancelled then
                TriggerEvent("chat:addMessage", {template = Config.Locales["ACTION_CANCELLED"]})
                return
            end
            ESX.TriggerServerCallback("lx_drugs:ProcessedItem", function() end)
            ClearPedTasks(GetPlayerPed(-1))
        end
    })
    Citizen.Wait(Config.Delays.producing)
end

function OpenManageLabMenu(lab)
    HasMenuOpen = true
    ESX.OpenContext("right", {
        {
            unselectable = true,
            icon = Config.Icons["MANAGE_TITLE"],
            title = Config.Locales["MANAGE_TITLE"],
        },
        {
            icon = Config.Icons["MANAGE_CHANGE_CODE"],
            title = Config.Locales["MANAGE_CHANGE_CODE"],
            description = Config.Locales["MANAGE_CHANGE_CODE_DESCRIPTION"],
            name = "CHANGE_CODE"
        },
        {
            icon = Config.Icons["MANAGE_OPEN_INV"],
            title = Config.Locales["MANAGE_OPEN_INV"],
            description = Config.Locales["MANAGE_OPEN_INV_DESCRIPTION"],
            name = "OPEN_INV"
        },
    }, function(menu, element) -- On Select Function
        if element.name == "CHANGE_CODE" then
            OpenChangeCodeMenu(lab)
        elseif element.name == "OPEN_INV" then
            ESX.CloseContext()
            OpenLabInventory(lab)
        end
    end, function(menu) -- on close
        HasMenuOpen = false
    end)
      
end

function OpenChangeCodeMenu(lab) --//TODO: Fix nested menus
    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "change_code", {
        title = Config.Locales["CHANGE_CODE_PROMPT"]
    }, function(data, menu)
        if not data.value then return TriggerEvent("chat:addMessage", {template = Config.Locales["INVALID_INPUT"]}) end
        menu.close()
        ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "change_code_confirm", {
            title = Config.Locales["CHANGE_CODE_PROMPT_CONFIRM"]
        }, function(data2, menu2)
            if not data2.value then return TriggerEvent("chat:addMessage", {template = Config.Locales["INVALID_INPUT"]}) end
            if not data.value == data2.value then return TriggerEvent("chat:addMessage", {template = Config.Locales["INVALID_CONFIRMATION"]}) end
            ESX.TriggerServerCallback("lx_drugs:ChangeCode", function(labs) 
                Labs = labs 
                menu2.close()
            end, lab.id, data.value)
        end, function(_, menu2)
            menu2.close()
        end)
        
    end, function(_, menu)
        menu.close()
    end)
end

function OpenLabInventory(lab) 
    if Config.UseOXInventory then
        --//TODO: Make compatible with ox inv
    else
        local elements = {
            {label = Config.Locales["DEPOSIT"], action = "DEPOSIT"}, --//TODO: Link to config 
        }
        
        ESX.TriggerServerCallback("lx_drugs:GetLabInventoryItems", function(data)
            for i, k in ipairs(data) do if k.value > 0 then table.insert(elements, k) end end
            local HasInventoryOpen = true
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "lab_inventory", {
                align = "top-right",
                elements = elements,
                title = Config.Locales["INVENTORY_TITLE"]
            }, function(data, menu)
                if data.current.action == "DEPOSIT" then
                    menu.close()
                    OpenLabInventoryDepositMenu(lab)
                    return
                end
                -- ESX.TriggerServerCallback("lx_drugs:TakeItem", function(inventory) 
                --     menu.close()
                --     lab["storage_data"] = inventory
                --     OpenLabInventory(lab)
                -- end, lab.id, data.current.item, data.current.value) --//TODO: Prompt amount
                PromptAmount("lx_drugs:TakeItem", lab, data, function(inventory)
                    menu.close()
                    lab["storage_data"] = inventory
                    OpenLabInventory(lab)
                end)
            end, function(data, menu)
                HasInventoryOpen = false
                menu.close()
            end)
            while HasInventoryOpen do
                Citizen.Wait(100)
                local x, y, z = lab.managelab_location.x, lab.managelab_location.y, lab.managelab_location.z
                if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) > 5 then
                    ESX.UI.Menu.CloseAll()
                end
            end
        end, lab.id)
    end
end

function OpenLabInventoryDepositMenu(lab)
    ESX.TriggerServerCallback("lx_drugs:GetInventoryItems", function(data)
        local HasInventoryOpen = true
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "lab_inventory_deposit", {
            align = "top-right",
            elements = data,
            title = Config.Locales["INVENTORY_TITLE"]
        }, function(data, menu)
            PromptAmount("lx_drugs:DepositItem", lab, data, function()
                menu.close()
                OpenLabInventory(lab)
            end)
        end, function(data, menu)
            HasInventoryOpen = false
            menu.close()
        end)
        while HasInventoryOpen do
            Citizen.Wait(100)
            local x, y, z = lab.managelab_location.x, lab.managelab_location.y, lab.managelab_location.z
            if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) > 5 then
                ESX.UI.Menu.CloseAll()
            end
        end
    end)
end

--@param event -> "lx_drugs:TakeItem" | ""
function PromptAmount(event, lab, data, cb)
    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "prompt_count", {
        title = Config.Locales["COUNT"]
    }, function(_data, menu)
        if not _data.value then return TriggerEvent("chat:addMessage", {template = Config.Locales["INVALID_INPUT"]}) end
        ESX.TriggerServerCallback(event, cb, lab.id, data.current.item, tonumber(_data.value))
        menu.close()
    end, function(_, menu)
        menu.close()
    end)
end

Citizen.CreateThread(function()
    SpawnAllLabObjects()
    FetchLabsFromServer()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        local isClose = false
        if HasMenuOpen then Citizen.Wait(500) end
        for _, lab in ipairs(Labs) do
            local from_x, from_y, from_z = lab.teleport_from.x, lab.teleport_from.y, lab.teleport_from.z
            local escape_x, escape_y, escape_z = lab.teleport_to.x, lab.teleport_to.y, lab.teleport_to.z
            if Vdist(from_x, from_y, from_z, GetEntityCoords(GetPlayerPed(-1))) <= 5 and not IsInLab then
                if string.len(lab.owner) <= 0 then
                    Draw3DText(from_x, from_y, from_z, Config.Locales["BUY_LAB"] .. " ~w~(~g~" .. Config.Locales["CURRENCY"] .. lab.price .. "~w~)")
                    if IsControlJustPressed(0, 38) then
                        ESX.TriggerServerCallback("lx_drugs:BuyLab", function(labs) 
                            Labs = labs
                        end, lab.id)
                    end
                else
                    Draw3DText(from_x, from_y, from_z, Config.Locales["ENTER_LAB"])
                    if IsControlJustReleased(0, 38) then
                        PromptCodeAndTeleport(lab.id, lab.code, lab.teleport_to, lab)
                    end
                end
                isClose = true
            end
        end
        if CurrentLabData then
            local x, y, z = CurrentLabData.teleport_to.x, CurrentLabData.teleport_to.y, CurrentLabData.teleport_to.z
            local from_x, from_y, from_z = CurrentLabData.teleport_from.x, CurrentLabData.teleport_from.y, CurrentLabData.teleport_from.z
            if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) <= 5 and IsInLab then
                Draw3DText(x, y, z, Config.Locales["EXIT_LAB"])
                if IsControlJustReleased(0, 38) then
                    IsInLab = false
                    CurrentLabId = -1
                    SetEntityCoords(GetPlayerPed(-1), from_x, from_y, from_z)
                end
                isClose = true
            end
        end
        if not isClose then
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if not IsInLab or HasMenuOpen then
            Citizen.Wait(1000)
        else
            if Config.CanLabProduce and CurrentLabData then
                local producing_x, producing_y, producing_z = CurrentLabData.produce_location.x, CurrentLabData.produce_location.y, CurrentLabData.produce_location.z
                if Vdist(producing_x, producing_y, producing_z, GetEntityCoords(GetPlayerPed(-1))) <= 5 and IsInLab then
                    Draw3DText(producing_x, producing_y, producing_z, Config.Locales["PRODUCE"])
                    if IsControlJustReleased(0, 38) then
                        StartProducing()
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if not IsInLab or HasMenuOpen then
            Citizen.Wait(1000)
        else
            if Config.CanLabProcess and CurrentLabData then
                local processing_x, processing_y, processing_z = CurrentLabData.process_location.x, CurrentLabData.process_location.y, CurrentLabData.process_location.z
                if Vdist(processing_x, processing_y, processing_z, GetEntityCoords(GetPlayerPed(-1))) <= 5 and IsInLab then
                    Draw3DText(processing_x, processing_y, processing_z, Config.Locales["PROCESS"])
                    if IsControlJustReleased(0, 38) then
                        StartProcessing()
                    end
                end
            end
        end        
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if not IsInLab or HasMenuOpen then
            Citizen.Wait(1000)
        end

        if Config.CanLabManage and CurrentLabData then
            local x, y, z = CurrentLabData.managelab_location.x, CurrentLabData.managelab_location.y, CurrentLabData.managelab_location.z
            if Vdist(x, y, z, GetEntityCoords(GetPlayerPed(-1))) <= 5 and IsInLab then
                Draw3DText(x, y, z, Config.Locales["MANAGE"])
                if IsControlJustReleased(0, 38) then
                    OpenManageLabMenu(CurrentLabData)
                end
            end
        end
    end
end)
