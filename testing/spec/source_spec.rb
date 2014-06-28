require_relative 'spec_helper'

describe 'Source Instantiation' do

  it 'has the correct defaults when nothing is provided' do

    s = Source.new name:'source'

    expect(s.type).to eq nil
    expect(s.automatic?).to eq true
    expect(s.push?).to eq true

  end

  it "supports anything if it's untyped" do
    s = Source.new name:'foo'

    expect(s.support?(Peach)).to eq true

  end

  it "supports only the given type and no other types if it's been given a specific type" do

    s = Source.new name:'foo',type:Peach

    expect(s.support?(Mango)).to eq false
    expect(s.support?(Peach)).to eq true

  end


  it 'raises an error if user tries to give it an initial_value'do
    #sources have no initial value
    expect { Source.new name: 'mysource',initial_value:10 }.to raise_error BadOptions
  end


  it "provides a typeless resource (Token) if it it's untyped" do

    s = Source.new name: 'foo'

    expect(s.remove_resource!).to be_a(Token)

  end

  it "provides a typed resource if it supports that type" do

    s = Source.new name:'foo', type: Green

    expect(s.remove_resource!(Green)).to be_a(Green)

  end

  it "keeps giving out resources forever, and each resource is a different object" do

    s = Source.new name:'foo',type: Blue

    obj_ids = []

    #i've tested this with up to 10000 loops.
    # but i keep this 100 just to make the whole
    # test suite run faster.
    100.times do

      res = s.remove_resource!(Blue)

      expect(res).to be_a(Blue)

      expect(obj_ids).not_to include(res.object_id)

      obj_ids.push(res.object_id)


    end

  end


end