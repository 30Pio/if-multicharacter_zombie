--#region Variables

local SPAWN_COORDS <const> = Config.SelectionSpawn ---@type vector4
local RANDOM_PED_MODELS <const> = { -- possible models to load when choosing an empty slot
    'mp_m_freemode_01',
    'mp_f_freemode_01',
}

local canPlayerRelog = true ---@type boolean
local currentCamera = -1 ---@type integer
local hidingPlayers = false ---@type boolean

CurrentCharacterPed = -1 ---@type integer

--#endregion Variables

--#region Threads

CreateThread(function()
    while not CLFramework.IsPlayerLoggedIn do
        Wait(100)
        if NetworkIsSessionStarted() then
            exports.spawnmanager:setAutoSpawn(false)
            DoScreenFadeOut(0)
            TriggerEvent('if-zombie_multicharacter:client:handleMulticharacterUi', true)
            break
        end
    end
end)

--#endregion Threads

--#region Functions

local function startMainLoop()
    if hidingPlayers then return end
    hidingPlayers = true
    MumbleSetVolumeOverride(PlayerId(), 0.0)
    CreateThread(function()
        local keys = { 18, 27, 172, 173, 174, 175, 176, 177, 187, 188, 191, 201, 108, 109, 209, 19 }
        while hidingPlayers do
            DisableAllControlActions(0)
            for i = 1, #keys do
                EnableControlAction(0, keys[i], true)
            end
            SetEntityVisible(PlayerPedId(), false, false)
            SetLocalPlayerVisibleLocally(true)
            SetPlayerInvincible(PlayerId(), true)
            ThefeedHideThisFrame()
            HideHudComponentThisFrame(11)
            HideHudComponentThisFrame(12)
            HideHudComponentThisFrame(21)
            HideHudAndRadarThisFrame()
            Wait(0)
            local vehicles = GetGamePool("CVehicle")
            for i = 1, #vehicles do
                SetEntityLocallyInvisible(vehicles[i])
            end
        end
        local playerId, playerPed = PlayerId(), PlayerPedId()
        MumbleSetVolumeOverride(playerId, -1.0)
        SetEntityVisible(playerPed, true, false)
        SetPlayerInvincible(playerId, false)
        FreezeEntityPosition(playerPed, false)
        Wait(10000)
        canPlayerRelog = true
    end)
    CreateThread(function()
        local playerPool = {}
        while hidingPlayers do
            local players = GetActivePlayers()
            for i = 1, #players do
                local player = players[i]
                if player ~= PlayerId() and not playerPool[player] then
                    playerPool[player] = true
                    NetworkConcealPlayer(player, true, true)
                end
            end
            Wait(500)
        end
        for k in pairs(playerPool) do
            NetworkConcealPlayer(k, false, false)
        end
    end)
end

---@param model string | integer
local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

---@param enable boolean
local function toggleWeather(enable)
    if GetResourceState('qb-weathersync'):find('start') then
        if enable then
            TriggerEvent('qb-weathersync:client:EnableSync')
        else
            TriggerEvent('qb-weathersync:client:DisableSync')
        end
    elseif GetResourceState('cd_easytime'):find('start') then
        TriggerEvent('cd_easytime:PauseSync', enable)
    elseif GetResourceState('vSync'):find('start') then
        TriggerEvent('vSync:toggle', enable)
        Wait(100)
        if enable then
            TriggerServerEvent('vSync:requestSync')
        else
            TriggerEvent('vSync:updateWeather', 'CLEAR', enable)
        end
    end
end

---@param model? string | integer
---@param skin? table
function InitializePedModel(model, skin)
    if not model and not skin then
        exports.spawnmanager:spawnPlayer({
            x = SPAWN_COORDS.x,
            y = SPAWN_COORDS.y,
            z = SPAWN_COORDS.z,
            heading = SPAWN_COORDS.w,
            model = model or joaat(RANDOM_PED_MODELS[math.random(#RANDOM_PED_MODELS)]),
            skipFade = true,
        }, function()
            canPlayerRelog = false
            if skin or CLFramework.DefaultSkin then
                local gender = model == `mp_m_freemode_01` and 0 or 1 ---@type integer | string
                CLFramework.LoadSkin(skin or CLFramework.DefaultSkin[gender])
            else
                SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
            end
        end)
    elseif model or skin then
        if model and GetEntityModel(PlayerPedId()) ~= model then
            loadModel(model)
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
        end
        if skin then
            CLFramework.LoadSkin(skin)
        elseif CLFramework.DefaultSkin then
            local gender = model == `mp_m_freemode_01` and 0 or 1 ---@type integer | string
            skin = CLFramework.DefaultSkin[gender]
            skin.model = model
            CLFramework.LoadSkin(skin)
        else
            SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
        end
    end
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    SetPedAoBlobRendering(playerPed, true)
    SetEntityAlpha(playerPed, 255, true)
    ResetEntityAlpha(playerPed)
end

---@param bool boolean
local function handleCamera(bool)
    toggleWeather(bool)
    local playerPed = PlayerPedId()
    if bool then
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)

        SetEntityCoords(playerPed, SPAWN_COORDS.x, SPAWN_COORDS.y, SPAWN_COORDS.z, true, false, false, false)
        SetEntityHeading(playerPed, SPAWN_COORDS.w)

        local camOffset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.7, 0.4)
        currentCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(currentCamera, true)
        RenderScriptCams(true, false, 1, true, true)
        SetCamCoord(currentCamera, camOffset.x, camOffset.y, camOffset.z)
        PointCamAtCoord(currentCamera, Config.SelectionSpawn.x, Config.SelectionSpawn.y, Config.SelectionSpawn.z + 1.3)
    else
        SetTimecycleModifier('default')
        SetCamActive(currentCamera, false)
        DestroyCam(currentCamera, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(playerPed, false)
    end
end

--- Close/open the Multicharacter UI
---@param bool boolean
local function handleMulticharacterUi(bool)
    if bool then
        CLFramework.TriggerServerCallback("if-zombie_multicharacter:server:getNumberOfSlots", function(result)
            local uiLocales = {}
            local locales = GetLocales()
            for k, v in pairs(locales) do
                if k == 'ui' and type(v) == 'table' then
                    uiLocales = v
                    break
                end
            end

            startMainLoop()
            handleCamera(true)
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
            TriggerEvent("esx:loadingScreenOff")
            CLFramework.ResetClientVars()
            canPlayerRelog = false

            while not IsUiReady do Wait(500) end
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "ui",
                toggle = true,
                translations = uiLocales,
                characterSlots = result,
                enableDeleteButton = Config.CanDelete,
                showNationality = CLFramework.QB or false
            })
            InitializePedModel(nil, nil)
            DoScreenFadeIn(1000)
        end)
    else
        handleCamera(false)
        hidingPlayers = false
        CurrentCharacterPed = -1
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "ui",
            toggle = false
        })
    end
