require_relative 'spec_helper'


describe Edge do

  describe '#initialize' do
    using NumberModifiers
    it 'can be created' do

      # i only want to test edge methods so I'll use a mock object and stub the method I need
      # to call, namely :name.

      from = double(:name => 'node1')

      to = double(:name => 'node2')

      edge = Edge.new name: 'edge1', from: from, to: to

    end

    it "is created with the expected defaults in case attributes aren't provided" do
      edge = Edge.new name: 'edge', from: Object.new, to: Object.new

      expect(edge.label).to eq 1
      expect(edge.types).to eq []


    end

    it 'can be created with types' do

      from = double(:name => 'node1')
      to = double(:name => 'node2')

      edge = Edge.new name: 'edge1', from: from, to: to, types: [Blue, Black]

      expect(edge.name).to eq('edge1')
      expect(edge.from).to eq(from)
      expect(edge.to).to eq(to)
      expect(edge.support?(Blue)).to be true
      expect(edge.support?(Black)).to be true

    end

    it 'can be assigned an integer label' do

      from = double(:name => 'node1')
      to = double(:name => 'node2')

      edge = Edge.new name: 'edge1', from: from, to: to, types: [Blue, Red], label: 5

      expect(edge.name).to eq 'edge1'

      expect(edge.from).to eq from
      expect(edge.to).to eq to

      expect(edge.support?(Blue)).to be true
      expect(edge.support?(Black)).not_to be true
      expect(edge.support?(Red)).to be true

      expect(edge.label).to be 5

    end


    it 'can be assigned a percent label' do

      from = double(:name => 'node1')
      to = double(:name => 'node2')

      edge = Edge.new name: 'edge1', from: from, to: to, types: [Blue, Red], label: 50.percent

    end

  end

  describe '#test_ping?' do
    before(:each) do
      @strategy=double(:condition => proc {})
      @to = instance_double(ResourcefulNode, :disabled? => false, :types => double())
    end

    context 'when require_all' do

      it 'is false when no resources can pass' do
        from = instance_double(ResourcefulNode, :resource_count => 0, :disabled? => false)

        edge = Edge.new :name => 'e', :from => from, :to => @to
        expect(edge).to receive(:strategy).and_return(@strategy)
        expect(edge.test_ping?(true)).to eq false

      end

      it 'is false when some but not all required resources can pass' do
        from = instance_double(ResourcefulNode, :resource_count => 5, :disabled? => false)

        edge = Edge.new :name => 'e', :from => from, :to => @to, :label => 8
        expect(edge).to receive(:strategy).and_return(@strategy)
        expect(edge.test_ping?(true)).to eq false
      end

      it 'is true when the exact number of required resources are available to be moved' do
        from = instance_double(ResourcefulNode, :resource_count => 8, :disabled? => false)

        edge = Edge.new :name => 'e', :from => from, :to => @to, :label => 8
        expect(edge).to receive(:strategy).and_return(@strategy)
        expect(edge.test_ping?(true)).to eq true
      end

      it 'is true when the more resources than required are available to be moved' do
        from = instance_double(ResourcefulNode, :resource_count => 3, :disabled? => false)

        edge = Edge.new :name => 'e', :from => from, :to => @to, :label => 2
        expect(edge).to receive(:strategy).and_return(@strategy)
        expect(edge.test_ping?(true)).to eq true
      end

    end

    context 'when not require_all' do

      it 'is false when no resources are available at all' do
        from = instance_double(ResourcefulNode, :resource_count => 0, :disabled? => false)

        edge = Edge.new :name => 'e', :from => from, :to => @to
        expect(edge).to receive(:strategy).and_return(@strategy)
        expect(edge.test_ping?(false)).to eq false
      end

      it 'is true if at least one resource is available' do
        from = instance_double(ResourcefulNode, :resource_count => 1, :disabled? => false)

        edge = Edge.new :name => 'e', :from => from, :to => @to, :label => 8
        expect(edge).to receive(:strategy).and_return(@strategy)
        expect(edge.test_ping?(false)).to eq true
      end

    end

  end

  describe '#pull_expression' do

    before(:each) do
      @e = Edge.new name: 'e', from: double(), to: double()

      @strat = instance_double(ValidTypes)
      allow(@e).to receive(:strategy).and_return(@strat)
    end

    it 'forwards the call to a strategy' do
      blk=proc { |r| true }
      expect(@strat).to receive(:pull_condition).and_return(blk)
      @e.pull_expression
    end

  end

  describe '#push_expression' do
    before(:each) do
      @e = Edge.new name: 'e', from: double(), to: double()

      @strat = instance_double(ValidTypes)
      allow(@e).to receive(:strategy).and_return(@strat)
    end

    it 'forwards the call to a strategy' do
      blk=proc { |r| true }
      expect(@strat).to receive(:push_condition).and_return(blk)
      received_blk = @e.push_expression
      expect(received_blk).to be blk

    end
  end

  describe '#pull!' do

    context 'when edge has label 1' do

      before(:each) do
        @p1 = instance_double(Node, types: [], enabled?: true)
        @p2 = instance_double(Node, types: [], enabled?: true)
        @e = Edge.new name: 'e', from: @p1, to: @p2
      end

      it 'sends take_resource! with a block to to_node' do


      end

      it 'returns a resource in case it succeeded' do

      end

      it 'raises an exception if it cannot pull the one resource' do

      end

    end

    context 'when edge has label greater than 1' do

      it 'sends #get_block to self before pulling anything each time' do

      end

      it 'sends #take_resource! with a block from node as many times as it has' do
        # as many times as the label tells it to

      end

      it 'raises no exception if at least one resource (but not all) got pulled' do
        # because the semantics of a label is 'at most' that many resources
        # if not all could be pulled, it's not an error.
      end

      it 'raises exception if no resources could be pulled' do

      end

    end

    it 'does not send put_resource! to the caller' do
      # it merely returns the resource

    end


  end

  describe '#push!' do


    context 'when edge has label 1' do

      before(:each) do
        @p1 = instance_double(Node, name: 'n', types: [], enabled?: true)
        @p2 = instance_double(Node, name: 'n2', types: [], enabled?: true)
        @e = Edge.new name: 'e', from: @p1, to: @p2
      end
      it 'sends put_resource! to to_node' do
        # passing the same parameter it was given by the caller
        res = instance_double(Token, type: Token)
        expect(@p2).to receive(:put_resource!)
        @e.push!(res)

      end

      it 'raises an exception if the push was unsuccessful' do
        # wrap the exception raised by to node or let it bubble up?
      end


    end


  end

  context 'general tests' do



  end

  context 'specific features' do

  end


end
