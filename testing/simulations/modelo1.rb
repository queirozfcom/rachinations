require_relative '../../domain/diagrams/diagram'
require_relative '../../dsl/dsl'
require_relative '../../domain/nodes/pool'
require_relative '../../domain/nodes/source'
require_relative '../../domain/edges/edge'

include DSL

n=diagram 'test_diagram' , :verbose do
  node 'source', Source
  node 'pool1', Pool
  edge 'edge1', Edge, 'source', 'pool1'
end

n.run!(5)


