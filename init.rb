# Include hook code here

require 'sads_xml'

Mime::Type.register_alias "application/xml", :sads

ActionController::Base.class_eval do
  include SadsXml
end
