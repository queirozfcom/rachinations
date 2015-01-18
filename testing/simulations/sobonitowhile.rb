require_relative '../../domain/diagrams/diagram'
require_relative '../../dsl/dsl'
require_relative '../../domain/nodes/pool'
require_relative '../../domain/edges/edge'
include DiagramShorthandMethods

n=diagram 'test_diagram', :verbose do
  node 'p1', Pool, mode: :push, activation: :automatic, initial_value: 8
  node 'p2', Pool, mode: :push, activation: :automatic
  node 'p3', Pool, mode: :push, activation: :automatic
  node 'p4', Pool, mode: :push, activation: :automatic
  edge 'e1', Edge, 'p1', 'p2'
  edge 'e2', Edge, 'p2', 'p1'
  edge 'e3', Edge, 'p1', 'p3'
  edge 'e4', Edge, 'p3', 'p1'
  edge 'e5', Edge, 'p4', 'p2'
  edge 'e6', Edge, 'p2', 'p4'
  edge 'e7', Edge, 'p4', 'p3'
  edge 'e8', Edge, 'p3', 'p4'
end

d = Diagram.new('bonitinho')

n.run_while! do
  not (n.get_node("p1").resource_count == 2 and n.get_node("p4").resource_count == 2)
end


