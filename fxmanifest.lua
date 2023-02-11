fx_version "cerulean"
game "gta5"

description "Drugs labs for ESX"
author "LxrsV1"
version "1.0.0"

client_scripts {"config/**/*.lua", "client/**/*.lua"}
server_scripts {"@oxmysql/lib/MySQL.lua", "config/**/*.lua", "server/main.lua", "server/**/*.lua"} -- Loading main first, had issues with loading ESX