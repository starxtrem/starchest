-- Devlopped By Starxtrem --

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('starchest:can_open', function(source, cb, namePoint)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    
    MySQL.Async.fetchAll('SELECT * FROM `starchest_access` WHERE `lieu` = @lieu ;',
	{
        ['@lieu'] = namePoint
    }, function(result)
        
        local members = {}
        local isOK = false

        for i,v in ipairs(result) do
            table.insert( members, {name = v.label, steam = v.owner} )
            if v.owner == xPlayer.identifier then
                isOK = true
            end
        end

        cb(isOK, namePoint, members)

	end)
end)

RegisterServerEvent("starchest:add_player")
AddEventHandler("starchest:add_player", function(pname, target)
    local _source = source

    local xTarget = ESX.GetPlayerFromId(target)

    MySQL.Async.execute('INSERT INTO starchest_access (owner, lieu, label) VALUES (@owner, @lieu, @label)',
	{
		['@owner']   = xTarget.identifier,
		['@lieu']   = pname,
		['@label']   = xTarget.name
    })
    
	TriggerClientEvent('esx:showNotification', _source, "Le joueur à reçu des clés")
	TriggerClientEvent('esx:showNotification', target, "Vous avez reçu les clés pour le coffre : " .. pname)
	
end)

RegisterServerEvent("starchest:remove_player")
AddEventHandler("starchest:remove_player", function(pname, steam)
    local _source = source

    MySQL.Async.execute('DELETE FROM starchest_access WHERE owner = @owner AND lieu = @lieu ;', {
        ['@owner'] = steam,
        ['@lieu'] = pname
    })
    
	TriggerClientEvent('esx:showNotification', _source, "Le joueur à perdu ses clés")
	
end)

AddEventHandler("esxStar:ReloadESX", function (obj)
	ESX = obj
end)


function getInventoryWeight(inventory)
  local weight = 0
  local itemWeight = 0

  if inventory ~= nil then
	  for i=1, #inventory, 1 do
	    if inventory[i] ~= nil then
	      itemWeight = 1.0
	      if ESX.Items[inventory[i].name] ~= nil then
	        itemWeight = ESX.Items[inventory[i].name].ppi
	      end
	      weight = weight + (itemWeight * inventory[i].count)
	    end
	  end
  end
  return weight
end

RegisterServerEvent('starchest:getInventory')
AddEventHandler('starchest:getInventory', function(plate)
  local inventory_ = {}
  local _source = source
  MySQL.Async.fetchAll(
    'SELECT * FROM `starchest` WHERE `lieu` = @plate',
    {
      ['@plate'] = plate
    },
    function(inventory)
      if inventory ~= nil and #inventory > 0 then
        for i=1, #inventory, 1 do
          table.insert(inventory_, {
            label      = inventory[i].name,
            name      = inventory[i].item,
            count     = inventory[i].count,
          })
        end
      end
    local xPlayer  = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('starchest:getInventoryLoaded', xPlayer.source, plate, inventory_)
    end)
end)

RegisterServerEvent('starchest:removeInventoryItem')
AddEventHandler('starchest:removeInventoryItem', function(plate, item, count)
  local _source = source
  local xPlayer_pre  = ESX.GetPlayerFromId(_source)
  print(ESX.GetPlayerFromId(_source))
  if xPlayer_pre ~= nil or xPlayer_pre.canCarryItems({{item, count}}) then

    MySQL.Async.fetchAll(
    'SELECT * FROM starchest WHERE item = @item AND lieu = @plate;',
    {
      ['@plate'] = plate,
      ['@item'] = item,
    },
    function(result1)

      if result1[1] ~= nil then
        if (result1[1].count - count) >= 0 then

          MySQL.Async.fetchAll(
            'UPDATE `starchest` SET `count`= `count` - @qty WHERE `lieu` = @plate AND `item`= @item',
            {
              ['@plate'] = plate,
              ['@qty'] = count,
              ['@item'] = item
            },
            function(result)
              local xPlayer  = ESX.GetPlayerFromId(_source)
              if xPlayer ~= nil then
                xPlayer.addInventoryItem(item, count)
              end
            end)

          else
            TriggerClientEvent('esx:showNotification', _source, "Il n'y a pas assez dans le coffre")
          end
        else
          TriggerClientEvent('esx:showNotification', _source, "Il n'y a pas assez dans le coffre")
        end
  
      end)

  else
    TriggerClientEvent('esx:showNotification', _source, "Tu n'as plus de place sur toi")
  end
end)

RegisterServerEvent('starchest:addInventoryItem')
AddEventHandler('starchest:addInventoryItem', function(plate, item, count, name)
  local _source = source
  local xPlayer_pre  = ESX.GetPlayerFromId(_source)
  if xPlayer_pre ~= nil or xPlayer_pre.canCarryItems({{item, 0 - count}}) then

    MySQL.Async.fetchAll(
      'SELECT * FROM starchest WHERE item = @item AND lieu = @plate;',
      {
        ['@plate'] = plate,
        ['@item'] = item,
      },
      function(result1)

        local inTruck = 0
        if result1[1] ~= nil then
          inTruck = result1[1].count
        end

          MySQL.Async.fetchAll(
            'INSERT INTO starchest (item,count,lieu,name) VALUES (@item,@qty,@plate,@name) ON DUPLICATE KEY UPDATE count=count+ @qty',
            {
              ['@plate'] = plate,
              ['@qty'] = count,
              ['@item'] = item,
              ['@name'] = name
            },
            function(result)
              local xPlayer  = ESX.GetPlayerFromId(_source)
              if xPlayer ~= nil then
                xPlayer.removeInventoryItem(item, count)
              end
            end)
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, "Tu n'as pas assez sur toi")
    end
end)

