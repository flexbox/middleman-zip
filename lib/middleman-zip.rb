require 'middleman-core'
require 'middleman-zip/version'
require 'middleman-zip/extension'

Middleman::Extensions.register(:zip, Middleman::Zip::ZipExtension)
