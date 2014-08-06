require_relative 'spec_helper'

describe 'Source' do

  describe '#initialize' do

    it 'is push_any automatic with no types by default' do

      s = Source.new name: 'source'

      expect(s.typed?).to eq false
      expect(s.automatic?).to eq true
      expect(s.push?).to eq true
      expect(s.any?).to eq true

    end

    it 'raises an error if user tries to give it an initial_value' do
      #sources have no initial value
      expect { Source.new name: 'mysource', initial_value: 10 }.to raise_error BadOptions
    end


  end


  describe '#support?' do

    it "supports anything if it's untyped" do
      s = Source.new name: 'foo'

      expect(s.support?(Peach)).to eq true

    end

    it "supports only the given type and no other types if it's been given a specific type" do

      s = Source.new name: 'foo', type: Peach

      expect(s.support?(Mango)).to eq false
      expect(s.support?(Peach)).to eq true

    end


  end


  describe '#take_resource!' do

    it "provides a typeless resource (Token) if it it's untyped" do

      s = Source.new name: 'foo'

      expect(s.take_resource!).to be_a(Token)

    end

    it "provides a typed resource if it supports that type" do

      s = Source.new name: 'foo', type: Green

      expect(s.take_resource!(Green)).to be_a(Green)

    end

    it "keeps giving out resources forever, and each resource is a different object" do

      s = Source.new name: 'foo', type: Blue

      obj_ids = []

      #i've tested this with up to 10000 loops.
      # but i keep this 100 just to make the whole
      # test suite run faster.
      100.times do

        res = s.take_resource!(Blue)

        expect(res).to be_a(Blue)

        expect(obj_ids).not_to include(res.object_id)

        obj_ids.push(res.object_id)


      end

    end

  end

  describe '#trigger!' do

    context 'when :push_any' do

      before(:each) do

        @s = Source.new name: 's'

        @e1 = instance_double(Edge, from: @s, to: double(), label: 1)

        @e2 = instance_double(Edge, from: @s, to: double(), label: 1)

        @s.attach_edge!(@e1)
        @s.attach_edge!(@e2)


      end

      it 'sends a push to outgoing edges(in random order)' do

        expect(@e1).to receive(:push_expression).and_return( proc{true==true} )
        expect(@e2).to receive(:push_expression).and_return( proc{true==true} )

        expect(@e1).to receive(:push!)
        expect(@e2).to receive(:push!)

        @s.trigger!

      end

    end

    context 'when :push_all' do

    end

  end


end