require_relative '../domain/diagram'
require "rubygems"
gem 'minitest'
require "minitest/autorun"
require 'coveralls'
Coveralls.wear!

class ResourceBagTest < MiniTest::Test

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

  def test_removal_works

    bag = ResourceBag.new

    obj1 = Token.new
    obj2 = Token.new


    bag.add(obj1)
    bag.add(obj2)

    bag.get(Token)

    assert_equal 1,bag.count(Token)

    bag.get(Token)

    assert_equal 0,bag.count(Token)

    assert_raises(NoElementsOfGivenTypeError) {bag.get(Token)}

    assert_equal 0,bag.count(Token)

  end

end