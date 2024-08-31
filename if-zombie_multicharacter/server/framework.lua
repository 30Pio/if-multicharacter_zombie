--#region Variables

local selectedFramework = Config.Framework:upper()
SVFramework = {}

--#endregion Variables

--#region ESX

local function loadESXFramework()
    --#region Variables

    local ESX = exports['es_extended']:getSharedObject()
    local CHAR_PREFIX <const> = 'char'
    local framework = {}
    framework.ESX = true

    --#endregion variables

    --#region Functions

    framework.CreateServerCallback = ESX.RegisterServerCallback
    framework.GetPlayerIdentifier = ESX.GetIdentifier
    framework.LoadCharacter = function(character)
        local _source = source
        local pIdentifier = ESX.GetIdentifier(_source)
        if not ESX.GetConfig().EnableDebug then
            local identifier = CHAR_PREFIX .. character.id + 1 .. ":" .. pIdentifier(source)
            if ESX.GetPlayerFromIdentifier(identifier) then
                DropPlayer(source, "Your identifier " .. identifier .. " is already on the server!")
                return
            end
        end

        TriggerEvent("esx:onPlayerJoined", _source, ("%s%s"):format(CHAR_PREFIX, character.id + 1))
        ESX.Players[pIdentifier] = true
    end
    framework.CreateCharacter = function(character)
        local _source = source
        TriggerEvent("esx:onPlayerJoined", _source, ("%s%s"):format(CHAR_PREFIX, character.id + 1), character.identity)
        ESX.Players[ESX.GetIdentifier(_source)] = true
    end
    framework.DeleteCharacter = function(source, identifier)
        local _source = source

        MySQL.update('DELETE FROM `users` WHERE `identifier` = ?', { identifier }, function(affectedRows)
            if affectedRows then
                print(("[^2INFO^7] Player ^5%s %s^7 has deleted a character ^5(%s)^7"):format(GetPlayerName(source),
                    source, identifier))
                TriggerClientEvent('esx:showNotification', _source, Locale("notifications.char_deleted"), "success")
                return true
            end

            error("\n^1Transaction failed while trying to delete " .. identifier .. "^0")
        end)
    end
    framework.ConvertMultiCharPlayerToDbData = function(playerData)
        local data = {
            id = playerData.id,
            identity = {
                firstname = playerData.identity.firstName,
                lastname = playerData.identity.lastName,
                dateofbirth = playerData.identity.birthDate,
                sex = playerData.identity.gender == Locale('ui.male') and 'm' or 'f',
                height = playerData.identity.height
            }
        }

        return data
    end
    local function ScrapeJob(job_name, job_grade)
        local job, grade = job_name or "unemployed", tostring(job_grade)

        if ESX.DoesJobExist(job, grade) then
            grade = job ~= "unemployed" and ESX.Jobs[job].grades[grade]?.label or ""
            job = ESX.Jobs[job].label
        else
            job = ESX.Jobs["unemployed"]?.label
            grade = "Freelancer"
        end

        return {
            name = job_name,
            label = job,
            grade = grade
        }
    end
    framework.ConvertDbPlayerToMultiData = function(playerData)
        local data = {
            identifier = playerData.identifier,
            accounts = json.decode(playerData.accounts),
            identity = {
                firstName = playerData.firstname,
                lastName = playerData.lastname,
                dateOfBirth = playerData.dateofbirth,
                gender = playerData.sex == "m" and Locale("ui.male") or Locale("ui.female"),
                nationality = (playerData.metadata and json.decode(playerData.metadata)?.nationality or "") or ""
            },
            job = ScrapeJob(playerData.job, playerData.grade)
        }

        return data
    end
    framework.LogoutPlayer = function(source)
        local _source = source
        TriggerEvent("esx:playerLogout", _source)
    end

    --#endregion Functions

    --#region Compartibility Events

    AddEventHandler("playerDropped", function()
        local _source = source
        ESX.Players[ESX.GetIdentifier(_source)] = nil
    end)

    --#endregion Compartibility Events

    return framework
end

--#endregion ESX

--#region QBCore

