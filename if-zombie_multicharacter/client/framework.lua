--#region Variables

local selectedFramework = Config.Framework:upper()
CLFramework = {}

--#endregion Variables

--#region ESX

local function loadESXFramework()
    --#region Variables

    local ESX = exports['es_extended']:getSharedObject()
    local framework = {}
    framework.ESX = true
    framework.DefaultSkin = Config.DefaultESXSkin
    framework.IsPlayerLoggedIn = ESX.PlayerLoaded

    --#endregion Variables

    --#region Functions

    framework.TriggerServerCallback = ESX.TriggerServerCallback
    framework.ResetClientVars = function()
        ESX.PlayerLoaded = false
        ESX.PlayerData = {}
    end
    framework.LoadSkin = function(skin)
        TriggerEvent("skinchanger:loadSkin", skin)
    end
    framework.GetPlayerData = ESX.GetPlayerData

    --#endregion Functions

    return framework
end

--#endregion ESX

--#region QBCore

local function loadQBCoreFramework()
    --#region Variables

    local QBCore = exports['qb-core']:GetCoreObject()
    local framework = {}
    framework.QB = true
    framework.DefaultSkin = Config.DefaultQBSkin
    framework.IsPlayerLoggedIn = LocalPlayer.state.isLoggedIn

    --#endregion Variables

    --#region Functions

    framework.TriggerServerCallback = QBCore.Functions.TriggerCallback
    framework.ResetClientVars = function()
        QBCore.PlayerData = {}
    end
    framework.LoadSkin = function(data)
        TriggerEvent('qb-clothing:client:loadPlayerClothing', data, PlayerPedId())
    end
    framework.GetPlayerData = QBCore.Functions.GetPlayerData

    --#endregion Functions

    return framework
end

--#endregion QBCore

--#region Loader

do
    if selectedFramework == 'ESX' then
        CLFramework = loadESXFramework()
    elseif selectedFramework == 'QB' or selectedFramework == 'QBCORE' then
        CLFramework = loadQBCoreFramework()
    else
        print('Invalid framework selected. Pls, check "Config.lua"')
        return
    end
end

--#endregion Loader
