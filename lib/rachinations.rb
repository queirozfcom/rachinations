lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rachinations/version'

require 'rachinations/utils/math_utils'
require 'rachinations/utils/string_utils'

require 'rachinations/domain/modules/common/refiners/proc_convenience_methods'
require 'rachinations/domain/modules/common/refiners/number_modifiers'
require 'rachinations/domain/modules/common/schedulable_tasks'

require 'rachinations/extras/fifo'

require 'rachinations/domain/diagrams/diagram'
require 'rachinations/domain/diagrams/verbose_diagram'
require 'rachinations/domain/diagrams/default_diagram'
require 'rachinations/domain/diagrams/silent_diagram'
require 'rachinations/domain/diagrams/non_deterministic_diagram'
require 'rachinations/dsl/diagram_shorthand_methods'
require 'rachinations/dsl/bootstrap'
require 'rachinations/domain/strategies/strategy'
require 'rachinations/domain/strategies/valid_types'
require 'rachinations/domain/edges/edge'

require 'rachinations/domain/exceptions/no_elements_of_given_type'
require 'rachinations/domain/exceptions/unsupported_type_error'
require 'rachinations/domain/exceptions/no_elements_matching_condition_error'
require 'rachinations/domain/exceptions/no_elements_found'
require 'rachinations/domain/exceptions/bad_config'
require 'rachinations/dsl/bad_dsl'

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

# users can use the dsl to create diagrams
include DSL::Bootstrap

# users can call .percent on numbers
include NumberModifiers


