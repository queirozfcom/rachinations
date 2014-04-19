require 'coveralls'
Coveralls.wear!

# so that i can require stuff as if these dirctories were in ruby's default PATH
$: << File.expand_path(File.dirname(__FILE__))+"/../../domain"
$: << File.expand_path(File.dirname(__FILE__))+"/../../dsl"

require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
  config.default_path = 'testing/spec'
end

require 'diagrams/diagram'
require 'diagrams/debug_diagram'
require 'strategies/strategy'
require 'strategies/valid_types'
require 'edges/edge'
require 'edges/random_edge'
require 'exceptions/no_elements_of_given_type'
require 'exceptions/unsupported_type_error'
require 'exceptions/no_elements_matching_condition_error'
require 'exceptions/no_elements_found'
require 'nodes/node'
require 'nodes/resourceful_node'
require 'nodes/pool'
require 'nodes/source'
require 'nodes/sink'
require 'nodes/gate'
require 'nodes/trader'
require 'nodes/converter'
require 'resources/token'
require 'edge_collection'
require 'node_collection'
require 'resource_bag'

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


