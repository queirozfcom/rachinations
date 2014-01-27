require_relative '../domain/edge'
require "minitest/autorun"

class EdgeTest < MiniTest::Test

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

  def test_simple

    edge = Edge.new name: 'edge1', from: 'foo',to: 'bar'

    assert_equal 1, edge.label
    assert_equal [], edge.types

  end

  def test_types_allowed

    edge = Edge.new name:'edge1', from:'foo',to: 'bar', types: [:blue, :black]

    assert_equal 'edge1', edge.name
    assert_equal 'foo', edge.from_node_name
    assert_equal 'bar', edge.to_node_name
    assert_equal [:blue, :black], edge.types

  end


  def test_label

    edge = Edge.new name:'edge1', from:'foo',to: 'bar', types: [:blue, :red], label: 5

    assert_equal 'edge1', edge.name
    assert_equal 'foo', edge.from_node_name
    assert_equal 'bar', edge.to_node_name
    assert_equal [:blue, :red], edge.types
    assert_equal 5, edge.label

  end


end