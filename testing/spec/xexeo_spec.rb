require_relative 'spec_helper'

#models in testing/simulations, rewritten as specs

describe Diagram do

  using DSL::DiagramShorthandMethods

  it "runs modelo1" do

    n=diagram 'test_diagram' do
      source 'source'
      pool 'pool1'
      edge from: 'source', to: 'pool1'
    end

    n.run!(5)

  end

  it "runs modelo2" do

    generator = Diagram.new('1to2')

    generator.add_node! Pool, {
        :name => 'g1',
        :activation => :automatic,
        :initial_value => 5,
        mode: :push_any
    }

    generator.add_node! Pool, {
        :name => 'g2',
        :activation => :automatic,
        mode: :push_any
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
        mode: :push_any
    }

    generator.add_node! Pool, {
        name: 'g2',
        activation: :automatic,
        mode: :push_any
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
      pool 'p1', mode: :push_any, activation: :automatic, initial_value: 8
      pool 'p2', mode: :push_any, activation: :automatic
      pool 'p3', mode: :push_any, activation: :automatic
      pool 'p4', mode: :push_any, activation: :automatic
      edge from: 'p1', to: 'p2'
      edge from: 'p2', to: 'p3'
      edge from: 'p3', to: 'p4'
    end

    n.run!(5)

    #puts n
  end

  it "runs sobonito" do

    n=diagram 'test_diagram' do
      pool 'p1', mode: :push_any, activation: :automatic, initial_value: 8
      pool 'p2', mode: :push_any, activation: :automatic
      pool 'p3', mode: :push_any, activation: :automatic
      pool 'p4', mode: :push_any, activation: :automatic
      edge from: 'p1',to: 'p2'
      edge from: 'p2',to: 'p1'
      edge from: 'p1',to: 'p3'
      edge from: 'p3',to: 'p1'
      edge from: 'p4',to: 'p2'
      edge from: 'p2',to: 'p4'
      edge from: 'p4',to: 'p3'
      edge from: 'p3',to: 'p4'
    end

    n.run!(20)
  end

  it "runs sobonitowhile" do
    n=diagram 'test_diagram' do
      pool 'p1',  mode: :push_any, activation: :automatic, initial_value: 8
      pool 'p2',  mode: :push_any, activation: :automatic
      pool 'p3',  mode: :push_any, activation: :automatic
      pool 'p4',  mode: :push_any, activation: :automatic
      edge from: 'p1',to: 'p2'
      edge from: 'p2',to: 'p1'
      edge from: 'p1',to: 'p3'
      edge from: 'p3',to: 'p1'
      edge from: 'p4',to: 'p2'
      edge from: 'p2',to: 'p4'
      edge from: 'p4',to: 'p3'
      edge from: 'p3',to: 'p4'
    end

    d = Diagram.new('bonitinho')

    n.run_while! do
      not (n.get_node("p1").resource_count == 2 and n.get_node("p4").resource_count == 2)
    end
  end


  it "runs whatIwish1" do

    skip "Needed features are missing"

    # n=diagram 'test_diagram' do
    #   node 'source', Source
    #   node 'pool1', Pool
    #   edge 'edge1', Edge, 'source', 'pool1'
    #   node 'pool2', Pool,
    #   converter 'c1'
    #   node 'e3' , Edge , 'pool2' , 'c1'
    #   trigger 't1' , Trigger , 'pool1' , 'pool2' , { |ExtendedNode p| p.resouces>0 }
    # end
    #
    # n.run!(5,report=true)

  end

end