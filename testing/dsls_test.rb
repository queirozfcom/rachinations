require_relative '../domain/diagrams/diagram'
require_relative '../dsl/dsl.rb'
gem 'minitest'
require "minitest/autorun"
require 'coveralls'
Coveralls.wear!

class DSLSTest < MiniTest::Test
  include DSL

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


  def test_create

   diagram 'test_diagram' do
      node 'source', Source
      node 'pool1', Pool
      edge 'edge1', Edge, 'source', 'pool1'
    end

  end

  def test_create_and_run

    diagram 'test_diagram' do
      node 'source', Source
      node 'pool1', Pool
      edge 'edge1', Edge, 'source', 'pool1'
    end.run!

  end

  def test_return_diagram

    d=diagram 'test_diagram' do
      node 'source', Source
      node 'pool1', Pool
      edge 'edge1', Edge, 'source', 'pool1'
    end

    assert d.is_a? Diagram

  end

  def test_simple_diagram_results

    d = diagram 'test_simple_diagram' do
      node 'source',Source
      node 'pool1',Pool, mode: :push, activation: :automatic
      node 'pool2',Pool
      edge 'edge1',Edge,'source','pool1'
      edge 'edge2',Edge,'pool1','pool2'
      run! 4
    end

    # rather than calling run! from within the block, we could've called it afterwards,
    # for example: d.run!(4)

    assert d.is_a? Diagram

    assert_equal 3,d.get_node('pool2').resource_count
    assert_equal 1,d.get_node('pool1').resource_count

  end


end