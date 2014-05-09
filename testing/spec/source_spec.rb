require_relative 'spec_helper'

describe 'Source Instantiation' do

  it 'should have the correct defaults when nothing is provided' do

    s = Source.new name:'source'

    expect(s.type).to eq nil
    expect(s.automatic?).to eq true
    expect(s.push?).to eq true

  end

  it "should support anything if it's untyped" do
    s = Source.new name:'foo'

    expect(s.support?(Peach)).to eq true

  end

  it "should support only the given type and not other types if it's been given a specific type" do

    s = Source.new name:'foo',type:Peach

    expect(s.support?(Mango)).to eq false
    expect(s.support?(Peach)).to eq true

  end


  it 'should raise an error if user tries to give it an initial_value'do
    #sources have no initial value

    expect { Source.new name: 'mysource',initial_value:10 }.to raise_error BadOptions

  end


  it 'should provide a typeless resource (Token) upon receiving receiving remove_resource!' do

    s = Source.new name: 'foo'

    expect(s.remove_resource!).to be_a(Token)

  end

  it "should return a typed resource if it supports that type" do

    s = Source.new name:'foo', type: Green

    expect(s.remove_resource!(Green)).to be_a(Green)

  end

  it "should keep giving out resources forever, and each resource is a different object" do

    s = Source.new name:'foo',type: Blue

    obj_ids = []

    #i've tested this with 10000 loops as well.
    1000.times do

      res = s.remove_resource!(Blue)

      expect(res).to be_a(Blue)

      obj_ids.should_not include(res.object_id)

      obj_ids.push(res.object_id)


    end

  end


end