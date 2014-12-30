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

    expect { Pool.new name: 'qux', types: [Peach] }.not_to raise_error

  end

  it "knows that having initial values for some types implies having those types even if the user didn't explicitly added them" do

    p = Pool.new name: 'foo', initial_values: {Peach => 6, Mango => 7}

    expect(p.support?(Peach)).to eq true
    expect(p.support?(Mango)).to eq true

  end

  it 'can be set to automatic upon instantiation' do
    Pool.new name: 'bar', activation: :automatic
  end

  it 'knows how many resources were added' do

    p1 = Pool.new name: 'typed pool'
    5.times { p1.put_resource! Token.new }
    p1.unlock_resources!
    2.times { p1.take_resource! }


    expect(p1.resources_added).to eq 5
    expect(p1.resources_removed).to eq 2
    expect(p1.resource_count).to eq 3

  end


  it 'is enabled by default' do

    p2 = Pool.new name: 'simpler yet'

    expect(p2.enabled?).to eq true

  end

  describe '#resource_count' do

    before(:each) do
      @untyped = Pool.new name: 'p', initial_value: 10
      @typed = Pool.new name: 'p', initial_value: {Peach => 10, Lemon => 5}
    end

    it 'works with no params' do
      expect(@typed.resource_count).to eq 15
      expect(@untyped.resource_count).to eq 10
    end

    it 'raises an error when it is asked about an unsupported type and it is typed' do
      expect { @typed.resource_count(type:Mango) }.to raise_error UnsupportedTypeError
    end

    it 'just returns zero if it is untyped and it is asked about a type' do
      expect(@untyped.resource_count(type:Mango)).to eq 0
    end

    it 'otherwise works with one type param' do
      expect(@typed.resource_count(type:Peach)).to eq 10
    end

    it 'accepts a single block' do
      expect(@typed.resource_count(expr: proc{|r| r.is_type? Peach } ) ).to eq 10
      expect(@untyped.resource_count( expr: proc{true})).to eq 10

      # if user sent a block. he prolly knows what he's doing so no errors.
      expect(@typed.resource_count(expr: proc{|r| r.is_type? Football })).to eq 0
    end

    it 'errors if given both a type and a block' do
      expect { @typed.resource_count(type:Peach,expr: proc{ |r| r.is_type? Mango } )}.to raise_error ArgumentError
    end

    it 'also errors if some other nonsense is passed' do
      expect { @typed.resource_count(Object.new) }.to raise_error ArgumentError
      expect { @untyped.resource_count('Foo') }.to raise_error ArgumentError
    end

  end

  describe '#take_resource!' do


  end

  describe '#put_resource!' do
    before(:each) do
      @p = Pool.new name: 'p'
      @res = instance_double(Token, lock!: @res, :unlocked? => true)
    end
    it 'blocks the resource upon receiving it' do

      expect(@res).to receive(:lock!)

      @p.put_resource!(@res)

    end

    it 'adds the resource to the store' do
      bag_dbl = instance_double(ResourceBag)
      expect(@p).to receive(:resources).and_return(bag_dbl)
      expect(bag_dbl).to receive(:add!)

      @p.put_resource!(Token.new)
    end

    it 'fires triggers' do
      expect(@p).to receive(:fire_triggers!)
      @p.put_resource!(Token.new)
    end

  end

  describe '#trigger!' do


    context 'when :push_any' do

      before(:each) do

        @p = Pool.new name: 'p', mode: :push_any

        @e = instance_double(Edge, from: @p, to: double(), label: 1)
        allow(@e).to receive_messages([:push!])

        @p.attach_edge!(@e)

      end

      it 'asks outgoing edges for blocks' do

        expect(@e).to receive(:push_expression).and_return(proc { |r| true == true })

        @p.trigger!

      end

      it 'removes resources from self if given a suitable block' do
        expect(@e).to receive(:push_expression).and_return(proc { |r| true })

        expect(@p).to receive(:remove_resource!)

        @p.trigger!

      end

      it 'calls push! on edge if it succeeded in removing from self the needed resource for that edge' do

        expect(@e).to receive(:push_expression).and_return( proc{ true==true } )

        res = instance_double(Token)

        expect(@p).to receive(:remove_resource!).and_return(res)

        expect(@e).to receive(:push!).with(res)

        @p.trigger!

      end

      it 'does not call push! on edge if it cannot provide the needed resource' do
        expect(@e).to receive(:push_expression).and_return( proc{ true })

        expect(@e).not_to receive(:push!)

        @p.trigger!

      end

    end

    context 'when :pull_any' do


    end

    context 'when :push_all' do

    end

    context 'when :pull_all' do

    end


  end

end