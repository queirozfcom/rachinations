require_relative 'spec_helper'

#models in testing/simulations, rewritten as specs

describe Diagram do

  it "runs modelo1" do

    n=diagram 'test_diagram' do
      node 'source', Source
      node 'pool1', Pool
      edge 'edge1', Edge, 'source', 'pool1'
    end

    d = Diagram.new('one source one pool')

    n.run!(5)

  end

  it "runs modelo2" do

    generator = Diagram.new('1to2')

    generator.add_node! Pool, {
        :name => 'g1',
        :activation => :automatic,
        :initial_value => 5,
        mode: :push
    }

    generator.add_node! Pool, {
        :name => 'g2',
        :activation => :automatic,
        mode: :push
    }

    generator.add_node! Pool, {
        :name => 'g3'
    }

    generator.add_edge! Edge, {
        :name => 'c1',
        :from => 'g1',
        :to => 'g2'
    }

    generator.add_edge! Edge, {
        :name => 'c2',
        :from => 'g1',
        :to => 'g3'
    }


    generator.add_edge! Edge, {
        :name => 'c3',
        :from => 'g2',
        :to => 'g1'
    }

    generator.run!(5)
  end

  it "runs noreporting" do
    generator = Diagram.new('1to2')

    generator.add_node! Pool, {
        name: 'g1',
        activation: :automatic,
        initial_value: 5,
        mode: :push
    }

    generator.add_node! Pool, {
        name: 'g2',
        activation: :automatic,
        mode: :push
    }

    generator.add_node! Pool, {
        name: 'g3'
    }

    generator.add_edge! Edge, {
        name: 'c1',
        from: 'g1',
        to: 'g2'
    }

    generator.add_edge! Edge, {
        name: 'c2',
        from: 'g1',
        to: 'g3',
    }


    generator.add_edge! Edge, {
        name: 'c3',
        from: 'g2',
        to: 'g1',
    }

# I want to check the initial state
#puts "#### Estado inicial ####"
#puts generator

# run and get the end
    generator.run!(10)

    #puts "#### Estado final ####"
    #puts generator
  end

  it "runs sequencial" do
    n=diagram 'test_diagram' do
      node 'p1', Pool, mode: :push, activation: :automatic, initial_value: 8
      node 'p2', Pool, mode: :push, activation: :automatic
      node 'p3', Pool, mode: :push, activation: :automatic
      node 'p4', Pool, mode: :push, activation: :automatic
      edge 'e1', Edge, 'p1', 'p2'
      edge 'e2', Edge, 'p2', 'p3'
      edge 'e3', Edge, 'p3', 'p4'
    end

    n.run!(5)

    #puts n
  end

  it "runs sobonito" do
    n=diagram 'test_diagram' do
      node 'p1', Pool, mode: :push, activation: :automatic, initial_value: 8
      node 'p2', Pool, mode: :push, activation: :automatic
      node 'p3', Pool, mode: :push, activation: :automatic
      node 'p4', Pool, mode: :push, activation: :automatic
      edge 'e1', Edge, 'p1', 'p2'
      edge 'e2', Edge, 'p2', 'p1'
      edge 'e3', Edge, 'p1', 'p3'
      edge 'e4', Edge, 'p3', 'p1'
      edge 'e5', Edge, 'p4', 'p2'
      edge 'e6', Edge, 'p2', 'p4'
      edge 'e7', Edge, 'p4', 'p3'
      edge 'e8', Edge, 'p3', 'p4'
    end

    d = Diagram.new('bonitinho')

    n.run!(20)
  end

  it "runs sobonitowhile" do
    n=diagram 'test_diagram' do
      node 'p1', Pool, mode: :push, activation: :automatic, initial_value: 8
      node 'p2', Pool, mode: :push, activation: :automatic
      node 'p3', Pool, mode: :push, activation: :automatic
      node 'p4', Pool, mode: :push, activation: :automatic
      edge 'e1', Edge, 'p1', 'p2'
      edge 'e2', Edge, 'p2', 'p1'
      edge 'e3', Edge, 'p1', 'p3'
      edge 'e4', Edge, 'p3', 'p1'
      edge 'e5', Edge, 'p4', 'p2'
      edge 'e6', Edge, 'p2', 'p4'
      edge 'e7', Edge, 'p4', 'p3'
      edge 'e8', Edge, 'p3', 'p4'
    end

    d = Diagram.new('bonitinho')

    n.run_while! do
      not (n.get_node("p1").resource_count == 2 and n.get_node("p4").resource_count == 2)
    end
  end


  it "runs whatIwish1" do

    pending "needed features are missing"

    # n=diagram 'test_diagram' do
    #   node 'source', Source
    #   node 'pool1', Pool
    #   edge 'edge1', Edge, 'source', 'pool1'
    #   node 'pool2', Pool,
    #   converter 'c1' , Converter
    #   node 'e3' , Edge , 'pool2' , 'c1'
    #   trigger 't1' , Trigger , 'pool1' , 'pool2' , { |ExtendedNode p| p.resouces>0 }
    # end
    #
    # n.run!(5,report=true)

  end

end