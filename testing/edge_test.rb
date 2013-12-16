require_relative '../models/edge'
require "rubygems"
gem "test-unit"
require "test/unit"

class MyTest < Test::Unit::TestCase

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

    edge = Edge.new 'edge1', 'foo', 'bar'

    assert_equal 1, edge.label
    assert_equal :all, edge.types_allowed
    assert_equal :none, edge.types_disallowed

  end

  def test_types_allowed

    edge = Edge.new 'edge1', 'foo', 'bar', :types_allowed => [:blue, :black]

    assert_equal 'edge1', edge.name
    assert_equal 'foo', edge.from_node_name
    assert_equal 'bar', edge.to_node_name
    assert_equal [:blue, :black], edge.types_allowed
    assert_equal nil, edge.types_disallowed

  end

  def test_types_disallowed
    edge = Edge.new 'edge1', 'foo', 'bar', :types_disallowed => [:blue, :red]

    assert_equal 'edge1', edge.name
    assert_equal 'foo', edge.from_node_name
    assert_equal 'bar', edge.to_node_name
    assert_equal [:blue, :red], edge.types_disallowed
    assert_equal nil, edge.types_allowed
    assert_equal 1, edge.label
  end

  def test_label

    edge = Edge.new 'edge1', 'foo', 'bar', :types_disallowed => [:blue, :red], :label => 5

    assert_equal 'edge1', edge.name
    assert_equal 'foo', edge.from_node_name
    assert_equal 'bar', edge.to_node_name
    assert_equal [:blue, :red], edge.types_disallowed
    assert_equal nil, edge.types_allowed
    assert_equal 5, edge.label

  end


end