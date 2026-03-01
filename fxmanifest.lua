fx_version 'cerulean'
games { 'gta5', 'rdr3' }
lua54 'yes'

name 'Prism'
author 'aquapha, forked by mysbryce'
version '1.2.0'
description 'A validation builder for lua'

shared_scripts {
  'lib/validator/utils/*.lua',

  'lib/validator/enums.lua',
  'lib/generator.lua',
  'lib/validator/parsers/*.lua',
  'lib/validator/parser.lua',

  'lib/validator/methods/primitive-methods.lua',
  'lib/validator/methods/table-methods.lua',

  'lib/validator/primitive-builders.lua',

  'init.lua'
}

provide 'lua-vBuilder-fivem'