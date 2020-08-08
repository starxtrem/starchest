-- Devlopped By Starxtrem --

ESX = nil

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local COFFRES = {
    ["Tattoosud"] = { name = "Tattoosud", x = 1315.77, y = -1658.13, z = 50.24},

    ["Tattoonord"] = { name = "Tattoonord", x = 1859.65, y = 3750.89, z = 32.05}
}

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        local star = false
        for k2,v2 in pairs(COFFRES) do
            
            if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v2.x, v2.y, v2.z, true) < 20 then
                star = true
                DrawMarker(25, v2.x, v2.y, v2.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.5, 2.5, 1.0, 185, 185, 185, 250, false, true, 2, false, false, false, false)
        
                if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v2.x, v2.y, v2.z, true) < 2.5 then
        
                    if IsControlJustReleased(0, 38) then -- E

                        ESX.TriggerServerCallback('starchest:can_open', function (allowed, Pname, members)
                            if allowed == true then
                                
                                ESX.UI.Menu.CloseAll()

                                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'coffre_main',
                                {
                                    title    = "Coffre " .. Pname,
                                    elements = {
                                        { label = "Gestion des clés", value = "manage" },
                                        { label = "Inventaire", value = "inv" },
                                        { label = "Coffre d'argent", value = "money" }
                                    }
                                }, function(data, menu)
                                    
                                    menu.close()

                                    if data.current.value == 'manage' then

                                        els = {{label = "Inviter le joueur proche", value = "add_player"}}
                                        for i,v in ipairs(members) do
                                            table.insert( els, {label = "Retirer " .. v.name, value = "remove_player", steam = v.steam} )
                                        end
                                        
                                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'coffre_manage',
                                        {
                                            title    = "Clés du coffre " .. Pname,
                                            elements = els
                                        }, function(data2, menu2)
                                            
                                            menu2.close()
                                            
                                            if data2.current.value == 'add_player' then
                                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                                if closestDistance > 0 and closestDistance < 4 then
                                                    TriggerServerEvent("starchest:add_player", Pname, GetPlayerServerId(closestPlayer))
                                                else
                                                    ESX.ShowNotification("Pas de joueur à proximité")
                                                end
                                            end

                                        end, function(data2, menu2)
                                            menu2.close()
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
                                                            ESX.ShowNotification("Quantité invalide")
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

                                end, function(data, menu)
                                    menu.close()
                                end)

                            else
                                ESX.ShowNotification("Tu n'as pas les clés")
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

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

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
                                    ESX.ShowNotification('~r~ Quantité invalide')
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
                                ESX.ShowNotification('~r~ Tu en porte trop')
                            end
                        else
                            ESX.ShowNotification('~r~ Quantité invalide')
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

-- Devlopped By Starxtrem --