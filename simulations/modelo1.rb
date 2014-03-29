require_relative '../domain/diagram'
require_relative '../dsl/dsl.rb'
include DSL

n=diagram 'test_diagram' do
  node 'source', Source
  node 'pool1', Pool
  edge 'edge1', Edge, 'source', 'pool1'
end

d = Diagram.new('one source one pool')

n.run!(5)


