-- Devlopped By Starxtrem --
local safe = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('starcheckpos', function(source, cb)
  local _source = source
  MySQL.Async.fetchAll('SELECT * FROM `starchest_access` WHERE `granted` = @granted ', { ['@granted'] = 1}, function(result)
    local position = {}
    for i,v in ipairs(result) do
      table.insert(position, {name = v.lieu, posx = v.x, posy = v.y, posz = v.z})
    end
    cb(position)
  end)
end)

ESX.RegisterServerCallback('starchest:can_open', function(source, cb, namePoint)
  local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll('SELECT * FROM `starchest_access` WHERE `lieu` = @lieu ',
	{
      ['@lieu'] = namePoint
    }, function(result)
        local members = {}
        local isOK = false
        local myclee = false

        for i,v in ipairs(result) do
            table.insert( members, {name = v.label, steam = v.owner, proprio = v.granted} )
            if v.owner == xPlayer.identifier then
                isOK = true
                if v.granted == 1 then
                  myclee = true
                end
            end
        end

        cb(isOK, namePoint, members, myclee)

	end)
end)

RegisterServerEvent("starchest:add_player")
AddEventHandler("starchest:add_player", function(pname, target)
    local _source = source

    local xTarget = ESX.GetPlayerFromId(target)

    MySQL.Async.execute('INSERT INTO starchest_access (owner, lieu, label, granted) VALUES (@owner, @lieu, @label, @granted)',
	{
		['@owner']   = xTarget.identifier,
		['@lieu']   = pname,
		['@label']   = xTarget.name,
		['@granted']   = 0
    })

	TriggerClientEvent('esx:showNotification', _source, _U('player_keys_ok'))
	TriggerClientEvent('esx:showNotification', target, "Vous avez reçu les clés pour le coffre : " .. pname)

end)

RegisterServerEvent("starchest:remove_player")
AddEventHandler("starchest:remove_player", function(steam ,pname)
    local _source = source
    MySQL.Async.execute('DELETE FROM starchest_access WHERE owner = @owner AND lieu = @lieu', {
        ['@owner'] = steam,
        ['@lieu'] = pname
    })

	TriggerClientEvent('esx:showNotification', _source, _U('player_keys_remove'))

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
            TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
          end
        else
          TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
        end

      end)

  else
    TriggerClientEvent('esx:showNotification', _source, _U('not_space'))
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
      TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
    end
end)

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
                TriggerClientEvent('esx:showNotification', _source, _U('op_ok'))
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, _U('error'))
    end
end)

RegisterServerEvent('starchest:sendBill')
AddEventHandler('starchest:sendBill', function(target, lieu, amount)
  local _target = target
  local tPlayer  = ESX.GetPlayerFromId(_target)
  if tPlayer ~= nil then
    TriggerClientEvent('starchest:QuestionBill', _target, source, lieu, amount)
  end
end)

RegisterServerEvent('starchest:AccesptPayementBills')
AddEventHandler('starchest:AccesptPayementBills', function(target, amount, lieu, a)
  local _source = source
  local xPlayer  = ESX.GetPlayerFromId(_source)
  local tPlayer  = ESX.GetPlayerFromId(target)

  if xPlayer ~= nil then
    if a then
      MySQL.Async.fetchAll(
        'SELECT * FROM starchest_2 WHERE lieu = @lieu;',
        {
          ['@lieu'] = lieu
        },
        function(result1)

          if amount > 0 and xPlayer.getBank() >= amount then

              MySQL.Async.fetchAll(
              'INSERT INTO starchest_2 (money,black,lieu) VALUES (@mon,@bla,@lieu) ON DUPLICATE KEY UPDATE money=money + @mon',
              {
                ['@lieu'] = lieu,
                ['@mon'] = amount,
                ['@bla'] = 0
              },
              function(result)
                local xPlayer = ESX.GetPlayerFromId(_source)
                if xPlayer ~= nil then
                  xPlayer.removeBank(amount)
                  xPlayer.showNotification("Vous avez payé une facture de $"..amount)
                  tPlayer.showNotification(xPlayer.name.." à payé une facture de $"..amount)
                end
              end)

          else
            xPlayer.showNotification("Vous n\'avez pas l'argent sur le compte en banque...")
            tPlayer.showNotification("la carte cb de "..xPlayer.name.." à été rejeté")
          end
        end)
      else
        xPlayer.showNotification('Vous avez refuser la facture de '..amount..'$')
        tPlayer.showNotification(xPlayer.name.." à déchiré la facture sous vos yeux de cocker... Sniff")
      end
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
                TriggerClientEvent('esx:showNotification', _source, _U('op_ok'))
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, _U('error'))
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
                TriggerClientEvent('esx:showNotification', _source, _U('op_ok'))
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, _U('error'))
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
                TriggerClientEvent('esx:showNotification', _source, _U('op_ok'))
              end
            end)

        else
          TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
        end
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, _U('error'))
    end
end)

--coffre utilisable

ESX.RegisterUsableItem('coffreauto', function(source)
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local thePos = GetEntityCoords(GetPlayerPed(xPlayer.source))
  local numbercoffre = math.random(5000)
  xPlayer.removeInventoryItem('coffreauto', 1)

    MySQL.Async.execute('INSERT INTO starchest_access (owner, lieu, label,x ,y, z, granted) VALUES (@owner, @lieu, @label, @x, @y, @z, @granted)',
    {
      ['@owner']   = xPlayer.identifier,
      ['@lieu']   = 'Coffre'..numbercoffre,
      ['@label']   = xPlayer.name,
      ['@x']   = thePos.x,
      ['@y']   = thePos.y,
      ['@z']   = thePos.z,
      ['@granted']   = 1
    })

	xPlayer.showNotification(_U('chest_pos_sucess'))
  TriggerClientEvent('starchest:updatePos', -1, 'Coffre'..numbercoffre, thePos.x, thePos.y, thePos.z)
end)

-- Devlopped By Starxtrem --
