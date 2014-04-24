require_relative 'spec_helper'
require_relative '../../domain/modules/verbose'
require_relative '../../domain/diagrams/non_deterministic_diagram'


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

  generator.run!(100)

    # don´t know what to test...

  end

end
