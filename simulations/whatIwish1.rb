require_relative '../domain/diagram'
require_relative '../dsl/dsl.rb'
include DSL

n=diagram 'test_diagram' do
  node 'source', Source
  node 'pool1', Pool
  edge 'edge1', Edge, 'source', 'pool1'
  node 'pool2', Pool,
  converter 'c1' , Converter
  node 'e3' , Edge , 'pool2' , 'c1'
  trigger 't1' , Trigger , 'pool1' , 'pool2' , { |ExtendedNode p| p.resouces>0 }
end

n.run!(5,report=true)





