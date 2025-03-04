ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('n-grower:giveItem')
AddEventHandler('n-grower:giveItem', function(targetCoords)
    local src = source
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local maxDistance = 5.0
    local validTree = false

    for _, treeCoords in ipairs(Config.OrangeLocations) do
        if #(vector3(targetCoords.x, targetCoords.y, targetCoords.z) - treeCoords) < 0.5 then
            validTree = true
            break
        end
    end

    if not validTree then
        DropPlayer(src, "Wykryto oszustwo: Nieprawidłowe współrzędne drzewa")
        return
    end

    if #(playerCoords - vector3(targetCoords.x, targetCoords.y, targetCoords.z)) > maxDistance then
        DropPlayer(src, "Wykryto oszustwo: Zbyt duża odległość od drzewa")
        return
    end

    local amount = math.random(1, 5)
    if exports.ox_inventory:CanCarryItem(src, Config.Settings.item, amount) then
        exports.ox_inventory:AddItem(src, Config.Settings.item, amount)
    else
        TriggerClientEvent('esx:showNotification', src, 'Brak miejsca w ekwipunku')
    end
end)

RegisterServerEvent('n-grower:sellItem')
AddEventHandler('n-grower:sellItem', function()
    local src = source

    local count = exports.ox_inventory:GetItemCount(src, Config.Settings.item)
    print(count)
    if count > 0 then
        local totalMoney = count * Config.Settings.price
        if exports.ox_inventory:RemoveItem(src, Config.Settings.item, count) then
        exports.ox_inventory:AddItem(src, 'money', totalMoney)
        print(('Gracz %s sprzedał %d %s za %d$'):format(GetPlayerName(src), count, Config.Settings.item, totalMoney))
        end
    end
end)
