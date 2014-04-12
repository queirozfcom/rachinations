require_relative '../domain/diagram'
gem 'minitest'
require "minitest/autorun"
require 'minitest/reporters'

require 'coveralls'
Coveralls.wear!

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

    assert_equal 2, p.get_node('pool1').resource_count
    assert_equal 5, p.get_node('pool2').resource_count


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

    assert_equal 1, p.get_node('pool1').resource_count
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

    p.add_node!(Pool, name: 'pool1', :initial_value => 5)

    p.add_node!(Pool, name: 'pool2', :activation => :automatic)

    p.add_edge!(Edge, name: 'connector2', from: 'pool1', to: 'pool2')

    #i know this is too much
    p.run!(10)

    assert_equal(0, p.get_node("pool1").resource_count)
    assert_equal(5, p.get_node("pool2").resource_count)
  end


  def test_one_source_three_pools
    p = Diagram.new('one source three pools')

    p.add_node!(Source, name: 'source')

    p.add_node!(Pool, name: 'pool1', mode: :push, activation: :automatic)

    p.add_node!(Pool, name: 'pool2')

    p.add_node!(Pool, name: 'pool3', activation: :automatic)

    p.add_edge!(Edge, name: 'connector1', from: 'source', to: 'pool1')

    p.add_edge!(Edge, name: 'connector2', from: 'pool1', to: 'pool2')

    p.add_edge!(Edge, name: 'connector3', from: 'pool2', to: 'pool3')

    p.run!(4)

    assert_equal(1, p.get_node("pool1").resource_count)
    assert_equal(1, p.get_node("pool2").resource_count)
    assert_equal(2, p.get_node("pool3").resource_count)

  end


  def test_get_invalid_node

    p = Diagram.new('get invalid node')

    p.add_node! Source, name: 'source'

    p.add_node! Pool, name: 'pool1'

    p.add_edge! Edge, {
        name: 'connector1',
        from: 'source',
        to: 'pool1'
    }

    assert_raises(RuntimeError) { p.get_node('pool2') }

  end

  def test_one_source_one_pool_types

    green = Class.new(Token)
    red = Class.new(Token)

    p = Diagram.new('one source one pool typed')

    p.add_node!(Source, name: 'source', :types => [green])

    p.add_node!(Pool, name: 'pool1', :types => [green, red])

    p.add_edge!(Edge, name: 'connector1', from: 'source', to: 'pool1')

    p.run!(5)

    assert_equal(5, p.get_node('pool1').resource_count(green))
    assert_equal(0, p.get_node('pool1').resource_count(red))

  end


  def test_two_pools_different_types_edge_allows_types

    gREEN = Class.new(Token)

    #setting the constant so I can reference this class by name..
    # this is useful when I need to see the contents of a pool
    Object.const_set(:Green, gREEN)

    rED = Class.new(Token)
    Object.const_set(:Red, rED)

    p = Diagram.new('two pools different types')

    p.add_node!(Source, name: 'source', :types => [gREEN])

    p.add_node!(Pool, name: 'pool1', types: [gREEN, rED])

    p.add_edge! Edge, name: 'connector1', from: 'source', to: 'pool1'

    p.run!(5)

    assert_equal(5, p.get_node('pool1').resource_count(gREEN))
    assert_equal(0, p.get_node('pool1').resource_count(rED))

  end


  def test_two_automatics_pulling_and_pushing

    d = Diagram.new 'my-diagram'

    d.add_node! Pool, name: 'pool1', :initial_value => 25, :mode => :push, :activation => :automatic

    d.add_node! Pool, name: 'pool2', :initial_value => 0, :mode => :pull, :activation => :automatic

    d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool2'

    d.run!(5)

    assert_equal 20, d.get_node('pool1').resource_count
    assert_equal 5, d.get_node('pool2').resource_count

  end


  def test_leaves_but_doesnt_arrive

    blue = Class.new(Token)
    black = Class.new(Token)

    d = Diagram.new 'my-diagram'

    d.add_node! Pool, name: 'pool1', :initial_value => {blue => 25}, :mode => :push, :activation => :automatic
    d.add_node! Pool, name: 'pool2', :initial_value => {black => 20}, :mode => :push, :activation => :automatic
    d.add_node! Pool, name: 'pool3', :initial_value => {blue => 0}

    d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool3', :types => [blue, black]
    d.add_edge! Edge, name: 'edge2', from: 'pool2', to: 'pool3', :types => [blue, black]

    d.run!(5)

    assert_equal 20, d.get_node('pool1').resource_count(blue)
    assert_equal 5, d.get_node('pool3').resource_count(blue)
    assert_equal 15, d.get_node('pool2').resource_count(black)


  end

  def test_one_source_two_pools_typed_pull

    green = Class.new(Token)
    red = Class.new(Token)
    yellow = Class.new(Token)
    blue = Class.new(Token)


    p = Diagram.new('one source two pools types pull')

    p.add_node!(Source, name: 'source', :types => [green])

    p.add_node!(Pool, name: 'pool1', :types => [green, red])

    p.add_node!(Pool, name: 'pool2', :activation => :automatic, :types => [green, yellow])

    p.add_edge! Edge, name: 'connector1', from: 'source', to: 'pool1'

    p.add_edge!(Edge, name: 'connector2', from: 'pool1', to: 'pool2', :types => [green, red, blue])

    p.run!(5)

    assert_equal(1, p.get_node("pool1").resource_count(green))
    assert_equal(4, p.get_node("pool2").resource_count(green))


  end

  def test_nodes_dont_accept_resources_of_other_types

    football = Class.new(Token)
    basketball = Class.new(Token)
    baseball = Class.new(Token)

    p = Diagram.new ('test nodes don\'t accept resources of foreign types')

    p.add_node!(Source, :name => 'source', :types => [football])

    p.add_node!(Pool, :name => 'pool1', :mode => :push, :activation => :automatic, types: [football])

    p.add_node!(Pool, :name => 'pool2', :types => [football, basketball])

    p.add_node!(Pool, :name => 'pool3', :activation => :automatic, :types => [basketball, baseball])

    p.add_edge!(Edge, name: 'connector1', from: 'source', to: 'pool1')

    p.add_edge!(Edge, name: 'connector2', from: 'pool1', to: 'pool2')

    p.add_edge!(Edge, name: 'connector3', from: 'pool2', to: 'pool3')

    p.run!(4)


    assert_equal 1, p.get_node('pool1').resource_count(football)
    assert_equal 0, p.get_node('pool2').resource_count(basketball)
    assert_equal 3, p.get_node('pool2').resource_count(football)

  end


end