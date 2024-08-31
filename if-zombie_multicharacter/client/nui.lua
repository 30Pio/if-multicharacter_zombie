--#region Variables

IsUiReady = false ---@type boolean
local cached_player_skins = {}

--#endregion Variables

--#region NUI Callbacks

RegisterNUICallback('uiReady', function(data, cb)
    IsUiReady = true
    cb("ok")
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    local character = data.character
    DoScreenFadeOut(0)
    TriggerServerEvent('if-zombie_multicharacter:server:selectCharacter', character)
    TriggerEvent('if-zombie_multicharacter:client:handleMulticharacterUi', false)
    cb("ok")
end)

RegisterNUICallback('characterPed', function(data, cb)
    local character = data.character
    if character then
        if not cached_player_skins[character.identifier] then
            local temp_result = promise.new()

            CLFramework.TriggerServerCallback('if-zombie_multicharacter:server:getSkin', function(result)
                temp_result:resolve(result)
            end, character.identifier)

            local resolved_result = Citizen.Await(temp_result)
            cached_player_skins[character.identifier] = resolved_result
        end

        local model = cached_player_skins[character.identifier]?.model
        local skin = CLFramework.ESX and cached_player_skins[character.identifier] or
            CLFramework.QB and cached_player_skins[character.identifier].skin

        model = model and (tonumber(model) or joaat(model)) or nil

        if model then
            InitializePedModel(model, skin)
        else
            InitializePedModel()
        end
        cb("ok")
    else
        InitializePedModel(data.gender and data.gender == Locale('ui.male') and `mp_m_freemode_01` or `mp_f_freemode_01`)
        cb("ok")
    end
end)

RegisterNUICallback('setupCharacters', function(_, cb)
    CLFramework.TriggerServerCallback("if-zombie_multicharacter:server:setupCharacters", function(result)
        cached_player_skins = {}
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
        cb("ok")
    end)
end)

RegisterNUICallback('removeBlur', function(_, cb)
    SetTimecycleModifier('default')
    cb("ok")
end)

RegisterNUICallback('createNewCharacter', function(data, cb)
    local character = data
    DoScreenFadeOut(0)
    TriggerServerEvent('if-zombie_multicharacter:server:createCharacter', character)
    TriggerEvent('if-zombie_multicharacter:client:handleMulticharacterUi', false)
    cb("ok")
end)

RegisterNUICallback('removeCharacter', function(data, cb)
    if not Config.CanDelete then return end
    TriggerServerEvent('if-zombie_multicharacter:server:deleteCharacter', data.identifier)
    TriggerEvent('if-zombie_multicharacter:client:handleMulticharacterUi', true)
    cb("ok")
end)

--#endregion NUI Callbacks
