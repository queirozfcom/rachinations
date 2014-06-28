require_relative 'spec_helper'

describe Converter do

  it 'should be created with name as single argument' do

    expect { Converter.new name: 'foo' }.not_to raise_error

  end

  it 'should allow to be inserted in a diagram' do

    pending 'not yet'

    d = Diagram.new 'd'

    d.add_node! Converter, name: 'conv'

    expect(d.get_node('conv')).to be_a Converter

  end

  it 'should be connected to one edge in and one edge out' do
    skip 'I think this should be an integration test since it involves other classes.'
  end

  it 'should allow many egdes in and one edge out, should wait for all need of entering edges to be fulfilled to create out' do
    skip 'Converter not Working yet'
  end

  it 'should generate the resource that the link needs ' do
    skip 'Converter not Working yet'
  end

  it 'should understand the ALL mode for its input, exit is always all' do
    skip 'Converter not Working yet'
  end


end