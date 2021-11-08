# ESX_CommunityService
community service converted from esx to qbus framework 

# todo: 
-copy the ESX_CommunityService to your resource 
-add these lines to qb-policejob/server/main.lua

-- Addition
QBCore.Commands.Add("communityserv", "Grant community service", {{name = "id", help = "ID of a person"}, {name = "count", help = "Count of service"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
            TriggerEvent('esx_communityservice:sendToCommunityService', tonumber(args[1]), tonumber(args[2]))
        else
            TriggerClientEvent('QBCore:Notify', src, "Invalid id or action", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You must be a Police!", "error")
    end
end)

--addition 2
QBCore.Commands.Add("endcommserv", "cancel community service", {{name = "id", help = "ID of a person"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        if args[1] then
            if args[1] ~= nil then
                TriggerEvent('esx_communityservice:endCommunityServiceCommand', tonumber(args[1]))
            else
                TriggerClientEvent('QBCore:Notify', src, "Invalid id or action", "error")
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You must be a Police!", "error")
    end
end)
--step 3
start resource 
good to go



# usage: 
/comserv id time (to give community service as admin)
/endcomserv id ( to end community service as admin)
/communityserv id time (as police)
/endcommserv id (as police to end community service)
