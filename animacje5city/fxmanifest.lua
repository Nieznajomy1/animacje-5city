
fx_version "bodacious"
games {"gta5"}
client_scripts {
	'@es_extended/locale.lua',
	'client.lua',
	'config.lua',
	'Gesty/handsup.lua',
	'Gesty/pointing.lua',
	'Gesty/weapon.lua',
}

server_scripts {
    '@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'server.lua'
}

exports {
	'getCarry',
	'OpenAnimationsMenu'
}