require_relative '../dsl/dsl.rb'
require "rubygems"
gem "test-unit"
require "test/unit"


class DSLSTest < Test::Unit::TestCase
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


  def test_no_error

    diagram 'test_diagram' do
      node 'source', Source, :types => ['blue']
      node 'pool1',  Pool, :activation => :automatic, :types => ['blue','yellow']
      edge 'edge1', 'source','pool1', :types => ['blue,red']
    end

  end
end