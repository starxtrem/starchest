-- Devlopped By Starxtrem --

-- Check version

Citizen.CreateThread( function()
    if Config.CheckVersion then
        updatePath = "/starxtrem/starchest" -- your git user/repo path
        resourceName = "starchest ("..GetCurrentResourceName()..")" -- the resource name
        
        function checkVersion(err,responseText, headers)
            curVersion = LoadResourceFile(GetCurrentResourceName(), "version") -- make sure the "version" file actually exists in your resource root!

            if curVersion ~= responseText then
                print("###############################")
                print(_U('version_outdated').. "\nhttps://github.com"..updatePath.."")
                print("###############################")
            else
                print(_U('version_current'))
            end
        end

        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end
end)

-- visu coffre

RegisterServerEvent('starchest:checkcoffredist')
AddEventHandler('starchest:checkcoffredist',function(name, status, x, y, z)
  local _source = source
  if safe[name] == nil then
    safe[name] = false
  end
  if status == true then
    if safe[name] == false then
      safe[name] = true
      TriggerClientEvent('starchest:checkcoffredistcl',source, x, y, z, name)
    end
  end
end)

-- annonce

RegisterServerEvent('starchest:annonce')
AddEventHandler('starchest:annonce', function(result)
  local _source  = source
  local xPlayer  = ESX.GetPlayerFromId(_source)
  local xPlayers = ESX.GetPlayers()
  local text     = result
  for i=1, #xPlayers, 1 do
    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
    TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], _U('label_announce'), '', ''..text, 'CHAR_LIFEINVADER')
  end
end)

-- delete chest

RegisterServerEvent('starchest:delete')
AddEventHandler('starchest:delete',function(name)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  xPlayer.showNotification(_U('delete_chestok'))
  MySQL.Async.execute('DELETE FROM starchest_access WHERE lieu = @name',
  {
    ['@name'] = name
  })
end)

-- Add Chest admin

RegisterCommand('addchest', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local thePos = GetEntityCoords(GetPlayerPed(xPlayer.source))
    local numbercoffre = math.random(5000)
  
    if xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == 'admin' then
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
    else
      xPlayer.showNotification(_U('no_admin'))
    end
end)

-- Delete Chest admin

RegisterCommand('deletechest', function(source , args)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local name = args[1]
    local namegood = 'Coffre'..name 
  
    if xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == 'admin' then
        MySQL.Async.execute('DELETE FROM starchest_access WHERE lieu = @name',
        {
          ['@name'] = namegood
        })
        xPlayer.showNotification(_U('delete_chestok'))
        TriggerClientEvent('starchest:deletechest', -1, namegood)
    else
      xPlayer.showNotification(_U('no_admin'))
    end
end)

-- Change owner

RegisterCommand('changeowner', function(source , args)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local name = args[1]
    local namegood = 'Coffre'..name 
    local newowner = args[2]
  
    if xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == 'admin' then
        MySQL.Async.execute('UPDATE starchest_access SET owner = @newowner WHERE lieu = @name',
        {
          ['@name'] = namegood,
          ['@newowner'] = newowner
        })
        xPlayer.showNotification(_U('change_ownerok'))
    else
      xPlayer.showNotification(_U('no_admin'))
    end
end)


-- Devlopped By Starxtrem --