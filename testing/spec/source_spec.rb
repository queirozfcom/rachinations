require_relative 'spec_helper'

describe 'Source Instantiation' do

  it 'should have the correct defaults when nothing is provided' do

    s = Source.new name:'source'

    expect(s.types).to eq []
    expect(s.automatic?).to eq true
    expect(s.push?).to eq true
  end
end