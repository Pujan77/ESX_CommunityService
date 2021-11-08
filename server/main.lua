QBCore = exports['qb-core']:GetCoreObject()


--RegisterCommand( 'comserv', 'admin', function(source, args, user)
--	if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
--		TriggerEvent('esx_communityservice:sendToCommunityService', tonumber(args[1]), tonumber(args[2]))
--	else
--		TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id_or_actions') } } )
--	end
--end, function(source, args, user)
--	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
--end, {help = _U('give_player_community'), params = {{name = "id", help = _U('target_id')}, {name = "actions", help = _U('action_count_suggested')}}})
--_U('system_msn')
QBCore.Commands.Add("comserv", _U('give_player_community'), {{name = "id", help = _U('target_id')}, {name = "actions", help = _U('action_count_suggested')}}, false, function(source, args, user)
	local Player = QBCore.Functions.GetPlayer(source)
	if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
		TriggerEvent('esx_communityservice:sendToCommunityService', tonumber(args[1]), tonumber(args[2]))
	else
		TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id_or_actions') } } )
	end
end,"admin")

QBCore.Commands.Add("endcomserv", "End Community Service", { { name = "id", help = _U('target_id') } }, false, function(source, args, user)
    local Player = QBCore.Functions.GetPlayer(source)

    if args[1] then
        if args[1] ~= nil then
            TriggerEvent('esx_communityservice:endCommunityServiceCommand', tonumber(args[1]))
        else
            TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id') } })
        end
    else
        --print("SIP")
        
    end
end, "admin")

---- police ma add nabirsine


--TriggerEvent('es:addGroupCommand', 'endcomserv', 'admin', function(source, args, user)
--	if args[1] then
--		if GetPlayerName(args[1]) ~= nil then
--			TriggerEvent('esx_communityservice:endCommunityServiceCommand', tonumber(args[1]))
--		else
--			TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id')  } } )
--		end
--	else
--		TriggerEvent('esx_communityservice:endCommunityServiceCommand', source)
--	end
--end, function(source, args, user)
--	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
--end, {help = _U('unjail_people'), params = {{name = "id", help = _U('target_id')}}})
RegisterServerEvent("qb-clothes:loadPlayerSkinjerico") --DO NOT CHANGE THIS
AddEventHandler('qb-clothes:loadPlayerSkinjerico', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:execute("SELECT * FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            TriggerClientEvent("qb-clothes:loadSkin", src, false, result[1].model, result[1].skin) --CHANGE THIS
        else
            TriggerClientEvent("qb-clothes:loadSkin", src, true) ---CHANGE THIS
        end
    end)
end)




RegisterServerEvent('esx_communityservice:endCommunityServiceCommand')
AddEventHandler('esx_communityservice:endCommunityServiceCommand', function(source)
	if source ~= nil then
		TriggerEvent("qb-clothes:loadPlayerSkinjerico",source) --DO NOT TOUCH THIS
		releaseFromCommunityService(source)

	end
end)

-- unjail after time served
RegisterServerEvent('esx_communityservice:finishCommunityService')
AddEventHandler('esx_communityservice:finishCommunityService', function()
	releaseFromCommunityService(source)
end)





RegisterServerEvent('esx_communityservice:completeService')
AddEventHandler('esx_communityservice:completeService', function()

	local _source = source
	local identifier = QBCore.Functions.GetPlayer(_source).PlayerData.license
	--print(identifier)

	exports.oxmysql:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			exports.oxmysql:execute('UPDATE communityservice SET actions_remaining = actions_remaining - 1 WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})
		else
			--print ("ESX_CommunityService :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)




RegisterServerEvent('esx_communityservice:extendService')
AddEventHandler('esx_communityservice:extendService', function()

	local _source = source
	local identifier = QBCore.Functions.GetPlayer(_source).PlayerData.license

	exports.oxmysql:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			exports.oxmysql:execute('UPDATE communityservice SET actions_remaining = actions_remaining + @extension_value WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@extension_value'] = Config.ServiceExtensionOnEscape
			})
		else
			--print ("ESX_CommunityService :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)






RegisterServerEvent('esx_communityservice:sendToCommunityService')
AddEventHandler('esx_communityservice:sendToCommunityService', function(target, actions_count)
--print("llego")
	local identifier = QBCore.Functions.GetPlayer(target).PlayerData.license
	--print("llego1")
	exports.oxmysql:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			exports.oxmysql:execute('UPDATE communityservice SET actions_remaining = @actions_remaining WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		else
			exports.oxmysql:execute('INSERT INTO communityservice (identifier, actions_remaining) VALUES (@identifier, @actions_remaining)', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		end
	end)
	--print("llego2")
	--TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_msg', QBCore.Functions.GetPlayer(target).PlayerData.license, actions_count) }, color = { 147, 196, 109 } })
	--TriggerClientEvent('esx_policejob:unrestrain', target)
	TriggerClientEvent('esx_communityservice:inCommunityService', target, actions_count)
end)


















RegisterServerEvent('esx_communityservice:checkIfSentenced')
AddEventHandler('esx_communityservice:checkIfSentenced', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local identifier = QBCore.Functions.GetPlayer(_source).PlayerData.license -- get steam identifier

	exports.oxmysql:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] ~= nil and result[1].actions_remaining > 0 then
			--TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('jailed_msg', GetPlayerName(_source), ESX.Math.Round(result[1].jail_time / 60)) }, color = { 147, 196, 109 } })
			TriggerClientEvent('esx_communityservice:inCommunityService', _source, tonumber(result[1].actions_remaining))
		end
	end)
end)







function releaseFromCommunityService(target)

	local identifier = QBCore.Functions.GetPlayer(target).PlayerData.license
	exports.oxmysql:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			exports.oxmysql:execute('DELETE from communityservice WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})

			--TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_finished', GetPlayerName(target)) }, color = { 147, 196, 109 } })
		end
	end)

	TriggerClientEvent('esx_communityservice:finishCommunityService', target)
end
