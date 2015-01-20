require_relative 'spec_helper'


describe NonDeterministicDiagram do

  it "runs noreporting" do
    generator = NonDeterministicDiagram.new('1to2')
    #generator.extend(Verbose)

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

    generator.run!(100) #should be enough

    # don´t know what to test...
    expect(generator.get_node('g3').resource_count).to eq 5

  end

  include DSL

  it ' makes a train run' do


    d = NonDeterministicDiagram.new 'dia'

    d.add_node! Pool, {
        name: 'p1',
        mode: :push_any,
        activation: :automatic,
        initial_value: 8
    }

    d.add_node! Pool, {
        name: 'p2',
        mode: :push_any,
        activation: :automatic
    }

    d.add_node! Pool, {
        name: 'p3',
        mode: :push_any,
        activation: :automatic
    }

    d.add_node! Pool, {
        name: 'p4',
        mode: :push_any,
        activation: :automatic
    }

    d.add_edge! Edge, {
        name: 'e1',
        from: 'p1',
        to: 'p2'
    }
    d.add_edge! Edge, {
        name: 'e2',
        from: 'p2',
        to: 'p3'
    }
    d.add_edge! Edge, {
        name: 'e3',
        from: 'p3',
        to: 'p4'
    }


    d.run!(200)

    expect(d.get_node('p1').resource_count).to eq 0
    expect(d.get_node('p2').resource_count).to eq 0
    expect(d.get_node('p3').resource_count).to eq 0
    expect(d.get_node('p4').resource_count).to eq 8

  end


end
