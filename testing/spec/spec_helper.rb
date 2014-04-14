require 'coveralls'
Coveralls.wear!

# so that i can require stuff as if these dirctories were in ruby's default PATH
$: << File.expand_path(File.dirname(__FILE__))+"/../../domain"
$: << File.expand_path(File.dirname(__FILE__))+"/../../dsl"

require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
  config.default_path = 'testing/spec'
  config.formatter = :progress
end

require 'diagrams/diagram'
require 'diagrams/debug_diagram'
require 'edges/edge'
require 'edges/random_edge'
require 'exceptions/no_elements_of_given_type'
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