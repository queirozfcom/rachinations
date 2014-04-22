require_relative '../../domain/diagrams/diagram'
require_relative '../dsl/dsl.rb'
include DSL

n=diagram 'test_diagram' do
  node 'p1', Pool, mode: :push, activation: :automatic, initial_value: 8
  node 'p2', Pool, mode: :push, activation: :automatic
  node 'p3', Pool, mode: :push, activation: :automatic
  node 'p4', Pool, mode: :push, activation: :automatic
  edge 'e1', Edge, 'p1', 'p2'
  edge 'e2', Edge, 'p2', 'p3'
  edge 'e3', Edge, 'p3', 'p4'
end

n.run!(5,true)

puts n
