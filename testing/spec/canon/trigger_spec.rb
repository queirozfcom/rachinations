require_relative '../spec_helper'

describe 'triggers' do

  it 'makes triggers trig!' do
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

  it 'makes triggers trig! more than once' do
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

  it 'makes triggers trig! more than once with instant_resource_count' do
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