local function loadQBCoreFramework()
    --#region Variables

    local QBCore = exports['qb-core']:GetCoreObject()
    local SKIP_SPAWN_SELECTION = false -- SET TO TRUE IF YOU WANT TO SKIP THE SPAWN SELECTION WHEN CHAR IS SELECTED
    local hasDonePreloading = {}
    local framework = {}
    framework.QB = true

    --#endregion Variables

    --#region Functions

    local function loadHouseData(src)
        local HouseGarages = {}
        local Houses = {}
        local result = MySQL.query.await('SELECT * FROM houselocations', {})
        if result[1] then
            for _, v in pairs(result) do
                local owned = false
                if tonumber(v.owned) == 1 then
                    owned = true
                end
                local garage = v.garage and json.decode(v.garage) or {}
                Houses[v.name] = {
                    coords = json.decode(v.coords),
                    owned = owned,
                    price = v.price,
                    locked = true,
                    adress =
                        v.label,
                    tier = v.tier,
                    garage = garage,
                    decorations = {},
                }
                HouseGarages[v.name] = { label = v.label, takeVehicle = garage, }
            end
        end
        TriggerClientEvent("qb-garages:client:houseGarageConfig", src, HouseGarages)
        TriggerClientEvent("qb-houses:client:setHouseConfig", src, Houses)
    end

    framework.CreateServerCallback = QBCore.Functions.CreateCallback
    framework.GetPlayerIdentifier = QBCore.Functions.GetIdentifier
    framework.LoadCharacter = function(character)
        local _source = source
        if QBCore.Player.Login(_source, character.identifier) then
            repeat
                Wait(10)
            until hasDonePreloading[_source]
            print('^2[qb-core]^7 ' ..
                GetPlayerName(_source) .. ' (Citizen ID: ' .. character.identifier .. ') has successfully loaded!')
            QBCore.Commands.Refresh(_source)
            loadHouseData(_source)
            if SKIP_SPAWN_SELECTION then
                local coords = json.decode(character.position)
                TriggerClientEvent('qb-multicharacter:client:spawnLastLocation', _source, coords, character)
            else
                if GetResourceState('qb-apartments'):find('start') then
                    TriggerClientEvent('apartments:client:setupSpawnUI', _source, character)
                else
                    TriggerClientEvent('qb-spawn:client:setupSpawns', _source, character, false, nil)
                    TriggerClientEvent('qb-spawn:client:openUI', _source, true)
                end
            end
            TriggerEvent("qb-log:server:CreateLog", "joinleave", "Loaded", "green",
                "**" ..
                GetPlayerName(_source) ..
                "** (<@" ..
                (QBCore.Functions.GetIdentifier(_source, 'discord'):gsub("discord:", "") or "unknown") ..
                "> |  ||" ..
                (QBCore.Functions.GetIdentifier(_source, 'ip') or 'undefined') ..
                "|| | " ..
                (QBCore.Functions.GetIdentifier(_source, 'license') or 'undefined') ..
                " | " .. character.identifier .. " | " .. _source .. ") loaded..")
        end
    end
    framework.CreateCharacter = function(character)
        local _source = source
        local newData = character
        if QBCore.Player.Login(_source, false, newData) then
            repeat
                Wait(10)
            until hasDonePreloading[_source]
            if GetResourceState('qb-apartments'):find('start') and Apartments?.Starting then
                local randbucket = (GetPlayerPed(_source) .. math.random(1, 999))
                SetPlayerRoutingBucket(_source, randbucket)
                print('^2[qb-core]^7 ' .. GetPlayerName(_source) .. ' has successfully loaded!')
                QBCore.Commands.Refresh(_source)
                loadHouseData(_source)
                TriggerClientEvent("if-zombie_multicharacter:client:handleMulticharacterUi", _source, false)
                TriggerClientEvent('apartments:client:setupSpawnUI', _source, newData)
                -- You can add here some function/event to add player default items, if you're not doing that on the core
            else
                print('^2[qb-core]^7 ' .. GetPlayerName(_source) .. ' has successfully loaded!')
                QBCore.Commands.Refresh(_source)
                loadHouseData(_source)
                TriggerClientEvent("qb-multicharacter:client:closeNUIdefault", _source)
                -- You can add here some function/event to add player default items, if you're not doing that on the core
                TriggerEvent('apartments:client:SetHomeBlip', nil)
            end
        end
    end
    framework.DeleteCharacter = function(source, identifier)
        local _source = source
        QBCore.Player.DeleteCharacter(_source, identifier)
        TriggerClientEvent('QBCore:Notify', _source, Locale("notifications.char_deleted"), "success")
    end
    framework.ConvertMultiCharPlayerToDbData = function(playerData)
        local data = {
            cid = playerData.id,
            charinfo = {
                firstname = playerData.identity.firstName,
                lastname = playerData.identity.lastName,
                birthdate = playerData.identity.birthDate,
                gender = playerData.identity.gender == Locale('ui.male') and 0 or 1,
                nationality = playerData.identity.nationality,
                height = playerData.identity.height
            }
        }

        return data
    end
    framework.ConvertDbPlayerToMultiData = function(playerData)
        local job = json.decode(playerData.job)
        local charinfo = json.decode(playerData.charinfo)
        local data = {
            identifier = playerData.citizenid,
            accounts = json.decode(playerData.money),
            identity = {
                firstName = charinfo.firstname,
                lastName = charinfo.lastname,
                dateOfBirth = charinfo.birthdate,
                gender = tonumber(charinfo.gender) == 0 and Locale("ui.male") or Locale("ui.female"),
                nationality = charinfo.nationality,
                height = charinfo.height
            },
            job = {
                label = job.label,
                grade = job.grade.name
            }
        }

        return data
    end
    framework.LogoutPlayer = function(source)
        local _source = source
        QBCore.Player.Logout(_source)
    end

    --#endregion Functions

    --#region Events

    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        Wait(1000) -- 1 second should be enough to do the preloading in other resources
        hasDonePreloading[Player.PlayerData.source] = true
    end)
    AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
        hasDonePreloading[src] = false
    end)

    --#endregion Events

    return framework
end

--#endregion QBCore

--#region Loader

if selectedFramework == 'ESX' then
    SVFramework = loadESXFramework()
elseif selectedFramework == 'QB' or selectedFramework == 'QBCORE' then
    SVFramework = loadQBCoreFramework()
else
    print('Invalid framework selected. Pls, check "Config.lua"')
    return
end

--#endregion Loader
