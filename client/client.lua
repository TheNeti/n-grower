ESX = exports['es_extended']:getSharedObject()

local usedTargets = {}
local clothing = false
local duty = false

local function collect(targetCoords)
    if not usedTargets[targetCoords] then
        usedTargets[targetCoords] = { uses = math.random(1, 3), onCooldown = false }
    end

    local targetData = usedTargets[targetCoords]

    if targetData.onCooldown then
        ESX.ShowNotification('Brak pomarańczy na drzewie')
        return
    end

    if targetData.uses > 0 then
        if lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true
            },
            anim = {
                dict = 'amb@prop_human_movie_bulb@idle_a',
                clip = 'idle_b'
            },
        }) then

            TriggerServerEvent('n-grower:giveItem', targetCoords)
            targetData.uses = targetData.uses - 1

            if targetData.uses <= 0 then
                targetData.onCooldown = true
                ESX.ShowNotification('Zebrałeś wszystkie pomarańcze!')

                SetTimeout(Config.Settings.colldown * 1000 * 60, function()
                    targetData.uses = math.random(1, 3)
                    targetData.onCooldown = false
                end)
            end
        end
    end
end

local function clothes()
    if lib.progressCircle({
        duration = 2000,
        label = 'Przebieranie',
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = false,
            combat = true
        },
        anim = {
            dict = 'clothingtie',
            clip = 'try_tie_negative_a'
        },
    }) then 
        if not clothing then
            clothing = true
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                if skin.sex == 0 then
                    TriggerEvent('skinchanger:loadClothes', skin, Config.SkinMale)
                else
                    TriggerEvent('skinchanger:loadClothes', skin, Config.SkinFemale)
                end
            end)
        elseif clothing then
            clothing = false
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
            end)
        end
    end
end

CreateThread(function()
    local blip = AddBlipForCoord(Config.Settings.coords.x, Config.Settings.coords.y, Config.Settings.coords.z)
    SetBlipSprite(blip, 85)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 17)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Sad")
    EndTextCommandSetBlipName(blip)

    RequestModel('a_m_m_farmer_01')
    while not HasModelLoaded('a_m_m_farmer_01') or not HasCollisionForModelLoaded('a_m_m_farmer_01') do
        Wait(1)
    end

    planterman = CreatePed(28, 'a_m_m_farmer_01', Config.Settings.coords.x, Config.Settings.coords.y, Config.Settings.coords.z-1, Config.Settings.rotation, false, true)
    SetEntityAsMissionEntity(planterman, true, true)
    SetEntityInvincible(planterman, true)
    SetBlockingOfNonTemporaryEvents(planterman, true)
    FreezeEntityPosition(planterman, true)


    exports.ox_target:addBoxZone({
        coords = Config.Settings.coords,
        size = Config.Settings.size,
        rotation = Config.Settings.rotation,
        debug = false,
        drawSprite = true,
        options = {
            {
                name = 'dutyon',
                onSelect = function()
                    duty = true
                end,
                icon = 'fa-solid fa-id-card-clip',
                label = 'Rozpocznij Prace',
                canInteract = function()
                    return not duty and not clothing
                end,
                distance = 2
            },
            {
                name = 'dutyoff',
                onSelect = function()
                    duty = false
                end,
                icon = 'fa-solid fa-id-card-clip',
                label = 'Zakończ Prace',
                canInteract = function()
                    return duty and not clothing
                end,
                distance = 2
            },
            {
                name = 'clothes',
                onSelect = function()
                    clothes()
                end,
                icon = 'fa-solid fa-shirt',
                label = 'Przebierz się',
                canInteract = function()
                    return duty
                end,
                distance = 2
            },
            {
                name = 'sell',
                onSelect = function()
                    TriggerServerEvent('n-grower:sellItem')
                end,
                icon = 'fa-solid fa-sack-dollar',
                label = 'Sprzedaj Pomarańcze',
                canInteract = function()
                    return duty and clothing
                end,
                distance = 2
            }
        }
    })

    for k, coords in pairs(Config.OrangeLocations) do
        usedTargets[coords] = { uses = math.random(1, 3), onCooldown = false }

        exports.ox_target:addSphereZone({
            coords = vec3(coords.x, coords.y, coords.z),
            radius = 2.2,
            debug = false,
            drawSprite = true,
            options = {
                {
                    name = 'Orange',
                    onSelect = function()
                        collect(coords)
                    end,
                    canInteract = function()
                        return duty and clothing
                    end,
                    icon = 'fa-solid fa-hands-bubbles',
                    label = 'Zbierz Pomarańcze',
                    distance = 2
                }
            }
        })
    end
end)