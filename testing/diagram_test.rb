require_relative '../domain/diagram'
gem 'minitest'
require "minitest/autorun"
require 'minitest/reporters'

#pretty outputs
MiniTest::Reporters.use!

class DiagramTest < MiniTest::Test

  def test_two_pools
    p = Diagram.new 'two pools'

    p.add_node! Pool, {
        :name => 'pool1',
        :initial_value => 7,
        :mode => :push,
        :activation => :automatic
    }

    p.add_node! Pool, {
        :name => 'pool2',
    }

    p.add_edge! Edge, {
        :name => 'connector1',
        :from => 'pool1',
        :to => 'pool2'
    }

    p.run!(5)

    assert_equal 2,p.get_node('pool1').resource_count
    assert_equal 5,p.get_node('pool2').resource_count


  end

  def test_one_source_one_pool
    p = Diagram.new('one source one pool')

    p.add_node! Source, {
        :name => 'source'
    }

    p.add_node! Pool, {
        :name => 'pool1'
    }

    p.add_edge! Edge, {
        :name => 'connector1',
        :from => 'source',
        :to => 'pool1'
    }

    p.run!(5)

    assert_equal 5, p.get_node("pool1").resource_count
  end

  def test_one_source_two_pools_single_run
    p = Diagram.new('one source two pools')

    p.add_node!(Source, {name: 'source'})

    p.add_node!(Pool, {name: 'pool1'})

    p.add_node!(Pool, {name: 'pool2', activation: :automatic})

    p.add_edge!(Edge, {name: 'edge1', from: 'source', to: 'pool1'})

    p.add_edge!(Edge, {name: 'connector2', from: 'pool1', to: 'pool2'})

    p.run!(1)

    assert_equal(1, p.get_node("pool1").resource_count)
    assert_equal(0, p.get_node("pool2").resource_count)
  end


  def test_one_source_two_pools_multiple_runs
    p = Diagram.new('one source two pools')

    p.add_node!(Source, {name: 'source'})

    p.add_node!(Pool, {name: 'pool1'})

    p.add_node!(Pool, {name: 'pool2', activation: :automatic})

    p.add_edge!(Edge, {name: 'edge1', from: 'source', to: 'pool1'})

    p.add_edge!(Edge, {name: 'connector2', from: 'pool1', to: 'pool2'})


    p.run!(1)

    assert_equal 1,p.get_node('pool1').resource_count
    assert_equal(0, p.get_node("pool2").resource_count)


    p.run!(1)

    assert_equal(1, p.get_node("pool1").resource_count)
    assert_equal(1, p.get_node("pool2").resource_count)

    p.run!(1)

    assert_equal(1, p.get_node("pool1").resource_count)
    assert_equal(2, p.get_node("pool2").resource_count)


  end


  def test_two_pools_pull_automatic
    p = Diagram.new('two pools pull automatic')

    p.add_node!(Pool,name: 'pool1', :initial_value => 5)

    p.add_node!(Pool,name:'pool2', :activation => :automatic)

    p.add_edge!(Edge,name:'connector2',from: 'pool1',to: 'pool2')

    #i know this is too much
    p.run!(10)

    assert_equal(0, p.get_node("pool1").resource_count)
    assert_equal(5, p.get_node("pool2").resource_count)
  end


  def test_one_source_three_pools
    p = Diagram.new('one source three pools')

    p.add_node!(Source,name:'source')

    p.add_node!(Pool,name:'pool1',mode: :push,activation: :automatic)

    p.add_node!(Pool,name:'pool2')

    p.add_node!(Pool,name:'pool3',activation: :automatic)

    p.add_edge!(Edge, name:'connector1',from:'source',to:'pool1')

    p.add_edge!(Edge, name: 'connector2',from:'pool1',to:'pool2')

    p.add_edge!(Edge, name: 'connector3',from:'pool2',to:'pool3')

    p.run!(4)

    assert_equal(1, p.get_node("pool1").resource_count)
    assert_equal(1, p.get_node("pool2").resource_count)
    assert_equal(2, p.get_node("pool3").resource_count)

  end

