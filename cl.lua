-- Devlopped By Starxtrem --
local QuestionBill = false
local QuestionLieu = ''
local QuestionAmount = 0
local QuestionSource = 0
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
            --COFFRES = {[v.name] = {v.name, x = tonumber(v.posx), y = tonumber(v.posy), z = tonumber(v.posz)}}
        end
    end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('starchest:updatePos')
AddEventHandler('starchest:updatePos', function(name, x, y, z)
	--COFFRES = {}
	--ESX.TriggerServerCallback('starcheckpos', function(position)
	--		for i,v in ipairs(position) do
                    --COFFRES = {[v.name] = {v.name, x = tonumber(v.posx), y = tonumber(v.posy), z = tonumber(v.posz)}}
					table.insert(COFFRES, {
							name     = name,
							x     = tonumber(x),
							y     = tonumber(y),
							z     = tonumber(z)
					})
	--		end
	--end)
end)

RegisterNetEvent('starchest:QuestionBill')
AddEventHandler('starchest:QuestionBill', function(sousource, lieu, amount)
	ESX.ShowNotification('Appuyez sur ~b~Y~w~ pour payer ou ~b~N~w~ pour refuser ('..amount..'$)')
	QuestionSource = sousource
	QuestionBill = true
	QuestionAmount = amount
	QuestionLieu = lieu
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
        safe = CreateObject("prop_ld_int_safe_01", x, y, z, true, true, true)
        PlaceObjectOnGroundProperly(safe)
        FreezeEntityPosition(safe, true)
    end
    star = true
end)

--[[RegisterNetEvent('starchest:checkcoffredistdelcl')
AddEventHandler('starchest:checkcoffredistdelcl', function()
    if starcount > 0 then
        starcount = 0
        DeleteEntity(safe)
        safe = nil
    end
end)]]

Citizen.CreateThread(function()
	--Citizen.Wait(2000)
    while true do
        Citizen.Wait(3000)
        star = false
    end
end)

Citizen.CreateThread(function()
	--Citizen.Wait(2000)
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
end)

Citizen.CreateThread(function()
	--Citizen.Wait(2000)
	while true do
		Citizen.Wait(0)
        for k2,v2 in pairs(COFFRES) do
            if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v2.x, v2.y, v2.z, true) < 20 then
                star = true

                --DrawMarker(25, v2.x, v2.y, v2.z - 0.9, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.5, 2.5, 1.0, 185, 185, 185, 250, false, true, 2, false, false, false, false)

                if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v2.x, v2.y, v2.z, true) < 2.5 then

                    if IsControlJustReleased(0, 38) then -- E
                        ESX.TriggerServerCallback('starchest:can_open', function (allowed, Pname, members, proprio)
                            if allowed == true then

                                ESX.UI.Menu.CloseAll()

                                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'coffre_main',
                                {
                                    title    = "Coffre " .. Pname,
                                    elements = {
                                        { label = "Gestion des clés", value = "manage" },
                                        { label = "Facturation", value = "fact" },
                                        { label = "Inventaire", value = "inv" },
                                        { label = "Coffre d'argent", value = "money" },
                                        {label = 'Passer une annonce', value = 'announce'}
                                    }
                                }, function(data, menu)

                                    menu.close()

                                    if data.current.value == 'manage' then
                                        local els = {}
                                        if proprio == true then
                                            table.insert(els, {label = "Inviter le joueur proche", value = "add_player"})
                                            for i,v in ipairs(members) do
                                                table.insert(els, {label = "Retirer " .. v.name, value = "remove_player", steam = v.steam })
                                            end
                                        else
                                            table.insert(els, {label = "Interdit"})
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

                                            if data2.current.value == 'remove_player' then
                                                TriggerServerEvent("starchest:remove_player", data2.current.steam, Pname)
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
                                                ESX.ShowNotification('Montant invalide')
                                            else
                                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                                if closestPlayer == -1 or closestDistance > 3.0 then
                                                    ESX.ShowNotification('Personne devant vous !')
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
                                    if data.current.value == 'announce' then
                                        messagenotfinish = true
                                        Message()
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
            --else
            --    star = false
            end
        end
        if not star then
            Citizen.Wait(2000)
        end
	end
end)


function Message()
    Citizen.CreateThread(function()
      while messagenotfinish do
          Citizen.Wait(1)
  
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
          while (UpdateOnscreenKeyboard() == 0) do
              DisableAllControlActions(0);
             Citizen.Wait(1)
          end
          if (GetOnscreenKeyboardResult()) then
              local result = GetOnscreenKeyboardResult()
              messagenotfinish = false
             TriggerServerEvent('starchest:annonce',result)
  
          end
      end
    end)
end

function DrawAdvancedTextCNN (x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end


 Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)

                if (affichenews == true) then

                DrawRect(0.494, 0.227, 5.185, 0.118, 0, 0, 0, 150)
                DrawAdvancedTextCNN(0.588, 0.14, 0.005, 0.0028, 0.8, "~r~ Annonce entreprise ~d~", 255, 255, 255, 255, 1, 0)
                DrawAdvancedTextCNN(0.586, 0.199, 0.005, 0.0028, 0.6, texteafiche, 255, 255, 255, 255, 7, 0)
                DrawAdvancedTextCNN(0.588, 0.246, 0.005, 0.0028, 0.4, "", 255, 255, 255, 255, 0, 0)

                else
                Citizen.Wait(500)

            end
       end
    end)



RegisterNetEvent('starchest:annonce')
AddEventHandler('starchest:annonce', function(text)
    texteafiche = text
    affichenews = true

  end)


RegisterNetEvent('starchest:annoncestop')
AddEventHandler('starchest:annoncestop', function()
    affichenews = false
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


AddEventHandler('onResourceStop',function(resource)
    if resource == GetCurrentResourceName() then
        DeleteEntity(safe)
    end
end)

-- Devlopped By Starxtrem --
