--#region Events

RegisterNetEvent('if-zombie_multicharacter:server:selectCharacter', SVFramework.LoadCharacter)
RegisterNetEvent('if-zombie_multicharacter:server:createCharacter', function(character)
    local frameworkCharacter = SVFramework.ConvertMultiCharPlayerToDbData(character)
    if not frameworkCharacter then return end

    SVFramework.CreateCharacter(frameworkCharacter)
end)
RegisterNetEvent('if-zombie_multicharacter:server:deleteCharacter', function(...)
    local _source = source
    if not Config.CanDelete then
        print(("[WARNING]: Player %s (%s) tried to delete a character when it's not allowed!"):format(
            GetPlayerName(_source), _source))
        DropPlayer(_source, '[MultiCharacter] Character Deletion exploiting.')
        -- You can add some additional logic here
    end

    SVFramework.DeleteCharacter(_source, ...)
end)

RegisterNetEvent('if-zombie_multicharacter:server:relog', function()
    local _source = source
    if not Config.Relog.enabled then
        print(("[WARNING]: Player %s (%s) tried to relog when it's not enabled!"):format(
            GetPlayerName(_source), _source))
        DropPlayer(_source, '[MultiCharacter] Relog exploiting.')
        -- You can add some additional logic here
    end

    SVFramework.LogoutPlayer(_source)
    Wait(500)
    TriggerClientEvent('if-zombie_multicharacter:client:handleMulticharacterUi', _source, true)
end)

--#endregion Events

--#region Callbacks

SVFramework.CreateServerCallback("if-zombie_multicharacter:server:getNumberOfSlots", function(source, cb)
    local _source = source
    local pLicense = SVFramework.GetPlayerIdentifier(_source, 'license')
    local numOfChars = Config.DefaultSlots

    if next(Config.PlayerSlots) then
        for _, v in pairs(Config.PlayerSlots) do
            if v.license == pLicense then
                numOfChars = v.numberOfChars
                break
            end
        end
    end
    cb(numOfChars)
end)

SVFramework.CreateServerCallback("if-zombie_multicharacter:server:getSkin", function(source, cb, identifier)
    local result = DB.GetCharSkin(identifier)
    if result then
        cb(SVFramework.ESX and json.decode(result.skin) or
            SVFramework.QB and { model = result.model, skin = json.decode(result.skin) })
    else
        cb(nil)
    end
end)

SVFramework.CreateServerCallback("if-zombie_multicharacter:server:setupCharacters", function(source, cb)
    local license = SVFramework.GetPlayerIdentifier(source, 'license')
    local plyChars = {}
    local result = DB.GetPlayerCharacters(SVFramework.ESX and ('%' .. license) or license)

    if result then
        for i = 1, (#result), 1 do
            local char = result[i]
            plyChars[#plyChars + 1] = SVFramework.ConvertDbPlayerToMultiData(char)
        end
    end
    cb(plyChars)
end)

--#endregion Callbacks
