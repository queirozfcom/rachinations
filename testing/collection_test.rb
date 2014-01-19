require_relative '../domain/edge_collection'
require_relative '../domain/node_collection'
gem 'minitest'
require "minitest/autorun"
require 'minitest/reporters'

#pretty outputs
MiniTest::Reporters.use!

class CollectionTest < MiniTest::Test


  def test_delegation

    EdgeCollection.new.map { |e| el.__id__ }

    assert_raises(NoMethodError) { EdgeCollection.new.inject { |e| el.__id__ } }

  end

end