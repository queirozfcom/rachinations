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

    c.attach_edge(double(:from => c, :to => double()))

    c.attach_edge(double(:from => double(), :to => c))

  end


  describe '#trigger!' do

    context 'simple' do

      before(:each) do

        @c = Converter.new name: 'c'
        @edge_in = instance_double(Edge, from: double(), to: @c, label: 1, pull_expression: proc{true==true})
        @edge_out = instance_double(Edge, from: @c, to: double(), label: 1,push_expression: proc{true==true})
        @c.attach_edge!(@edge_in).attach_edge!(@edge_out)

      end

      it 'asks incoming edges for their pull_expressions' do

        expect(@edge_in).to receive(:pull_expression)
        expect(@edge_in).to receive(:pull!)
        @edge_out.as_null_object
        @c.trigger!

      end

      it "doesn't ping outgoing edges if incoming edge cannot pull" do

        expect(@edge_in).to receive(:pull_expression).and_raise(RuntimeError)
        expect(@edge_out).not_to receive(:push!)

        @c.trigger!

      end

    end

    context 'when pull_any' do

      before(:each) do

        @c = Converter.new name: 'c', mode: :pull_any
        @edge_in = instance_double(Edge, from: double(), to: @c,label:1)
        @edge_out = instance_double(Edge, from: @c, to: double(),label:1)
        @c.attach_edge!(@edge_in).attach_edge!(@edge_out)

      end

      it 'does not push when resource contributions are not met' do

        expect(@edge_in).to receive(:pull_expression).and_return(proc{true})

        expect(@edge_in).to receive(:pull!)

        expect(@edge_out).not_to receive(:push_expression)

        expect(@c).to receive(:in_conditions_met?).and_return(false)

        @c.trigger!


      end

      it 'does cause a push when resource contribution is met, even if across turns' do
        expect(@edge_in).to receive(:pull_expression).and_raise(RuntimeError)

        expect(@edge_in).not_to receive(:pull!)

        expect(@c).to receive(:in_conditions_met?).and_return(true)

        expect(@edge_out).to receive(:test_push?).and_return(true)
        expect(@edge_out).to receive(:push_expression).and_return(proc{true})
        expect(@edge_out).to receive(:push!)

        @c.trigger!
      end

    end

    context 'when pull_all' do

      before(:each) do
        @c = Converter.new name: 'c', mode: :pull_all
        @edge_in = instance_double(Edge, from: double(), to: @c, label:1,pull_expression: proc{true})
        @edge_in2 = instance_double(Edge, from: double(), to: @c, label: 1,pull_expression: proc{true})
        @edge_out = instance_double(Edge, from: @c, to: double(), label: 1,push_expression: proc{true})
        @c.attach_edge!(@edge_in).attach_edge!(@edge_in2).attach_edge!(@edge_out)
      end


      it 'pushes and pulls if all edges (incoming and outgoing) can push and pull, respectively' do

        expect(@edge_in).to receive(:test_pull?).with(require_all:true).and_return(true)
        expect(@edge_in).to receive(:pull!)

        expect(@edge_in2).to receive(:test_pull?).with(require_all:true).and_return(true)
        expect(@edge_in2).to receive(:pull!)

        expect(@edge_out).to receive(:test_push?).with(require_all:true).and_return(true)
        expect(@edge_out).to receive(:push!)


        @c.trigger!

      end


      it 'does not pull or push if at least one incoming edge cannot pull ' do

        # they are shuffled and we stop sending test_ping? to edges
        # once one has returned false. Therefore we do not know which
        # edges will receive the message so we have to allow all to.

        allow(@edge_in).to receive_messages(:test_pull? => false)
        allow(@edge_in2).to receive_messages(:test_pull? => false)
        allow(@edge_out).to receive_messages(:test_push? => false)

        # but none outgoing will get pinged
        expect(@edge_in).not_to receive(:pull!)
        expect(@edge_in2).not_to receive(:pull!)
        expect(@edge_out).not_to receive(:push!)


        @c.trigger!

      end

      it 'also does not pull or push if at least one outgoing edge cannot push' do

      end

    end

  end

  describe '#put_resource!' do

    before(:each) do
      @c = Converter.new name: 'c'
      @edge_in = instance_double(Edge, from: double(), to: @c, label: 1)
      @edge_out = instance_double(Edge, from: @c, to: double(), label: 1)
      @c.attach_edge!(@edge_out)
      @c.attach_edge!(@edge_in)
    end

    it 'does not ping incoming edges' do

      expect(@edge_in).not_to receive(:test_pull?)
      expect(@edge_out).to receive(:push_expression).and_return(proc{true})
      @edge_out.as_null_object
      @c.put_resource!(double(), @edge_in)
    end


  end

  describe '#take_resource!' do

    before(:each) do

      # TODO
    end

    it 'something'  do

    end


  end

  describe '#attach_edge' do

    before(:each) do
      @c = Converter.new name: 'c'
      @e = Edge.new name: 'e', from: double(), to: @c

    end

    it 'adds attached edge to resources_contributed hash' do

      hsh = Hash.new

      expect(@c).to receive(:resources_contributed).and_return(hsh)

      expect(hsh).to receive(:store)

      @c.attach_edge!(@e)


    end

  end

end