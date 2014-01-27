require_relative '../domain/diagram'
require "rubygems"
gem 'minitest'
require "minitest/autorun"

class PoolTest < MiniTest::Test

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_create_simple_Pool_sending_all_parameters

    pool = Pool.new name: 'pool0', :activation => :automatic, :mode => :push, :initial_value => 78

    assert_equal 78 ,pool.resource_count
    assert_equal 'pool0',pool.name
    assert_equal :automatic,pool.activation  
    assert_equal :push, pool.mode
    assert_equal [], pool.types
    
  end

  def test_create_simple_pool_default_attributes

    pool = Pool.new name:'pool1'

    assert_equal 0, pool.resource_count
    assert_equal 'pool1', pool.name
    assert_equal :passive, pool.activation
    assert_equal :pull, pool.mode
    assert_equal [],pool.types
  end

  def test_create_one_custom_type_no_initial_values

    pool = Pool.new name: 'pool1',types: [:amarelo]

    assert_equal 0, pool.resource_count(:amarelo)
    assert_equal 'pool1', pool.name
    assert_equal :passive, pool.activation
    assert_equal :pull, pool.mode
    assert_equal [:amarelo], pool.types

  end

  def test_create_one_custom_type_implicitly_via_initial_values

    pool = Pool.new name: 'pool1', initial_value: {azul: 50} , mode: :push

    assert_equal 50, pool.resource_count(:azul)
    assert_equal 'pool1', pool.name
    assert_equal :passive, pool.activation
    assert_equal :push,pool.mode
    assert_equal [:azul], pool.types

    assert_raises(ArgumentError) { pool.resource_count }
    assert_raises(ArgumentError) { pool.resource_count(:rosa) }

  end

  def test_create_two_custom_types_no_initial_values

    pool = Pool.new name: 'pool1', types: [:verde,:vermelho], activation: :automatic

    assert_equal 'pool1', pool.name
    assert_equal [:verde, :vermelho], pool.types
    assert_equal 0, pool.resource_count(:verde)
    assert_equal 0, pool.resource_count(:vermelho)
    assert_equal :automatic, pool.activation

    assert_raises(ArgumentError) { pool.resource_count(:azul) }
    assert_raises(ArgumentError) { pool.resource_count }

  end

  def test_create_two_custom_types_implicitly_via_initial_value

    pool = Pool.new name:'pool1', initial_value: { azul: 10 , roxo: 40 }

    assert_equal [:azul,:roxo], pool.types
    assert_equal 10, pool.resource_count(:azul)
    assert_equal 40, pool.resource_count(:roxo)

    assert_raises(ArgumentError) { pool.resource_count(:verde) }
    assert_raises(ArgumentError) { pool.resource_count }

  end

end