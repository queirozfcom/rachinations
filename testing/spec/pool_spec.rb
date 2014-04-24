require_relative 'spec_helper'

describe Pool do

  it 'can be created with just a name attribute and have the expected default attributes' do
    obj = Pool.new name: 'some name'

    expect(obj.types).to eq []
    expect(obj.passive?).to eq true
    expect(obj.pull?).to eq true
    expect(obj.resource_count).to eq 0

  end

  it 'knows its name' do

    obj = Pool.new name: 'foo'

    expect(obj).to respond_to :name
    expect(obj.name).to eq 'foo'
  end

  it 'cannot have its name set after creation' do

    obj = Pool.new name: 'bar'
    expect(obj).not_to respond_to :name=

  end

  it 'supports simple integers as resources' do

    obj = Pool.new name: 'baz', initial_value: 10

  end

  it 'should support types during instantiation' do

    #note that there is no check whether this class is suited to play the role of a Token...

    foo = Class.new
    Object.const_set(:Foo, foo)


    obj = Pool.new name: 'qux', types: [Foo]


  end

  it 'should perform a pull_any operation' do
    pending
  end

  it 'should perform a pull_all operation' do
    pending
  end

  it 'should perform a push_any operation' do
    pending
  end

  it 'should perform a push all operation' do
    pending
  end


  it 'can be set to automatic upon instantiation' do
    Pool.new name: 'bar', activation: :automatic
  end

  it 'can be executed on an individual basis, i.e. not via calling diagram.run! but a method on the pool itself' do
    pending 'how do i test this without bringing the whole diagram in?'
  end

  it "knows how many resources it's got" do

    p=Pool.new name: 'foo', initial_value: 82

    expect(p.resource_count).to eq 82

  end

  it 'knows how many resources were added' do

    p1 = Pool.new name: 'typed pool'
    5.times {p1.add_resource! Token.new}
    2.times {p1.remove_resource!}


    expect(p1.resources_added).to eq 5
    expect(p1.resources_removed).to eq 2
    expect(p1.resource_count).to eq 3

  end


  it "knows that Token and subclasses are not the same thing" do

    #i need to check the types very precisely

    Object.const_set(:Subtype,Class.new(Token))

    p1 = Pool.new name: 'typed pool', initial_value: {Subtype => 10}

    #if nothing is given, just return everything
    expect{p1.resource_count}.not_to raise_error
    expect(p1.resource_count).to eq 10

    expect{p1.resource_count(Token)}.to raise_error UnsupportedTypeError

    p2 = Pool.new name: 'untyped pool'

    p2.add_resource! Token.new
    p2.add_resource! Token.new
    p2.add_resource! Token.new

    p2.add_resource! Subtype.new
    p2.add_resource! Subtype.new

    expect(p2.resource_count(Token)).to eq 3
    expect(p2.resource_count(Subtype)).to eq 2


end

end