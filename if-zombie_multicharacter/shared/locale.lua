--#region Variables

---@type { [string]: string | table }
local dict = {}

local GetCurrentResourceName = GetCurrentResourceName
local LoadResourceFile = LoadResourceFile
local pairs = pairs
local type = type

--#endregion Variables

--#region Functions

local function deepTranslate(dict, path)
    local value = dict
    for part in path:gmatch("[^%.]+") do
        value = value[part]
        if not value then
            return nil
        end
    end
    return value
end

---@param str string
---@param ... string | number
---@return string
function Locale(str, ...)
    local lstr = deepTranslate(dict, str)

    if lstr and type(lstr) == 'string' then
        if ... then
            return lstr:format(...)
        end
        return lstr
    end

    return str
end

function GetLocales()
    return dict
end

local function mergeTables(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k] or false) == "table" then
            mergeTables(t1[k], v)
        else
            t1[k] = v
        end
    end
end

local function loadLocale()
    local lang = Config.Locale
    local currentResourceName = GetCurrentResourceName()
    local locales = json.decode(LoadResourceFile(currentResourceName, ('locales/%s.json'):format(lang)))

    if not locales then
        local warning = "couldn't load 'locales/%s.json'"
        print('^1ERROR:^7', warning:format(lang))

        if lang ~= 'en' then
            locales = json.decode(LoadResourceFile(currentResourceName, 'locales/en.json'))

            if not locales then
                print('^1ERROR:^7', warning:format('en'))
            end
        end

        if not locales then return end
    end

    mergeTables(dict, locales)
end

--#endregion Functions

--#region Loader

do
    loadLocale()
end

--#endregion Loader

-- Credits: overextended & ZentriX Shop
