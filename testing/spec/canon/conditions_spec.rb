require_relative '../spec_helper'

describe 'Nodes that can be given conditions' do

  it 'does not run disabled nodes from the beginning' do

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

    d.get_node('source').attach_condition{ false }

    d.run!(10)

    expect(d.resource_count).to eq 0
    expect(d.get_node('deposit').resource_count).to eq 0

  end

  it 'must not run disabled nodes at some point' do

    #não entendi pra que serve esse teste

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

    d.get_node('source').attach_condition { d.get_node('deposit').resource_count < 3 }

    d.run!(10)

    expect(d.resource_count).to eq 3
    expect(d.get_node('deposit').resource_count).to eq 3

  end

  it 'runs when both ends (of an edge) are enabled' do

    d= Diagram.new 'simple'

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

    d.get_node('deposit').attach_condition { d.get_node('deposit').resource_count < 3 }

    d.run!(10)

    # expect(d.resource_count).to eq 3
    expect(d.get_node('deposit').resource_count).to eq 3

  end


end