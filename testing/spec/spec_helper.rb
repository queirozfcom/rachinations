require 'coveralls'
Coveralls.wear!

# so that i can require stuff as if these dirctories were in ruby's default PATH
#$: << File.expand_path(File.dirname(__FILE__))+"/../../domain"
#$: << File.expand_path(File.dirname(__FILE__))+"/../../dsl"

require 'rspec'

# RSpec.configure do |config|
#   config.color_enabled = true
#   config.default_path = 'testing/spec'
# end


# A few extra methods
# to make code read more intuitively.
class Proc

  alias_method :accepts?, :call
  alias_method :accept?, :call
  alias_method :match?, :call
  alias_method :matches?, :call
  alias_method :match_resource?, :call
  alias_method :matches_resource?, :call

end

require_relative '../../extras/fifo'


require_relative '../../domain/diagrams/diagram'
require_relative '../../domain/diagrams/verbose_diagram'
require_relative '../../dsl/dsl'
require_relative '../../domain/strategies/strategy'
require_relative '../../domain/strategies/valid_types'
require_relative '../../domain/edges/random_edge'
require_relative '../../domain/edges/edge'
require_relative '../../domain/exceptions/no_elements_of_given_type'
require_relative '../../domain/exceptions/unsupported_type_error'
require_relative '../../domain/exceptions/bad_options'
require_relative '../../domain/exceptions/no_elements_matching_condition_error'
require_relative '../../domain/exceptions/no_elements_found'
require_relative '../../domain/nodes/node'
require_relative '../../domain/nodes/resourceful_node'
require_relative '../../domain/nodes/pool'
require_relative '../../domain/nodes/source'
require_relative '../../domain/nodes/sink'
require_relative '../../domain/nodes/gate'
require_relative '../../domain/nodes/trader'
require_relative '../../domain/nodes/converter'
require_relative '../../domain/resources/token'
require_relative '../../domain/edge_collection'
require_relative '../../domain/node_collection'
require_relative '../../domain/resource_bag'


include DSL

#resource classes to be used in tests
Blue=Class.new(Token)
Black=Class.new(Token)
Green=Class.new(Token)
Red=Class.new(Token)
Yellow=Class.new(Token)


Football=Class.new(Token)
Baseball=Class.new(Token)
Basketball=Class.new(Token)

Mango=Class.new(Token)
Peach=Class.new(Token)
Banana=Class.new(Token)
Lemon=Class.new(Token)


