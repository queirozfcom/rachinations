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
        pool 'p', initial_value: 9, mode: :pull_all
      end

      d.run! 5
      expect(d.p.resource_count).to eq 9
    end

    it 'runs with conditions' do

      d = diagram 'conditions' do
        source 's1'
        pool 'p1'
        source 's2', condition: lambda{ p1.resource_count > 3 }
        pool 'p2'
        edge from: 's1', to: 'p1'
        edge from: 's2', to: 'p2'
      end

      d.run! 10

      expect(d.p2.resource_count).to eq 6

    end

    it 'runs with triggers'do
      d = diagram 'triggers' do
        source 's1'
        pool 'p1'
        source 's2', activation: :passive, triggered_by: 'p1'
        pool 'p2'
        edge from: 's1',to: 'p1'
        edge from: 's2', to: 'p2'
      end

      d.run! 10

      expect(d.p2.resource_count).to eq 10

    end


  end
end