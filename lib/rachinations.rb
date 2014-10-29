lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rachinations/version'

require 'rachinations/domain/modules/common/refiners/proc_convenience_methods'
require 'rachinations/domain/modules/common/refiners/number_modifiers'

require 'rachinations/extras/fifo'

require 'rachinations/domain/diagrams/diagram'
require 'rachinations/domain/diagrams/verbose_diagram'
require 'rachinations/dsl/dsl'
require 'rachinations/domain/strategies/strategy'
require 'rachinations/domain/strategies/valid_types'
require 'rachinations/domain/edges/edge'
require 'rachinations/domain/exceptions/no_elements_of_given_type'
require 'rachinations/domain/exceptions/unsupported_type_error'
require 'rachinations/domain/exceptions/bad_options'
require 'rachinations/domain/exceptions/no_elements_matching_condition_error'
require 'rachinations/domain/exceptions/no_elements_found'
require 'rachinations/domain/nodes/node'
require 'rachinations/domain/nodes/resourceful_node'
require 'rachinations/domain/nodes/pool'
require 'rachinations/domain/nodes/source'
require 'rachinations/domain/nodes/sink'
require 'rachinations/domain/nodes/gate'
require 'rachinations/domain/nodes/trader'
require 'rachinations/domain/nodes/converter'
require 'rachinations/domain/resources/token'
require 'rachinations/domain/edge_collection'
require 'rachinations/domain/node_collection'
require 'rachinations/domain/resource_bag'


include DSL
using NumberModifiers
