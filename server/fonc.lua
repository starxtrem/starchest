-- Check version

Citizen.CreateThread( function()
    if Config.CheckVersion then
        updatePath = "/starxtrem/starchest" -- your git user/repo path
        resourceName = "starchest ("..GetCurrentResourceName()..")" -- the resource name
        
        function checkVersion(err,responseText, headers)
            curVersion = LoadResourceFile(GetCurrentResourceName(), "version") -- make sure the "version" file actually exists in your resource root!

            if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
                print("###############################")
                print(_U('version_outdated').. "\n" ..curVersion.." ".._U('version_to').." "..responseText.."\nhttps://github.com"..updatePath.."")
                print("###############################")
            elseif tonumber(curVersion) > tonumber(responseText) then
                print(_U('version_not_found'))
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