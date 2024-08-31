fx_version 'cerulean'
game 'gta5'

author 'IF Developments'
description 'Zombie Multicharacter - Free'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua',
    'shared/*.lua'
}
client_scripts {
    'client/*.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    -- '@qb-apartments/config.lua', -- Uncomment if you're using qb-apartments
    'server/framework.lua',
    'server/db.lua',
    'server/main.lua'
}

ui_page 'nui/index.html'
files {
    'locales/*.json',
    'nui/*',
    'nui/**/*',
    'nui/**/**/*'
}

provides {
    'esx_multicharacter',
    'qb-multicharacter',
    'esx_identity'
}

escrow_ignore {
    'config.lua'
}
