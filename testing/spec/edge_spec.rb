require_relative 'spec_helper'

describe Edge do

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

end

describe '#ping!' do

  it "is false when node types don't match" do

    node1 = double(enabled?: true, types: [Peach])
    node2 = double(enabled?: true, types: [Mango])

    allow(node1).to receive(:remove_resource!).and_raise NoElementsFound

    e = Edge.new name: 'e', from: node1, to: node2

    expect(e.ping!).to eq false

  end

  it 'is false when edge is typed but no match was found given node types' do

    node1 = double(enabled?: true, types: [Peach])
    node2 = double(enabled?: true, types: [Mango])

    allow(node1).to receive(:remove_resource!).and_raise NoElementsFound

    e = Edge.new name: 'e', from: node1, to: node2, types: [Football, Baseball]

    expect(e.ping!).to eq false


  end

  it 'is false when fewer resources than required were moved' do

    node1 = double(enabled?: true, types: [])
    node2 = double(enabled?: true, types: [])

    $count = 0

    expect(node1).to receive(:remove_resource!).exactly(4).times {

      $count += 1

      if $count == 4
        raise NoElementsFound.new
      else
        double()
      end

    }

    expect(node2).to receive(:add_resource!).exactly(3).times

    e = Edge.new name: 'e', from: node1, to: node2, label: 5

    expect(e.ping!).to eq false
  end

  it 'is true when all required resources were moved' do

    node1 = double(enabled?: true, types: [])
    node2 = double(enabled?: true, types: [])

    e = Edge.new name: 'foo', from: node1, to: node2, label: 10

    expect(node1).to receive(:remove_resource!).exactly(10).times.and_return(double())
    expect(node2).to receive(:add_resource!).exactly(10).times

    expect(e.ping!).to eq true

  end

  describe '#test_ping?' do
    before(:each) do
      @strategy=double(:get_condition => proc {})
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

end
