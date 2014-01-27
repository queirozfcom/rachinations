require_relative '../domain/diagram'
require "rubygems"
gem 'minitest'
require "minitest/autorun"

class SourceTest < MiniTest::Test

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

  def test_attributes
    source = Source.new name:'source'

    assert_equal 'source', source.name
    assert_equal :automatic, source.activation
    assert_equal :push, source.mode

  end



end