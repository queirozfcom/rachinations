require_relative 'spec_helper'

describe Diagram do

  before :all do
    puts "This is Diagram RSpec"
  end

  it 'can be empty' do
    d = Diagram.new 'empty'
    expect(d.name).to eq 'empty'
  end

  it 'should be created with a source and a pool and run n times' do

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

    d.run!(10)

  end


  it 'should run with a source and a pool and have the expected amount of resources at the end' do

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
    d.get_node('deposit').resource_count.should == 10

  end

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
