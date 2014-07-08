require_relative 'spec_helper'

describe Converter do

  it 'is created with name as single argument' do

    expect { Converter.new name: 'foo' }.not_to raise_error

  end

  it 'is added into a diagram' do

    d = Diagram.new 'd'

    d.add_node! Converter, name: 'conv'

    expect(d.get_node('conv')).to be_a Converter

  end

  it 'is connected to one edge in and one edge out' do

    c = Converter.new name: 'c'

    c.attach_edge(double(:from => c))

    c.attach_edge(double(:to => double()))

  end

  it 'allows many edges in and one edge out, should wait for all need of entering edges to be fulfilled to create out' do
    skip 'Converter not Working yet'
  end

  describe '#trigger!' do

    it 'pings incoming nodes' do

      c = Converter.new name: 'c'

      edge_in = double(from: nil, to: c)

      c.attach_edge(edge_in)

      edge_out = double(from: c, to: nil)

      c.attach_edge(edge_out)

      expect(edge_in).to receive(:ping!)

      c.trigger!

    end

    it "pings outgoing edges iff incoming edge's ping! was successful " do
      # if and only if

      c1 = Converter.new name: 'c1'

      edge_in = double(from: nil, to: c1)

      edge_out = double(from: c1, to: nil)

      c1.attach_edge!(edge_in).attach_edge!(edge_out)

      expect(edge_in).to receive(:ping!).and_return(false)
      expect(edge_out).not_to receive(:ping!)

      c1.trigger!

      # now test the opposite

      c2 = Converter.new name: 'c2'

      edge_in = double(from: double(), to: c2)

      edge_out = double(from: c2, to: double())

      c2.attach_edge!(edge_in).attach_edge!(edge_out)

      expect(edge_in).to receive(:ping!).and_return(true)
      expect(edge_out).to receive(:ping!)

      c2.trigger!


    end

  end

  describe '#fire' do

    it 'sends resources when there is only one outgoing node' do

      c = Converter.new name: 'c'

      edge_in = double(from: double(), to: c)
      edge_out = double(from: c, to: double())

      expect(edge_out).to receive(:ping!)

      c.attach_edge!(edge_out).attach_edge!(edge_in)

      c.fire!

    end

    it 'requires push_all by default' do

      c = Converter.new name: 'c'

      edge_in = double(from:double(),to:c)

      edge_out1 = double(from: c, to: double())
      edge_out2 = double(from: c, to: double())
      edge_out3 = double(from: c, to: double())
      #
      # expect(edge_in).to receive(:test_ping)
      #
      # c.attach_edge!(edge_in).attach_edge!(edge_out1).attach_edge!(edge_out2).attach_edge!(edge_out3)



    end

  end

  it 'understands the ALL mode for its input, exit is always all' do
    skip 'Converter not Working yet'
  end


end