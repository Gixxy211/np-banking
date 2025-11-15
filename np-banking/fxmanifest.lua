fx_version 'adamant'

game 'gta5'

description 'Gixxy - Banking Script | NP Inspired'

version '1.0.0'

ui_page 'UI/index.html'

files {
    'UI/index.html',
    'UI/styles/*.css',
    'UI/scripts/*.js',
    'UI/images/*.png',
	'UI/images/*.jpg',
    'UI/images/*.svg',
	'UI/fonts/*.ttf'
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'Config.lua'
}

client_script 'Client/*.lua'
server_script 'Server/*.lua'

lua54 'yes'