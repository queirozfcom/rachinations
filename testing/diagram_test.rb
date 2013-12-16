require_relative '../models/diagram'
require "rubygems"
gem "test-unit"
require "test/unit"

class DiagramTesting < Test::Unit::TestCase

	def test_one_source_one_pool
		p = Diagram.new('test1')

		source = Source.new "source"
		p.add_node! source

		pool1 = Pool.new "pool1"
		p.add_node! pool1

		edge1 = Edge.new 'connector1', "source",  "pool1"
		p.add_edge! edge1

		p.run!(5)

		assert_equal 5, p.get_node("pool1").resource_count
  end


=begin
  def test_one_source_two_pools
    p = Diagram.new

    source = Source.new(:name=>"source")
    p.add_node!(source)

    pool1 = Pool.new(:name=>"pool1")
    p.add_node!(pool1)

    pool2 = Pool.new(:name=>"pool2",:activation=>"automatic")
    p.add_node!(pool2)

    edge1 = Edge.new("source","pool1",:name=>"connector1")
    p.add_edge!(edge1)

    edge2 = Edge.new("pool1","pool2",:name=>"connector2")
    p.add_edge!(edge2)

    p.run!(3)

    assert_equal(1, p.get_node("pool1").resources)
    assert_equal(2,p.get_node("pool2").resources)
  end

  def test_one_source_three_pools
    p = Diagram.new

    source = Source.new(:name=>"source")
    p.add_node!(source)

    pool1 = Pool.new(:name=>"pool1",:mode=>"push",:activation=>"automatic")
    p.add_node!(pool1)

    pool2 = Pool.new(:name=>"pool2")
    p.add_node!(pool2)

    pool3 = Pool.new(:name=>"pool3",:activation=>"automatic")

    p.add_node!(pool3)

    edge1 = Edge.new("source","pool1",:name=>"connector1")
    p.add_edge!(edge1)

    edge2 = Edge.new("pool1","pool2",:name=>"connector2")
    p.add_edge!(edge2)

    p.add_edge!(Edge.new("pool2","pool3",:name=>"connector3"))

    p.run!(4)

    assert_equal(1, p.get_node("pool1").resources)
    assert_equal(1, p.get_node("pool2").resources)
    assert_equal(2, p.get_node("pool3").resources)

  end



  def test_get_invalid_node

		p = Diagram.new

		source = Source.new(:name=>'source')
		p.add_node!(source)

		pool1 = Pool.new(:name=>'pool1')
		p.add_node!(pool1)

		edge1 = Edge.new('source','pool1',:name=>'connector1')
		p.add_edge!(edge1)

		assert_raise('RuntimeError') { p.get_node('pool2') }

  end



  def test_other_types

    p = Diagram.new

    p.add_node!(Source.new(:name=>'source',:types=>[Football]))

    p.add_node!(Pool.new(:name=>'pool1',:mode=>'push',:activation=>'automatic'))

    p.add_node!(Pool.new(:name=>'pool2',:types=>[Football,Basketball]))

    p.add_node!(Pool.new(:name=>'pool3',:activation=>'automatic',:types=>[Baseball,Basketball]))

    p.add_edge!(Edge.new('source','pool1',:name=>'connector1'))

    p.add_edge!(Edge.new('pool1','pool2',:name=>'connector2'))
    
    p.add_edge!(Edge.new('pool2','pool3',:name=>'connector3'))

    p.run!(4)

    assert_equal(1, p.get_node('pool1').resource_count(Football))
    assert_equal(3, p.get_node('pool2').resource_count(Football))
    assert_equal(0, p.get_node('pool3').resource_count(Football))

  end

  def test_nodes_dont_accept_resources_of_other_types

    p = Diagram.new

    source = Source.new(:name=>"source",:types=>[Football])
    p.add_node!(source)

    pool1 = Pool.new(:name=>"pool1",:mode=>"push",:activation=>"automatic")
    p.add_node!(pool1)

    pool2 = Pool.new(:name=>"pool2",:types=>[Football,Basketball])
    p.add_node!(pool2)

    pool3 = Pool.new(:name=>"pool3",:activation=>"automatic",:types=>[Basketball,Baseball])

    p.add_node!(pool3)

    edge1 = Edge.new("source","pool1",:name=>"connector1")
    p.add_edge!(edge1)

    edge2 = Edge.new("pool1","pool2",:name=>"connector2")
    p.add_edge!(edge2)

    p.add_edge!(Edge.new("pool2","pool3",:name=>"connector3"))

    p.run!(4)
  end

  def test_each_resource_is_unique
    #if a source generates 4 Footballs, then the Footballs that will end up in the other nodes are not
    #just *any* Footballs, but the same Footballs, as identified by their object_id.
    p = Diagram.new

    source = Source.new(:name=>"source",:types=>[Football])
    p.add_node!(source)


    pool1 = Pool.new(:name=>"pool1")
    p.add_node!(pool1)

    pool2 = Pool.new(:name=>"pool2",:activation=>"automatic")
    p.add_node!(pool2)

    edge1 = Edge.new("source","pool1",:name=>"connector1")
    p.add_edge!(edge1)

    edge2 = Edge.new("pool1","pool2",:name=>"connector2")
    p.add_edge!(edge2)

    p.run!(3)

    assert_equal(1, p.get_node("pool1").resources)
    assert_equal(2,p.get_node("pool2").resources)
  end

=end

end