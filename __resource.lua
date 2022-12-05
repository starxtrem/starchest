author 'Starxtrem'
description 'Starchest dev By starxtrem'
version '2.3'

client_scripts {
    '@es_extended/locale.lua',
    "client/*.lua",
	'locales/*.lua',
    'config.lua',
}

server_scripts {
    '@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
    "server/*.lua",
	'locales/*.lua',
    'config.lua',
}

dependencies {
	'es_extended',
}
-- Devlopped By Starxtrem --
