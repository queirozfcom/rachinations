require 'rspec'
require_relative '../../domain/diagrams/diagram'

describe Edge do

  it 'can be created' do

    # i only want to test edge methods so I'll use a mock object and stub the method I need
    # to call, namely :name.

    from = Object.stub(:name).and_return('node1')
    to = Object.stub(:name).and_return('node2')

    edge = Edge.new name: 'edge1', from: from ,to: to

  end


  it 'can be created with types' do
    blue = Class.new(Token)
    black = Class.new(Token)

    from = Object.stub(:name).and_return('node1')
    to = Object.stub(:name).and_return('node2')

    edge = Edge.new name:'edge1', from: from,to: to, types: [blue, black]


    expect(edge.name).to eq('edge1')
    expect(edge.from).to eq(from)
    expect(edge.to).to eq(to)
    expect(edge.support?(blue)).to be true
    expect(edge.support?(black)).to be true

  end

  it 'can be assigned an integer label' do
    blue = Class.new(Token)
    Object.const_set(:Blue,blue)

    red = Class.new(Token)
    Object.const_set(:Red,red)

    green = Class.new(Token)
    Object.const_set(:Green,green)

    black = Class.new(Token)
    Object.const_set(:Black,black)

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
