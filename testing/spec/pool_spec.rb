require_relative 'spec_helper'

describe Pool do

  it 'is created with just a name attribute and has the expected default attributes' do
    obj = Pool.new name: 'some name'

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

    p=Pool.new name: 'baz', initial_value: 10

    expect(p.resource_count).to eq 10


  end

  it 'supports types during instantiation' do

    #note that there is no check whether this class is suited to play the role of a Token...

    expect{Pool.new name: 'qux', types: [Peach]}.not_to raise_error

  end

  it "knows that having initial values for some types implies having those types even if the user didn't explicitly added them" do

     p = Pool.new name:'foo',initial_values: {Peach =>6,Mango=>7}

     expect(p.support?(Peach)).to eq true
     expect(p.support?(Mango)).to eq true

  end



  it 'performs a pull_any operation' do
    skip
  end

  it 'performs a pull_all operation' do
    skip
  end

  it 'performs a push_any operation' do
    skip
  end

  it 'performs a push all operation' do
    skip
  end


  it 'can be set to automatic upon instantiation' do
    Pool.new name: 'bar', activation: :automatic
  end

  it 'can be executed on an individual basis, i.e. not via calling diagram.run! but a method on the pool itself' do
    skip 'how do i test this without bringing the whole diagram in?'
  end

  it "knows how many resources it's got" do

    p=Pool.new name: 'foo', initial_value: 82

    expect(p.resource_count).to eq 82

  end

  it 'knows how many resources were added' do

    p1 = Pool.new name: 'typed pool'
    5.times { p1.add_resource! Token.new }
    2.times { p1.remove_resource! }


    expect(p1.resources_added).to eq 5
    expect(p1.resources_removed).to eq 2
    expect(p1.resource_count).to eq 3

  end


  it 'knows that Token and subclasses are not the same thing' do

    #i need to check the types very precisely

    Object.const_set(:Subtype, Class.new(Token))

    p1 = Pool.new name: 'typed pool', initial_value: {Subtype => 10}

    #if nothing is given, just return everything
    expect(p1.resource_count).to eq 10

    expect { p1.resource_count(Token) }.to raise_error UnsupportedTypeError

    p2 = Pool.new name: 'untyped pool'

    p2.add_resource! Token.new
    p2.add_resource! Token.new
    p2.add_resource! Token.new

    p2.add_resource! Subtype.new
    p2.add_resource! Subtype.new

    expect(p2.resource_count(Token)).to eq 3
    expect(p2.resource_count(Subtype)).to eq 2

  end

  it 'is enabled by default' do

    p2 = Pool.new name: 'simpler yet'

    expect(p2.enabled?).to eq true

  end

  describe '#resource_count' do

    before(:each) do
      @untyped = Pool.new name: 'p', initial_value: 10
      @typed = Pool.new name: 'p',initial_value: {Peach => 10,Lemon =>5}
    end

    it 'works with no params' do
      expect(@typed.resource_count).to eq 15
      expect(@untyped.resource_count).to eq 10
    end

    it 'raises an error when it is asked about an unsupported type and it is typed' do
      expect{@typed.resource_count(Mango)}.to raise_error UnsupportedTypeError
    end

    it 'just returns zero if it is untyped and it is asked about a type'do
      expect(@untyped.resource_count(Mango)).to eq 0
    end

    it 'otherwise works with one type param' do
      expect(@typed.resource_count(Peach)).to eq 10
    end

    it 'accepts a single block' do
      expect(@typed.resource_count {|r| r.is_type? Peach }).to eq 10
      expect(@untyped.resource_count{true}).to eq 10

      # if user sent a block. he prolly knows what he's doing so no errors.
      expect(@typed.resource_count{|r| r.is_type? Football}).to eq 0
    end

    it 'errors if given both a type and a block' do
      expect{@typed.resource_count(Peach) {|r| r.is_type? Mango}}.to raise_error ArgumentError
    end

    it 'also errors if some other nonsense is passed' do
      expect{@typed.resource_count(Hash.new)}.to raise_error ArgumentError
      expect{@untyped.resource_count('Foo')}.to raise_error ArgumentError
    end

  end

end