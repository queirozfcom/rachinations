require 'coveralls'
Coveralls.wear!

$: << File.expand_path(File.dirname(__FILE__))+"/../../domain"
$: << File.expand_path(File.dirname(__FILE__))+"/../../dsl"

require 'rspec'


require 'diagrams/diagram'
require 'diagrams/debug_diagram'
require 'edges/edge'
require 'edges/random_edge'
require 'exceptions/no_elements_of_given_type'
require 'modules/invariant'
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