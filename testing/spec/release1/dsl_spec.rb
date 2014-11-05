require_relative '../spec_helper'

describe Diagram do
  using NumberModifiers

  context 'diagram tests using the dsl' do

    it 'runs with one pool with no name' do
      d = diagram do
        pool
      end

      d.run! 5

    end

    it 'runs with one pool with some params' do

      d = diagram do
        pool name:'p',initial_value: 9, mode: :pull_all
      end

      d.run! 5
      expect(d.p.resource_count).to eq 9
    end



  end
end