----------------------------------------------------------------------  COFFRE : ARGENT PROPRE ET SALE

ESX.RegisterServerCallback('starchest:fetchMoney', function(source, cb, namePoint)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
	local account = xPlayer.getAccount('black_money')
    
    MySQL.Async.fetchAll('SELECT * FROM `starchest_2` WHERE `lieu` = @lieu ;',
    {
        ['@lieu'] = namePoint
    }, function(result)
      
        local a = 0
        local b = 0

        if result[1] ~= nil then
          a = result[1].money
          b = result[1].black
        end

        cb(a, b, xPlayer.getMoney(), account.money)
  end)
end)

RegisterServerEvent('starchest:money:deposit_money')
AddEventHandler('starchest:money:deposit_money', function(plate, amount)
  local _source = source
  local xPlayer_pre  = ESX.GetPlayerFromId(_source)
  local count = ESX.Math.Round(tonumber(amount))
  if xPlayer_pre ~= nil then

    MySQL.Async.fetchAll(
      'SELECT * FROM starchest_2 WHERE lieu = @plate;',
      {
        ['@plate'] = plate
      },
      function(result1)

        if count > 0 and xPlayer_pre.getMoney() >= count then

            MySQL.Async.fetchAll(
            'INSERT INTO starchest_2 (money,black,lieu) VALUES (@mon,@bla,@plate) ON DUPLICATE KEY UPDATE money=money+ @mon',
            {
              ['@plate'] = plate,
              ['@mon'] = count,
              ['@bla'] = 0
            },
            function(result)
              local xPlayer = ESX.GetPlayerFromId(_source)
              if xPlayer ~= nil then
                xPlayer.removeMoney(count)
                TriggerClientEvent('esx:showNotification', _source, "Opération réussi")
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, "Tu n'as pas assez / Quantité invalide")
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, "Petit soucis, ré-essaye")
    end
end)


RegisterServerEvent('starchest:money:deposit_sale')
AddEventHandler('starchest:money:deposit_sale', function(plate, amount)
  local _source = source
  local xPlayer_pre  = ESX.GetPlayerFromId(_source)
	local account = xPlayer_pre.getAccount('black_money')
  local count = ESX.Math.Round(tonumber(amount))
  if xPlayer_pre ~= nil then

    MySQL.Async.fetchAll(
      'SELECT * FROM starchest_2 WHERE lieu = @plate;',
      {
        ['@plate'] = plate
      },
      function(result1)

        if count > 0 and account.money >= count then

            MySQL.Async.fetchAll(
            'INSERT INTO starchest_2 (money,black,lieu) VALUES (@mon,@bla,@plate) ON DUPLICATE KEY UPDATE black=black+ @bla',
            {
              ['@plate'] = plate,
              ['@mon'] = 0,
              ['@bla'] = count
            },
            function(result)
              local xPlayer = ESX.GetPlayerFromId(_source)
              if xPlayer ~= nil then
                xPlayer.removeAccountMoney('black_money', count)
                TriggerClientEvent('esx:showNotification', _source, "Opération réussi")
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, "Tu n'as pas assez / Quantité invalide")
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, "Petit soucis, ré-essaye")
    end
end)


RegisterServerEvent('starchest:money:retirer_money')
AddEventHandler('starchest:money:retirer_money', function(plate, amount)
  local _source = source
  local xPlayer_pre  = ESX.GetPlayerFromId(_source)
  local count = ESX.Math.Round(tonumber(amount))
  if xPlayer_pre ~= nil then

    MySQL.Async.fetchAll(
      'SELECT * FROM starchest_2 WHERE lieu = @plate;',
      {
        ['@plate'] = plate
      },
      function(result1)

        if count > 0 and result1[1] ~= nil and result1[1].money >= count then

            MySQL.Async.fetchAll(
            'INSERT INTO starchest_2 (money,black,lieu) VALUES (0,0,@plate) ON DUPLICATE KEY UPDATE money=money- @mon',
            {
              ['@plate'] = plate,
              ['@mon'] = count
            },
            function(result)
              local xPlayer = ESX.GetPlayerFromId(_source)
              if xPlayer ~= nil then
                xPlayer.addMoney(count)
                TriggerClientEvent('esx:showNotification', _source, "Opération réussi")
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, "Il n'y a pas assez / Quantité invalide")
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, "Petit soucis, ré-essaye")
    end
end)


RegisterServerEvent('starchest:money:retirer_sale')
AddEventHandler('starchest:money:retirer_sale', function(plate, amount)
  local _source = source
  local xPlayer_pre  = ESX.GetPlayerFromId(_source)
	local account = xPlayer_pre.getAccount('black_money')
  local count = ESX.Math.Round(tonumber(amount))
  if xPlayer_pre ~= nil then

    MySQL.Async.fetchAll(
      'SELECT * FROM starchest_2 WHERE lieu = @plate;',
      {
        ['@plate'] = plate
      },
      function(result1)

        if count > 0 and result1[1] ~= nil and result1[1].black >= count then

            MySQL.Async.fetchAll(
            'INSERT INTO starchest_2 (money,black,lieu) VALUES (0,0,@plate) ON DUPLICATE KEY UPDATE black=black- @bla',
            {
              ['@plate'] = plate,
              ['@bla'] = count
            },
            function(result)
              local xPlayer = ESX.GetPlayerFromId(_source)
              if xPlayer ~= nil then
                xPlayer.addAccountMoney('black_money', count)
                TriggerClientEvent('esx:showNotification', _source, "Opération réussi")
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, "Il n'y a pas assez / Quantité invalide")
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, "Petit soucis, ré-essaye")
    end
end)


-- Devlopped By Starxtrem --