end

--#endregion Functions

--#region Events

RegisterNetEvent('if-zombie_multicharacter:client:handleMulticharacterUi', handleMulticharacterUi)

--#region ESX Compatibility Events
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData, isNew, skin)
    local spawn = playerData.coords or Config.SelectionSpawn
    if isNew or not skin or #skin == 1 then
        local finished = false
        skin = Config.DefaultESXSkin[playerData.sex == 'm' and 0 or 1]
        skin.sex = playerData.sex == "m" and 0 or 1
        local model = skin.sex == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`
        skin.model = model
        loadModel(model)
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        TriggerEvent("skinchanger:loadSkin", skin, function()
            local playerPed = PlayerPedId()
            SetPedAoBlobRendering(playerPed, true)
            ResetEntityAlpha(playerPed)
            if IsScreenFadedOut() then DoScreenFadeIn(1000) end
            TriggerEvent("esx_skin:openSaveableMenu", function()
                finished = true
            end, function()
                finished = true
            end)
        end)
        repeat
            Wait(500)
        until finished
    end

    if not IsScreenFadedOut() then DoScreenFadeOut(750) end
    Wait(750)

    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    SetEntityCoordsNoOffset(playerPed, spawn.x, spawn.y, spawn.z, false, false, false)
    SetEntityHeading(playerPed, spawn.w)
    if not isNew then
        TriggerEvent("skinchanger:loadSkin", skin)
    end
    Wait(500)

    DoScreenFadeIn(750)
    Wait(750)

    repeat
        Wait(500)
    until not IsScreenFadedOut()
    TriggerServerEvent("esx:onPlayerSpawn")
    TriggerEvent("esx:onPlayerSpawn")
    TriggerEvent("playerSpawned")
    TriggerEvent("esx:restoreLoadout")

    FreezeEntityPosition(PlayerPedId(), false)
end)
RegisterNetEvent("esx:onPlayerLogout")
AddEventHandler("esx:onPlayerLogout", function()
    DoScreenFadeOut(500)
    Wait(1000)
    TriggerEvent("if-zombie_multicharacter:client:handleMulticharacterUi", true)
    TriggerEvent("esx_skin:resetFirstSpawn")
end)
--#endregion ESX Compatibility Events

--#region QB Compatiblity Events
RegisterNetEvent('qb-multicharacter:client:closeNUIdefault', function() -- This event is only for no starting apartments
    if not IsScreenFadedOut() then DoScreenFadeOut(500) end
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.QBDefaultSpawn.x, Config.QBDefaultSpawn.y, Config.QBDefaultSpawn.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    handleMulticharacterUi(false)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)
RegisterNetEvent('qb-multicharacter:client:spawnLastLocation', function(coords, cData)
    CLFramework.TriggerServerCallback('apartments:GetOwnedApartment', function(result)
        if result then
            TriggerEvent("apartments:client:SetHomeBlip", result.type)
            local ped = PlayerPedId()
            SetEntityCoords(ped, coords.x, coords.y, coords.z)
            SetEntityHeading(ped, coords.w)
            FreezeEntityPosition(ped, false)
            SetEntityVisible(ped, true, true)
            local PlayerData = CLFramework.GetPlayerData()
            local insideMeta = PlayerData.metadata["inside"]
            DoScreenFadeOut(500)

            if insideMeta.house then
                TriggerEvent('qb-houses:client:LastLocationHouse', insideMeta.house)
            elseif insideMeta.apartment.apartmentType and insideMeta.apartment.apartmentId then
                TriggerEvent('qb-apartments:client:LastLocationHouse', insideMeta.apartment.apartmentType,
                    insideMeta.apartment.apartmentId)
            else
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
                SetEntityHeading(ped, coords.w)
                FreezeEntityPosition(ped, false)
                SetEntityVisible(ped, true, true)
            end

            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            Wait(2000)
            DoScreenFadeIn(250)
        end
    end, cData.citizenid)
end)
--#endregion QB Compatiblity Events

--#endregion Events

--#region Commands

if Config.Relog.enabled and Config.Relog.command then
    RegisterCommand(Config.Relog.command, function()
        if canPlayerRelog then
            canPlayerRelog = false
            TriggerServerEvent("if-zombie_multicharacter:server:relog")
        end
    end, false)
end

--#endregion Commands
