require_relative '../domain/diagram'
require_relative '../dsl/dsl.rb'
gem 'minitest'
require "minitest/autorun"


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


  def test_no_types

    diagram 'test_diagram' do
      node 'source', Source
      node 'pool1', Pool
      edge 'edge1', Edge, 'source', 'pool1'
    end

  end
end