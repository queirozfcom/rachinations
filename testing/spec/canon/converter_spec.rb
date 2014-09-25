require_relative '../spec_helper'

describe 'Converter canonical behavior' do

  it 'pulls_any' do

    d = Diagram.new 'foo'
    d.add_node! Pool, name: 'p9', initial_value: 9
    d.add_node! Pool, name: 'p0'
    d.add_node! Converter, name: 'c', mode: :pull_any, activation: :automatic
    d.add_edge! Edge, name: 'e1', from: 'p9', to: 'c'
    d.add_edge! Edge, name: 'e2', from: 'c', to: 'p0'

    c = d.get_node 'c'
    p0 = d.get_node('p0')
    p9 = d.get_node('p9')

    d.run!(5)

    expect(p0.resource_count).to eq 5
    expect(p9.resource_count).to eq 4

  end


  it 'pulls_any to two targets' do

    d = Diagram.new 'foo'
    d.add_node! Pool, name: 'p9', initial_value: 9
    d.add_node! Pool, name: 'p1'
    d.add_node! Pool, name: 'p2'
    d.add_node! Converter, name: 'c', mode: :pull_any
    d.add_edge! Edge, name: 'e1', from: 'p9', to: 'c'
    d.add_edge! Edge, name: 'e2', from: 'c', to: 'p1'
    d.add_edge! Edge, name: 'e3', from: 'c', to: 'p2'

    c = d.get_node 'c'
    p1 = d.get_node('p1')
    p2 = d.get_node('p2')
    p9 = d.get_node('p9')

    5.times { c.trigger! }

    # to unlock the resources
    p1.commit!
    p2.commit!
    p9.commit!

    expect(p1.resource_count).to eq 5
    expect(p2.resource_count).to eq 5
    expect(p9.resource_count).to eq 4

  end

  it 'pulls_any from two sources' do

    d = Diagram.new 'foo'
    d.add_node! Pool, name: 'p1', initial_value: 9
    d.add_node! Pool, name: 'p2', initial_value: 3
    d.add_node! Pool, name: 'p3'
    d.add_node! Pool, name: 'p4'
    d.add_node! Converter, name: 'c', mode: :pull_any
    d.add_edge! Edge, name: 'e1', from: 'p1', to: 'c'
    d.add_edge! Edge, name: 'e2', from: 'p2', to: 'c'
    d.add_edge! Edge, name: 'e3', from: 'c', to: 'p3'
    d.add_edge! Edge, name: 'e4', from: 'c', to: 'p4'

    c = d.get_node 'c'
    p1 = d.get_node('p1')
    p2 = d.get_node('p2')
    p3 = d.get_node('p3')
    p4 = d.get_node('p4')

    5.times { c.trigger! }

    # to unlock the resources
    p1.commit!
    p2.commit!
    p3.commit!
    p4.commit!

    expect(p1.resource_count).to eq 4
    expect(p2.resource_count).to eq 0
    expect(p3.resource_count).to eq 3
    expect(p4.resource_count).to eq 3

  end

  it "pulls_all from a single source" do
    d = Diagram.new 'foo'
    d.add_node! Pool, name: 'p1', initial_value: 9
    d.add_node! Pool, name: 'p2'
    d.add_node! Converter, name: 'c', mode: :pull_all
    d.add_edge! Edge, name: 'e1', from: 'p1', to: 'c'
    d.add_edge! Edge, name: 'e2', from: 'c', to: 'p2'

    c = d.get_node 'c'
    p1 = d.get_node('p1')
    p2 = d.get_node('p2')

    5.times { c.trigger! }

    # to unlock the resources
    p1.commit!
    p2.commit!

    expect(p1.resource_count).to eq 4
    expect(p2.resource_count).to eq 5
  end

  it 'pulls_all from multiple sources' do
    d = Diagram.new 'foo'
    d.add_node! Pool, name: 'p1', initial_value: 9
    d.add_node! Pool, name: 'p2', initial_value: 3
    d.add_node! Pool, name: 'p3', initial_value: 5
    d.add_node! Pool, name: 'p4'
    d.add_node! Pool, name: 'p5'

    d.add_node! Converter, name: 'c', mode: :pull_all
    d.add_edge! Edge, name: 'e1', from: 'p1', to: 'c', label: 2
    d.add_edge! Edge, name: 'e2', from: 'p2', to: 'c'
    d.add_edge! Edge, name: 'e3', from: 'p3', to: 'c'
    d.add_edge! Edge, name: 'e4', from: 'c', to: 'p4'
    d.add_edge! Edge, name: 'e5', from: 'c', to: 'p5'

    c = d.get_node 'c'
    p1 = d.get_node('p1')
    p2 = d.get_node('p2')
    p3 = d.get_node('p3')
    p4 = d.get_node('p4')
    p5 = d.get_node('p5')

    5.times { c.trigger! }

    # to unlock the resources
    p1.commit!
    p2.commit!
    p3.commit!
    p4.commit!
    p5.commit!

    expect(p1.resource_count).to eq 3
    expect(p2.resource_count).to eq 0
    expect(p3.resource_count).to eq 2
    expect(p4.resource_count).to eq 3
    expect(p5.resource_count).to eq 3
  end

end