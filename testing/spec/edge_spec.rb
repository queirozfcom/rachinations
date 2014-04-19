require_relative 'spec_helper'

describe Edge do

  it 'can be created' do

    # i only want to test edge methods so I'll use a mock object and stub the method I need
    # to call, namely :name.

    from = Object.stub(:name).and_return('node1')
    to = Object.stub(:name).and_return('node2')

    edge = Edge.new name: 'edge1', from: from ,to: to

  end

  it "is created with the expected defaults in case attributes aren't provided" do
    edge = Edge.new name:'edge', from: Object.new, to: Object.new

    expect(edge.label).to eq 1
    expect(edge.types).to eq []

  end

  it 'can be created with types' do

    from = Object.stub(:name).and_return('node1')
    to = Object.stub(:name).and_return('node2')

    edge = Edge.new name:'edge1', from: from,to: to, types: [Blue, Black]


    expect(edge.name).to eq('edge1')
    expect(edge.from).to eq(from)
    expect(edge.to).to eq(to)
    expect(edge.support?(Blue)).to be true
    expect(edge.support?(Black)).to be true

  end

  it 'can be assigned an integer label' do

    from = Object.stub(:name).and_return('node1')
    to = Object.stub(:name).and_return('node2')

    edge = Edge.new name:'edge1', from: from,to: to, types: [Blue, Red], label: 5

    expect(edge.name).to eq 'edge1'

    expect(edge.from).to eq from
    expect(edge.to).to eq to

    expect(edge.support?(Blue)).to be true
    expect(edge.support?(Black)).not_to be true
    expect(edge.support?(Red)).to be true

    expect(edge.label).to be 5

  end


end
