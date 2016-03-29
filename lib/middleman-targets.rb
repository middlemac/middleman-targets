################################################################################
# middleman-targets.rb
#  This file brings in the CLI additions and activates and registers this
#  extension in Middleman.
################################################################################

require 'middleman-core'
require_relative 'middleman-targets/commands'

Middleman::Extensions.register :MiddlemanTargets, :before_configuration do
  require_relative 'middleman-targets/extension'
  MiddlemanTargets
end
