require 'json'

module MiniCheck
  autoload :VERSION, 'mini_check/version'
  autoload :Check, 'mini_check/check'
  autoload :ChecksCollection, 'mini_check/checks_collection'
  autoload :RackApp, 'mini_check/rack_app'
  autoload :VersionRackApp, 'mini_check/version_rack_app'
end
