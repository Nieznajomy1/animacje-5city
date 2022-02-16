local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) 
	ESX = obj 
end)

RegisterServerEvent('whistle:Get')
AddEventHandler('whistle:Get', function(event,targetID)
	TriggerClientEvent("whistle:Status",targetID,event,source)
end)

RegisterServerEvent('cmg3_animations:sync')
AddEventHandler('cmg3_animations:sync', function(target, animationLib,animationLib2, animation, animation2, distans, distans2, height,targetSrc,length,spin,controlFlagSrc,controlFlagTarget,animFlagTarget,attachFlag)
	TriggerClientEvent('cmg3_animations:syncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length,spin,controlFlagTarget,animFlagTarget,attachFlag)
	TriggerClientEvent('cmg3_animations:syncMe', source, animationLib, animation,length,controlFlagSrc,animFlagTarget)
end)

RegisterServerEvent('cmg3_animations:stop')
AddEventHandler('cmg3_animations:stop', function(targetSrc)
	TriggerClientEvent('cmg3_animations:cl_stop', targetSrc)
end)

RegisterServerEvent('whistle:Send')
AddEventHandler('whistle:Send', function(event,targetID,whistle)
	TriggerClientEvent(event,targetID,whistle)
end)

RegisterServerEvent('whistle:Hands')
AddEventHandler('whistle:Hands', function(event,targetID,whistle)
	TriggerClientEvent(event,targetID,whistle)
end)

--User
RegisterServerEvent('w_animki:OdpalAnimacje4')
AddEventHandler('w_animki:OdpalAnimacje4', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	
	xTarget.showNotification('Naciśnij [E] aby wykonać wspólną animację (podnies)')
	TriggerClientEvent('w_animki:przytulSynchroC2', xTarget.source, xPlayer.source)
end)

RegisterServerEvent('w_animki:OdpalAnimacje5')
AddEventHandler('w_animki:OdpalAnimacje5', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)

	TriggerClientEvent('cmg2_animations:startMenu2', xTarget.source)
end)

RegisterServerEvent('cmg2_animations:sync')
AddEventHandler('cmg2_animations:sync', function(target, animationLib,animationLib2, animation, animation2, distans, distans2, height,targetSrc,length,spin,controlFlagSrc,controlFlagTarget,animFlagTarget)
	TriggerClientEvent('cmg2_animations:syncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length,spin,controlFlagTarget,animFlagTarget)
	TriggerClientEvent('cmg2_animations:syncMe', source, animationLib, animation,length,controlFlagSrc,animFlagTarget)
end)

RegisterServerEvent('cmg2_animations:stop')
AddEventHandler('cmg2_animations:stop', function(target)
	local xTarget = ESX.GetPlayerFromId(target)
	if xTarget ~= nil then
		TriggerClientEvent('cmg2_animations:cl_stop', xTarget.source)
	end
end)

RegisterServerEvent('w_animki:propka')
AddEventHandler('w_animki:propka', function(chlop, animka, pozycjaa, jakaanimkaaaa)
	TriggerClientEvent('esx_animations:akcept', chlop, source, animka, pozycjaa, jakaanimkaaaa)
end)

RegisterServerEvent('w_animki:propka')
AddEventHandler('w_animki:propka', function(cosiedzieje, kto, jakaanimka)
	if cosiedzieje == "AKCEPT" then
		TriggerClientEvent('esx_animations:graba', kto, jakaanimka, "chujwiektojanie")
	end
end)

RegisterServerEvent('richrp_animacje:requestSynced')
AddEventHandler('richrp_animacje:requestSynced', function(zmienna1, zmienna2)
	local _source = source
	TriggerClientEvent('richrp_animacje:syncRequest', zmienna1, _source, zmienna2)
end)

RegisterServerEvent('richrp_animacje:requestSynced')
AddEventHandler('richrp_animacje:requestSynced', function(zmienna1, zmienna2)
	local _source = source
	TriggerClientEvent('richrp_animacje:syncRequest', zmienna1, _source, zmienna2)
end)

RegisterServerEvent('richrp_animacje:syncAccepted')
AddEventHandler('richrp_animacje:syncAccepted', function(zmienna1, zmienna2)
	local _source = source
	TriggerClientEvent('richrp_animacje:playSynced', zmienna1, _source, zmienna2, 'Requester')
	TriggerClientEvent('richrp_animacje:playSynced', _source, zmienna1, zmienna2, 'Accepter')
end)