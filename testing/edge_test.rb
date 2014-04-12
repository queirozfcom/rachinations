require_relative '../domain/diagram'
require "minitest/autorun"
require 'coveralls'
Coveralls.wear!

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

  end

  def test_types_allowed

    blue = Class.new(Token)
    black = Class.new(Token)

    edge = Edge.new name:'edge1', from:'foo',to: 'bar', types: [blue, black]

    assert_equal 'edge1', edge.name
    assert edge.from? 'foo'
    assert edge.to? 'bar'
    assert edge.support? blue
    assert edge.support? black

  end


  def test_label

    blue = Class.new(Token)
    red = Class.new(Token)
    green = Class.new(Token)

    edge = Edge.new name:'edge1', from:'foo',to: 'bar', types: [blue, red], label: 5

    assert_equal 'edge1', edge.name
    assert edge.from? 'foo'
    assert edge.to? 'bar'
    assert edge.support? blue
    assert edge.support? red
    refute edge.support? green
    assert_equal 5, edge.label

  end


end