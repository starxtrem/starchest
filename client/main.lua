-- Devlopped By Starxtrem --
local QuestionBill = false
local QuestionLieu = ''
local QuestionAmount = 0
local QuestionSource = 0
ESX = nil

local COFFRES = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end
    Citizen.Wait(1500)
    ESX.TriggerServerCallback('starcheckpos', function(position)
        for i,v in ipairs(position) do
			table.insert(COFFRES, {
        	    name     = v.name,
			    x     = tonumber(v.posx),
			    y     = tonumber(v.posy),
			    z     = tonumber(v.posz)
			})
        end
    end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

-- Update Position
RegisterNetEvent('starchest:updatePos')
AddEventHandler('starchest:updatePos', function(name, x, y, z)
	table.insert(COFFRES, {
		name     = name,
		x     = tonumber(x),
		y     = tonumber(y),
		z     = tonumber(z)
	})
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if QuestionBill then
			if IsControlJustReleased(0, 246) then
				TriggerServerEvent('starchest:AccesptPayementBills', QuestionSource, QuestionAmount, QuestionLieu, true)
				QuestionBill = false
				QuestionLieu = ''
				QuestionAmount = 0
				QuestionSource = 0
			elseif IsControlJustReleased(0, 249) then
				TriggerServerEvent('starchest:AccesptPayementBills', QuestionSource, QuestionAmount, QuestionLieu, false)
				QuestionBill = false
				QuestionLieu = ''
				QuestionAmount = 0
				QuestionSource = 0
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
local starcount = {}
local safe = nil
local star = false

RegisterNetEvent('starchest:checkcoffredistcl')
AddEventHandler('starchest:checkcoffredistcl', function(x, y, z, ff)
    if starcount[ff] == nil then
        starcount[ff] = true
        safe = CreateObject(Config.PropsChestName, x, y, z, true, true, true)
        PlaceObjectOnGroundProperly(safe)
        FreezeEntityPosition(safe, true)
    end
    star = true
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        star = false
    end
end)

Citizen.CreateThread(function()
    if Config.PropsChest then
        while true do
            Citizen.Wait(1500)
            if star == true then
                for k2,v2 in pairs(COFFRES) do
                    if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v2.x, v2.y, v2.z, true) < 20 then
                        TriggerServerEvent('starchest:checkcoffredist',v2.name, true, v2.x, v2.y, v2.z)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        for k2,v2 in pairs(COFFRES) do
            if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v2.x, v2.y, v2.z, true) < 20 then
                star = true
                if Config.PropsChest == false then
                    DrawMarker(27, v2.x, v2.y, v2.z - 0.9, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.6, 0.6, 0.6, 25, 28, 24, 250, false, true, 2, false, false, false, false)
                end
                if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v2.x, v2.y, v2.z, true) < 2.5 then
                    if IsControlJustReleased(0, 38) then -- E
                        ESX.TriggerServerCallback('starchest:can_open', function (allowed, Pname, members, proprio)
                            if allowed == true then
                                ESX.UI.Menu.CloseAll()
                                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'coffre_main',
                                {
                                    title    = Pname,
                                    elements = {
                                        { label = _U('keys_gest'), value = "manage" },
                                        { label = _U('billing'), value = "fact" },
                                        { label = _U('inventory'), value = "inv" },
                                        { label = _U('money_chest'), value = "money" },
                                        { label = _U('announce'), value = 'announce'},
                                    }
                                }, function(data, menu)

                                    menu.close()

                                    if data.current.value == 'manage' then
                                        local els = {}
                                        if proprio == true then
                                            if Config.DeleteChestPlayer then
                                                table.insert(els, {label = "Supprimer le coffre", value = "delete"})
                                            end
                                            table.insert(els, {label = _U('invite_player'), value = "add_player"})
                                            for i,v in ipairs(members) do
                                                table.insert(els, {label = _U('remove_keys') .. v.name, value = "remove_player", steam = v.steam })
                                            end
                                        else
                                            table.insert(els, {label = "Interdit"})
                                        end
                                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'coffre_manage',
                                        {
                                            title    = "Clés du " .. Pname,
                                            elements = els
                                        }, function(data2, menu2)

                                            menu2.close()

                                            if data2.current.value == 'add_player' then
                                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                                if closestDistance > 0 and closestDistance < 4 then
                                                    TriggerServerEvent("starchest:add_player", Pname, GetPlayerServerId(closestPlayer))
                                                else
                                                    ESX.ShowNotification(_U('no_player_found'))
                                                end
                                            end

                                            if data2.current.value == 'remove_player' then
                                                TriggerServerEvent("starchest:remove_player", data2.current.steam, Pname)
                                            end

                                            if data2.current.value == 'delete' then
                                                TriggerServerEvent("starchest:delete", Pname)
                                            end

                                        end, function(data2, menu2)
                                            menu2.close()
                                        end)

                                    end

                                    if data.current.value == 'fact' then
                                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'fact', {
                                            title = 'Montant ?'
                                        }, function(data, menu)
                                            local amount = tonumber(data.value)
                                            if amount == nil or amount < 0 then
                                                ESX.ShowNotification(_U('invalid_amount'))
                                            else
                                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                                if closestPlayer == -1 or closestDistance > 3.0 then
                                                    ESX.ShowNotification(_U('no_player_found'))
                                                else
                                                    menu.close()
                                                    TriggerServerEvent('starchest:sendBill', GetPlayerServerId(closestPlayer), Pname, amount)
                                                end
                                            end
                                        end, function(data, menu)
                                            menu.close()
                                        end)
                                    end

                                    if data.current.value == "inv" then
                                        TriggerServerEvent("starchest:getInventory", Pname)
                                    end

                                    if data.current.value == 'money' then

                                        ESX.TriggerServerCallback('starchest:fetchMoney', function (propreC, saleC, propreP, saleP)

                                            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'coffre_manage',
                                            {
                                                title    = "Clés du coffre " .. Pname,
                                                elements = {
                                                    { label = "Sur toi : " .. propreP .. " $ | " .. saleP .. " $", value = "none" },
                                                    { label = "Coffre : " .. propreC .. " $ | " .. saleC .. " $", value = "none" },
                                                    { label = "---------------", value = "none" },
                                                    { label = "Déposer de l'argent", value = "deposit_money" },
                                                    { label = "Récupérer de l'argent", value = "retirer_money" },
                                                    { label = "---------------", value = "none" },
                                                    { label = "Déposer de l'argent sale", value = "deposit_sale" },
                                                    { label = "Récupérer de l'argent sale", value = "retirer_sale" }
                                                }
                                            }, function(data2, menu2)

                                                menu2.close()

                                                if data2.current.value ~= "none" then
                                                    local ACTION = data2.current.value

                                                    ESX.UI.Menu.Open(
                                                    'dialog', GetCurrentResourceName(), 'inventory_item_count_give',
                                                    {
                                                        title = 'Montant'
                                                    },
                                                    function(data3, menu3)

                                                        local quantity = tonumber(data3.value)

                                                        if quantity > 0 then

                                                            TriggerServerEvent("starchest:money:" .. ACTION, Pname, quantity)

                                                        else
                                                            ESX.ShowNotification(_U('invalid_quantity'))
                                                        end
                                                        ESX.UI.Menu.CloseAll()

                                                    end,
                                                    function(data3, menu3)
                                                        ESX.UI.Menu.CloseAll()
                                                    end
                                                    )

                                                end

                                            end, function(data2, menu2)
                                                menu2.close()
                                            end)

                                        end, Pname)

                                    end
                                    if data.current.value == 'announce' then
                                        Message()
                                    end

                                end, function(data, menu)
                                    menu.close()
                                end)

                            else
                                ESX.ShowNotification(_U('no_key'))
                            end
                        end, v2.name)

                        Citizen.Wait(300)

                    end
                end
            end
        end
        if not star then
            Citizen.Wait(2000)
        end
	end
