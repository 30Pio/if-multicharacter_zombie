MySQL = MySQL
DB = {}

local GET_PLAYER_CHARACTERS = "SELECT * FROM %s WHERE %s LIKE ?"
---Fetch the player enabled characters
function DB.GetPlayerCharacters(identifier)
    local QUERY_TABLE <const> = SVFramework.ESX and '`users`' or '`players`'
    local IDENTIFIER_COLUMN <const> = SVFramework.ESX and '`identifier`' or '`license`'
    return MySQL.query.await(GET_PLAYER_CHARACTERS:format(QUERY_TABLE, IDENTIFIER_COLUMN), { identifier })
end

local GET_CHAR_SKIN = "SELECT %s FROM %s WHERE %s = ? LIMIT 1"
---Fetch the character skin columns related
function DB.GetCharSkin(identifier)
    local QUERY_SELECTORS <const> = SVFramework.ESX and '`skin`' or '`model`, `skin`'
    local QUERY_TABLE <const> = SVFramework.ESX and '`users`' or '`playerskins`'
    local IDENTIFIER_COLUMN <const> = SVFramework.ESX and '`identifier`' or '`citizenid`'
    return MySQL.single.await(GET_CHAR_SKIN:format(QUERY_SELECTORS, QUERY_TABLE, IDENTIFIER_COLUMN), { identifier })
end
