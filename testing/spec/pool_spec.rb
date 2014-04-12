require 'rspec'
require_relative '../../domain/diagrams/diagram'

require 'coveralls'
Coveralls.wear!

describe Pool do

  it 'can be created with just a name attribute' do
    obj = Pool.new name: 'some name'
  end

  it 'knows its name' do

    obj = Pool.new name: 'foo'

    expect(obj).to respond_to :name
    expect(obj.name).to eq 'foo'
  end

  it 'cannot have its name set after creation'  do

    obj = Pool.new name: 'bar'
    expect(obj).not_to respond_to :name=

  end

  it 'supports simple integers as resources'    do

    obj = Pool.new name: 'baz', initial_value: 10

  end

  it 'should support types during instantiation' do

    #note that there is no check whether this class is suited to play the role of a Token...

    foo = Class.new
    Object.const_set(:Foo,foo)


    obj = Pool.new name: 'qux',types:[Foo]


  end

  it 'should perform a pull_any operation' do
    # this is because

    true.should == false
  end

  it 'should perform a pull_all operation' do

    true.should == false
  end

  it 'should perform a push_any operation'do

  end

  it 'should perform a push all operation' do

    true.should == false
  end


  it 'can be set to automatic upon instantiation' do

    true.should == false
  end

  it 'can be executed on an individual basis, i.e. not via calling diagram.run! but a method on the pool itself' do

    true.should == false
  end

  it 'knows how many resources it\'s got' do

    true.should == false
  end






end