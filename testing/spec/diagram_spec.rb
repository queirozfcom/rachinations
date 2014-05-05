require_relative 'spec_helper'

describe Diagram do

  it 'can be empty' do
    d = Diagram.new 'empty'
    expect(d.name).to eq 'empty'
  end

  it 'should be created with a source and a pool and run n times with no errors' do

    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }

    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run!(10)

    expect(d.resource_count).to eq 10
    expect(d.get_node('deposit').resource_count).to eq 10

  end

  it "runs for 2 turns with two pools using PULL and there's the correct amount of resources at the end" do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 5

    d.add_node! Pool, name: 'pool2', activation: :automatic

    d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

    d.run!(2)

    expect(d.get_node('pool1').resource_count).to eq 3
    expect(d.get_node('pool2').resource_count).to eq 2

  end

  it "runs for 2 turns with two pools using PULL and add  the correct amount" do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 5

    d.add_node! Pool, name: 'pool2', activation: :automatic

    d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

    d.run!(2)


    expect(d.get_node('pool1').resources_added).to eq 0
    expect(d.get_node('pool2').resources_added).to eq 2
    expect(d.get_node('pool2').resources_removed).to eq 0
    expect(d.get_node('pool1').resources_removed).to eq 2

  end

  it "runs for 2 turns with source and pool using PULL and add and remove the correct amount" do

    d = Diagram.new 'some_name'

    d.add_node! Source, name: 's1', activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_edge! Edge, name: 'edge', from: 's1', to: 'pool2'

    d.run!(2)


    expect(d.get_node('s1').resources_added).to eq 0
    expect(d.get_node('pool2').resources_added).to eq 2
    expect(d.get_node('pool2').resources_removed).to eq 0
    expect(d.get_node('s1').resources_removed).to eq 2

  end


  it "runs for two turns with two pools using PUSH and there's the correct amount of resources at the end" do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 5, mode: :push, activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

    d.run!(2)

    expect(d.get_node('pool1').resource_count).to eq 3
    expect(d.get_node('pool2').resource_count).to eq 2

  end

  it "runs for a single turn with one source and two pools and there's the correct amount of resources at the end" do
    p = Diagram.new('one source two pools')

    p.add_node!(Source, {name: 'source'})

    p.add_node!(Pool, {name: 'pool1'})

    p.add_node!(Pool, {name: 'pool2', activation: :automatic})

    p.add_edge!(Edge, {name: 'edge1', from: 'source', to: 'pool1'})

    p.add_edge!(Edge, {name: 'connector2', from: 'pool1', to: 'pool2'})

    p.run!(1)

    expect(p.get_node('pool1').resource_count).to eq 1
    expect(p.get_node('pool2').resource_count).to eq 0

  end

  it 'takes staging and commit steps into account when run with 3 pools for 1 turn only' do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 2, mode: :push, activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_node! Pool, name: 'pool3', activation: :automatic

    d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool2'

    d.add_edge! Edge, name: 'edge2', from: 'pool2', to: 'pool3'

    d.run!(1)

    expect(d.get_node('pool1').resource_count).to eq 1
    expect(d.get_node('pool2').resource_count).to eq 1
    expect(d.get_node('pool3').resource_count).to eq 0

  end

  it 'takes staging and commit steps into account when run with 3 pools for 4 turns' do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 10, mode: :push, activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_node! Pool, name: 'pool3', activation: :automatic

    d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool2'

    d.add_edge! Edge, name: 'edge2', from: 'pool2', to: 'pool3'


    d.run!(4)

    expect(d.get_node('pool1').resource_count).to eq 6
    expect(d.get_node('pool2').resource_count).to eq 1
    expect(d.get_node('pool3').resource_count).to eq 3


  end

  it 'runs with a source and a pool and have the expected amount of resources at the end' do

    d=Diagram.new 'simple'


    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
    }

    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run!(10)

    expect(d.get_node('deposit').resource_count).to eq 10

  end

  it 'can be run until a given condition is true' do
    d=Diagram.new 'simple'
    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }
    d.add_node! Source, {
        :name => 'source'
    }
    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run_while! { d.get_node('deposit').resource_count < 10 }
    expect(d.get_node('deposit').resource_count).to eq 10

  end

  it 'aborts after 999 turns as a safeguard against infinite loops given as stopping condition' do

    # you can create a subclass for diagram (I recommend the name UnsafeDiagram) in
    # order to allow arbitrarily long execution loops

    d=Diagram.new 'simple'

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }
    d.add_node! Source, {
        :name => 'source'
    }
    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run_while! { true == true }

    #not hanging on forever is the success condition.
    expect(d.get_node('deposit').resource_count).to eq 999

  end

  it 'aborts after specified turns as a safeguard against infinite loops given as stopping condition' do

    d=Diagram.new 'simple'
    d.max_iterations=9

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }
    d.add_node! Source, {
        :name => 'source'
    }
    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run_while! { true == true }

    #not hanging on forever is the success condition.
    expect(d.get_node('deposit').resource_count).to eq 9

  end

  it "does not raise errors when active pushes or pulls are not possible" do

    pending "active pushes from an empty node should not cause errors and neither should active pulls from empty nodes"

  end

  it "correctly carries typed tokens from suitable nodes via suitable edges" do

    pending 'should i subclass edge so as to place type-specific behaviour elsewhere?'

  end

  it "should raise an error in case users try to access a node that doesn't exist" do

    p = Diagram.new('get invalid node')

    p.add_node! Source, name: 'source'

    p.add_node! Pool, name: 'pool1'

    p.add_edge! Edge, {
        name: 'connector1',
        from: 'source',
        to: 'pool1'
    }

    # use curly brackets instead of parentheses here.
    expect{ p.get_node('pool')}.to raise_error RuntimeError

  end

  it "runs with typed nodes connected by typeless edges" do

    p = Diagram.new('one source one pool typed')

    p.add_node!(Source, name: 'source', :types => [Green])
    p.add_node!(Pool, name: 'pool1', :types => [Green, Red])
    p.add_edge!(Edge, name: 'connector1', from: 'source', to: 'pool1')

    p.run!(5)

    expect(p.get_node('pool1').resource_count(Green)).to eq 5
    expect(p.get_node('pool1').resource_count(Red)).to eq 0

  end

  it "allows untyped nodes to receive typed resources sent to them via untyped edges" do

    p = Diagram.new 'balls'

    p.add_node!(Source, name: 'source', :types => [Football])

    p.add_node!(Pool, name: 'pool1')

    p.add_edge!(Edge, name: 'connector1', from: 'source', to: 'pool1')

    p.run!(5)

    expect(p.get_node('pool1').resource_count(Football)).to eq 5

  end

  it "allows untyped nodes to receive typed resources sent to them via typed edges" do

    p = Diagram.new 'fruits'

    #by declaring initial values, we're implicitly declaring types.
    p.add_node! Pool, name: 'pool1', initial_value:  { Peach => 20,Mango => 99 }

    p.add_node! Pool, name: 'pool2', activation: :automatic

    p.add_edge!(Edge, name: 'connector1', from: 'pool1', to: 'pool2', types: [Peach])

    p.run!(5)

    expect(p.get_node('pool1').resource_count(Peach)).to eq 15
    expect(p.get_node('pool1').resource_count(Mango)).to eq 99
    expect(p.get_node('pool2').resource_count(Peach)).to eq 5

  end

  it "should execute start nodes only once" do

    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 'source',
        :activation => :start
    }

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run!(10)


    expect(d.get_node('deposit').resource_count).to eq  1

  end

  it 'must not run disabled nodes from the beginning' do

    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.get_node('source').attach_condition(false)

    d.run!(10)

    expect(d.resource_count).to eq 0
    expect(d.get_node('deposit').resource_count).to eq 0

  end

  it 'must not run disabled nodes at some point' do

    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.get_node('source').attach_condition(lambda {d.get_node('deposit').resource_count < 3})

    d.run!(10)

    expect(d.resource_count).to eq 3
    expect(d.get_node('deposit').resource_count).to eq 3

  end

  it 'must have both sides of an edge enabled to run' do
    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.get_node('deposit').attach_condition( lambda do
      d.get_node('deposit').resource_count < 3
    end)

    d.run!(10)

    expect(d.resource_count).to eq 3
    expect(d.get_node('deposit').resource_count).to eq 3

  end

  it 'should make triggers trig!' do
    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.get_node('deposit').attach_trigger([lambda { d.get_node('deposit').resource_count === 3 }, d.get_node('source')])

    d.run!(10)

    expect(d.resource_count).to eq 11
    expect(d.get_node('deposit').resource_count).to eq 11

  end

  it 'should make triggers trig! more than once' do
    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 's1'
    }

    d.add_node! Pool, {
        :name => 'd1',
        :initial_value => 0
    }


    d.add_node! Source, {
        :name => 's2',
        :activation => :passive
    }

    d.add_edge! Edge, {
        :name => 'c1',
        :from => 's1',
        :to => 'd1'
    }

    d.add_node! Pool, {
        :name => 'd2',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'c2',
        :from => 's2',
        :to => 'd2'
    }


    d.get_node('d1').attach_trigger([lambda { d.get_node('d1').resource_count > 3 }, d.get_node('s1')])
    d.get_node('d1').attach_trigger([lambda { d.get_node('d1').resource_count > 3 }, d.get_node('s2')])
    #d.extend(Verbose)
    d.run!(6)

    expect(d.resource_count).to eq 10
    expect(d.get_node('d1').resource_count).to eq 8
    expect(d.get_node('d2').resource_count).to eq 2

  end


  it 'should make triggers trig! more than once with instant_resource_count' do
    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 's1'
    }

    d.add_node! Pool, {
        :name => 'd1',
        :initial_value => 0
    }


    d.add_node! Source, {
        :name => 's2',
        :activation => :passive
    }

    d.add_edge! Edge, {
        :name => 'c1',
        :from => 's1',
        :to => 'd1'
    }

    d.add_node! Pool, {
        :name => 'd2',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'c2',
        :from => 's2',
        :to => 'd2'
    }


    d.get_node('d1').attach_trigger([lambda { d.get_node('d1').instant_resource_count > 3 }, d.get_node('s1')])
    d.get_node('d1').attach_trigger([lambda { d.get_node('d1').instant_resource_count > 3 }, d.get_node('s2')])
    #d.extend(Verbose)
    d.run!(6)

    expect(d.resource_count).to eq 12
    expect(d.get_node('d1').resource_count).to eq 9
    expect(d.get_node('d2').resource_count).to eq 3

  end

end
