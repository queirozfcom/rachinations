require_relative 'spec_helper'
require_relative '../../domain/modules/diagrams/verbose'
require_relative '../../domain/diagrams/non_deterministic_diagram'
require_relative '../../dsl/dsl'


describe NonDeterministicDiagram do

  it "runs noreporting" do
    generator = NonDeterministicDiagram.new('1to2')
    #generator.extend(Verbose)

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

  generator.run!(100) #should be enough

    # don´t know what to test...
    expect(generator.get_node('g3').resource_count).to eq 5

  end

  include DSL

  it 'should make a train run' do
    n=non_deterministic_diagram 'test_diagram' do
      node 'p1', Pool, mode: :push, activation: :automatic, initial_value: 8
      node 'p2', Pool, mode: :push, activation: :automatic
      node 'p3', Pool, mode: :push, activation: :automatic
      node 'p4', Pool, mode: :push, activation: :automatic
      edge 'e1', Edge, 'p1', 'p2'
      edge 'e2', Edge, 'p2', 'p3'
      edge 'e4', Edge, 'p3', 'p4'
    end

    n.run!(200)

    expect(n.get_node('p4').resource_count).to eq 8

  end


end
