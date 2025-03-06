fx_version "cerulean"
game "gta5"
lua54 "yes"

name 'n-grower'
author "TheNeti"
version "1.0"

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client/client.lua'

server_script 'server/server.lua'
