Mime::Type.register_alias "application/xml", :sads

require 'sads_xml/sads'
require 'sads_xml/controller_additions'

module SadsXml
  class SadsXmlEngine < Rails::Engine
  end
end