=begin

  def test_get_invalid_node

    p = Diagram.new('get invalid node')

    source = Source.new('source')
    p.add_node!(source)

    pool1 = Pool.new('pool1')
    p.add_node!(pool1)

    edge1 = Edge.new('connector1', 'source', 'pool1')
    p.add_edge!(edge1)

    assert_raises(RuntimeError) { p.get_node('pool2') }

  end

  def test_one_source_one_pool_types

    p = Diagram.new('one source one pool typed')

    p.add_node!(Source.new('source', :types => [:green]))

    p.add_node!(Pool.new('pool1', :types => [:green, :red]))

    p.add_edge!(Edge.new('connector1', 'source', 'pool1'))

    p.run!(5)

    assert_equal(5, p.get_node('pool1').resource_count(:green))
    assert_equal(0, p.get_node('pool1').resource_count(:red))

  end

  def test_two_pools_different_types_edge_allows_types

    p = Diagram.new('two pools different types')

    p.add_node!(Source.new('source', :types => [:green]))

    p.add_node!(Pool.new('pool1', :types => [:green, :red]))

    p.add_edge!(Edge.new('connector1', 'source', 'pool1'))

    p.run!(5)

    assert_equal(5, p.get_node('pool1').resource_count(:green))
    assert_equal(0, p.get_node('pool1').resource_count(:red))

  end

  def test_two_automatics_pulling_and_pushing

    d = Diagram.new 'my-diagram'

    d.add_node! Pool.new 'pool1', :initial_value => 25, :mode => :push, :activation => :automatic

    d.add_node! Pool.new 'pool2', :initial_value => 0, :mode => :pull, :activation => :automatic

    d.add_edge! Edge.new 'edge1','pool1','pool2'

    d.run!(5)

    assert_equal 20, d.get_node('pool1').resource_count
    assert_equal 5,d.get_node('pool2').resource_count

  end

  def test_leaves_but_doesnt_arrive

    d = Diagram.new 'my-diagram'

    d.add_node! Pool.new 'pool1', :initial_value => { :blue => 25 }, :mode => :push, :activation => :automatic

    d.add_node! Pool.new 'pool2', :initial_value => { :black => 20 }, :mode => :push, :activation => :automatic

    d.add_node! Pool.new 'pool3', :initial_value => {:blue => 0}
    d.add_edge! Edge.new 'edge1','pool1','pool3', :types=> [:blue, :black]

    d.add_edge! Edge.new 'edge2','pool2','pool3', :types=> [:blue, :black]

    d.run!(5)

    assert_equal 20, d.get_node('pool1').resource_count(:blue)
    assert_equal 5,d.get_node('pool3').resource_count(:blue)

    assert_equal 15,d.get_node('pool2').resource_count(:black)


  end

=begin

def test_one_source_two_pools_typed_pull

    p = Diagram.new('one source two pools types pull')

    source = Source.new('source', :types =>[:green])
    p.add_node!(source)

    pool1 = Pool.new('pool1',:types => [:green,:red])
    p.add_node!(pool1)

    pool2 = Pool.new('pool2', :activation => :automatic, :types => [:green, :yellow])
    p.add_node!(pool2)

    edge1 = Edge.new('connector1', 'source', 'pool1')
    p.add_edge!(edge1)

    edge2 = Edge.new('connector2', 'pool1', 'pool2', :types => [:green, :red, :blue])
    p.add_edge!(edge2)

    p.run!(5)

    assert_equal(1, p.get_node("pool1").resource_count(:green))
    assert_equal(4, p.get_node("pool2").resource_count(:green))


  end

  def test_nodes_dont_accept_resources_of_other_types

    p = Diagram.new

    source = Source.new(:name=>"source",:types=>[Football])
    p.add_node!(source)

    pool1 = Pool.new(:name=>"pool1",:mode=>"push",:activation=>"automatic")
    p.add_node!(pool1)

    pool2 = Pool.new(:name=>"pool2",:types=>[Football,Basketball])
    p.add_node!(pool2)

    pool3 = Pool.new(:name=>"pool3",:activation=>"automatic",:types=>[Basketball,Baseball])

    p.add_node!(pool3)

    edge1 = Edge.new("source","pool1",:name=>"connector1")
    p.add_edge!(edge1)

    edge2 = Edge.new("pool1","pool2",:name=>"connector2")
    p.add_edge!(edge2)

    p.add_edge!(Edge.new("pool2","pool3",:name=>"connector3"))

    p.run!(4)
  end

  def test_each_resource_is_unique
    #if a source generates 4 Footballs, then the Footballs that will end up in the other nodes are not
    #just *any* Footballs, but the same Footballs, as identified by their object_id.
    p = Diagram.new

    source = Source.new(:name=>"source",:types=>[Football])
    p.add_node!(source)


    pool1 = Pool.new(:name=>"pool1")
    p.add_node!(pool1)

    pool2 = Pool.new(:name=>"pool2",:activation=>"automatic")
    p.add_node!(pool2)

    edge1 = Edge.new("source","pool1",:name=>"connector1")
    p.add_edge!(edge1)

    edge2 = Edge.new("pool1","pool2",:name=>"connector2")
    p.add_edge!(edge2)

    p.run!(3)

    assert_equal(1, p.get_node("pool1").resources)
    assert_equal(2,p.get_node("pool2").resources)
  end

=end

end