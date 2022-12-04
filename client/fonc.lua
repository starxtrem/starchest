-- Annonce entreprise

function Message()
    Citizen.CreateThread(function()
        Citizen.Wait(1)
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Citizen.Wait(1)
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            TriggerServerEvent('starchest:annonce',result)
        end
    end)
end

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

--Bills Question

RegisterNetEvent('starchest:QuestionBill')
AddEventHandler('starchest:QuestionBill', function(sousource, lieu, amount)
	ESX.ShowNotification('Appuyez sur ~b~Y~w~ pour payer ou ~b~N~w~ pour refuser ('..amount..'$)')
	QuestionSource = sousource
	QuestionBill = true
	QuestionAmount = amount
	QuestionLieu = lieu
end)