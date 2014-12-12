require 'middleman-core'
require 'middleman-zip/version'

::Middleman::Extensions.register(:middleman_zip) do
  require 'middleman-zip/extension'
  Middleman::Zip::ZipExtension
end