end)

local PlayerData = {}
local Actual_pname = ""

RegisterNetEvent('starchest:getInventoryLoaded')
AddEventHandler('starchest:getInventoryLoaded', function(pname, inventory)
    local elements = {}
    Actual_pname = pname

    table.insert(elements, {
        label     = 'Déposer',
        count     = 0,
        value     = 'deposit'
    })

    if inventory ~= nil and #inventory > 0 then
        for i=1, #inventory, 1 do
            if inventory[i].count > 0 then
                table.insert(elements, {
                    label     = inventory[i].label .. ' x' .. inventory[i].count,
                    count     = inventory[i].count,
                    value     = inventory[i].name
                })
            end
        end
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'coffre_inv_star',
        {
          title    = 'Contenu du coffre',
          align    = 'bottom-right',
          elements = elements,
        },
        function(data, menu)
            if data.current.value == 'deposit' then
                local elem = {}
                PlayerData = ESX.GetPlayerData()
                for i=1, #PlayerData.inventory, 1 do
                    if PlayerData.inventory[i].count > 0 then
                        table.insert(elem, {
                            label  = PlayerData.inventory[i].label .. ' x' .. PlayerData.inventory[i].count,
                            count  = PlayerData.inventory[i].count,
                            value  = PlayerData.inventory[i].name,
                            name   = PlayerData.inventory[i].label
                        })
                    end
                end
                ESX.UI.Menu.Open(
                    'default', GetCurrentResourceName(), 'inventory_player',
                    {
                        title    = 'Contenu de l\'inventaire',
                        align    = 'bottom-right',
                        elements = elem,
                    },
                    function(data3, menu3)
                        ESX.UI.Menu.Open(
                            'dialog', GetCurrentResourceName(), 'inventory_item_count_give',
                            {
                                title = 'quantité'
                            },
                            function(data4, menu4)
                                local quantity = tonumber(data4.value)
                                if quantity > 0 and quantity <= tonumber(data3.current.count)  then
                                        TriggerServerEvent('starchest:addInventoryItem', Actual_pname, data3.current.value, quantity, data3.current.name)
                                else
                                    ESX.ShowNotification(_U('invalid_quantity'))
                                end

                                ESX.UI.Menu.CloseAll()


                            end,
                            function(data4, menu4)
                                ESX.UI.Menu.CloseAll()
                            end
                        )
                    end,
                    function(data3, menu3)
                        ESX.UI.Menu.CloseAll()
                    end
                )
            else
                ESX.UI.Menu.Open(
                    'dialog', GetCurrentResourceName(), 'inventory_item_count_give',
                    {
                    title = 'quantité'
                    },
                    function(data2, menu2)

                        local quantity = tonumber(data2.value)
                        PlayerData = ESX.GetPlayerData()
                        for i=1, #PlayerData.inventory, 1 do

                            if PlayerData.inventory[i].name == data.current.value then
                                if tonumber(PlayerData.inventory[i].limit) <= tonumber(PlayerData.inventory[i].count) + quantity and PlayerData.inventory[i].limit ~= -1 then
                                    max = true
                                else
                                    max = false
                                end
                            end
                        end

                        if quantity > 0 and quantity <= tonumber(data.current.count) then
                            if not max then
                                TriggerServerEvent('starchest:removeInventoryItem', Actual_pname, data.current.value, quantity)

                            else
                                ESX.ShowNotification(_U('inventory_full'))
                            end
                        else
                            ESX.ShowNotification(_U('invalid_quantity'))
                        end

                        ESX.UI.Menu.CloseAll()
                    end,
                    function(data2, menu2)
                        ESX.UI.Menu.CloseAll()
                    end
                )
            end
        end,
        function(data, menu)
            ESX.UI.Menu.CloseAll()
        end
    )
end)

AddEventHandler('onResourceStop',function(resource)
    if resource == GetCurrentResourceName() then
        DeleteEntity(safe)
    end
end)

-- Devlopped By Starxtrem --
