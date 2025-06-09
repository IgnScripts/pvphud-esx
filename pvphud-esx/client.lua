local isTalking = false
local lastTalkingState = false

CreateThread(function()
    if GetResourceState('pma-voice') == 'started' then
        activeVoiceSystem = 'pma-voice'
        exports('getTalkingState', function()
            return exports['pma-voice']:isPlayerTalking()
        end)
        print('Detected voice system: pma-voice')
    elseif GetResourceState('saltychat') == 'started' then
        activeVoiceSystem = 'saltychat'
        RegisterNetEvent('SaltyChat_IsTalking')
        AddEventHandler('SaltyChat_IsTalking', function(isTalking)
            SendNUIMessage({
                updateVoice = true,
                isTalking = isTalking
            })
        end)
        print('Detected voice system: saltychat')
    elseif GetResourceState('tokovoip_script') == 'started' then
        activeVoiceSystem = 'tokovoip'
        AddEventHandler('tokovoip:updateTokoVoip', function(data)
            local isTalking = data.talking or false
            SendNUIMessage({
                updateVoice = true,
                isTalking = isTalking
            })
        end)
        print('Detected voice system: tokovoip')
    else
        activeVoiceSystem = 'default'
        print('No specific voice system detected, using default NetworkIsPlayerTalking')
    end
end)

AddEventHandler('esx_status:onTick', function(data)
    local ped = PlayerPedId() 
    local health = GetEntityHealth(ped) - 100
    if health >= 99 then 
        health = 100
    elseif health < 1 then 
        health = 0
    end
    local armour = GetPedArmour(ped)
    if armour >= 99 then 
        armour = 100
    end
    isTalking = NetworkIsPlayerTalking(PlayerId())
    if IsPauseMenuActive(true) then 
        SendNUIMessage({
            showHud = false
        })
    elseif not IsPauseMenuActive(true) then
        SendNUIMessage({
            showHud = true,
            health = health,
            armor = armour,
            isTalking = isTalking
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local currentTalking = NetworkIsPlayerTalking(PlayerId())
        if currentTalking ~= lastTalkingState then
            lastTalkingState = currentTalking
            if not IsPauseMenuActive(true) then
                SendNUIMessage({
                    updateVoice = true,
                    isTalking = currentTalking
                })
            end
        end
    end
end)

