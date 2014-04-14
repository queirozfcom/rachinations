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

  end

  it "runs correctly for 2 turns with two pools using PULL and there's the correct amount of resources at the end" do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 5

    d.add_node! Pool, name: 'pool2', activation: :automatic

    d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

    d.run!(2)

    expect(d.get_node('pool1').resource_count).to eq 3
    expect(d.get_node('pool2').resource_count).to eq 2

  end

  it "runs correctly for two turns with two pools using PUSH and there's the correct amount of resources at the end" do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 5, mode: :push, activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

    d.run!(2)

    expect(d.get_node('pool1').resource_count).to eq 3
    expect(d.get_node('pool2').resource_count).to eq 2

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

  # it 'should run with a source and a pool and have the expected amount of resources at the end' do
  #
  #   d=Diagram.new 'simple'
  #
  #
  #   d.add_node! Source, {
  #   :name => 'source'
  #   }
  #
  #   d.add_node! Pool, {
  #       :name => 'deposit',
  #   }
  #
  #   d.add_edge! Edge, {
  #       :name => 'connector',
  #       :from => 'source',
  #       :to => 'deposit'
  #   }
  #
  #   d.run!(10)
  #   d.get_node('deposit').resource_count.should == 10
  #
  # end

  #it 'should allow the creation of a simple source-pool diagram and run while a condition is true' do
  #  d=Diagram.new 'simple'
  #  d.add_node! Pool, {
  #      :name => 'deposit',
  #      :initial_value => 0
  #  }
  #  d.add_node! Source, {
  #      :name => 'source'
  #  }
  #  d.add_edge! Edge, {
  #      :name => 'connector',
  #      :from => 'source',
  #      :to => 'deposit'
  #  }
  #  d.run_while! { d.get_node('deposit').resource_count < 10 }
  #  d.get_node('deposit').resource_count.should == 10
  #end


end
