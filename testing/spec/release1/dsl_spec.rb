require_relative '../spec_helper'

describe Diagram do
  using NumberModifiers

  context 'diagram tests using the dsl' do

    # it 'runs a simple example diagram' do
    #   d = diagram do
    #     source 's1'
    #     pool 'p1', :push_any, :automatic
    #     pool 'p2'
    #     edge from: 's1', to: 'p1'
    #     edge from: 'p1', to: 'p2'
    #   end
    #   d.run 5
    #
    #   expect(d.p1.resource_count).to eq 1
    #   expect(d.p2.resource_count).to eq 4
    #
    # end
    #
    # it 'runs with one pool with no name' do
    #   d = diagram do
    #     pool
    #   end
    #
    #   d.run! 5
    #
    # end
    #

    it 'runs with one pool with some params' do

      d = diagram do
        pool 'p', 9, :pull_all
      end

      d.run! 5
      expect(d.p.resource_count).to eq 9

    end

    it 'requires valid names for nodes and edges because they might be used as methods' do

      expect {

        d = diagram 'wrong' do
          pool 'p1'
          source 's1'
          pool 'foo bar'
          source '1ar baz'
          edge ' foo', from: 'p1', to: 's1'
          edge 'foo ', from: 'p1', to: 's1'
        end

      }.to raise_error(BadDSL)

    end

    it 'runs with conditions' do

      d = diagram 'conditions' do
        source 's1'
        pool 'p1'
        source 's2', condition: lambda { p1.resource_count > 3 }
        pool 'p2'
        edge from: 's1', to: 'p1'
        edge from: 's2', to: 'p2'
      end

      d.run! 10

      expect(d.p2.resource_count).to eq 6

    end

    it 'runs with triggers' do

      d = diagram 'triggers' do
        source 's1'
        pool 'p1'
        source 's2', activation: :passive, triggered_by: 'p1'
        pool 'p2'
        edge from: 's1', to: 'p1'
        edge from: 's2', to: 'p2'
      end

      d.run! 10

      expect(d.p2.resource_count).to eq 10

    end

    it 'runs with a three-way, default gate using different notations' do

      d = diagram do
        source 's1'
        gate 'g1'
        edge from: 's1', to: 'g1'
        pool 'p1'
        pool 'p2'
        pool 'p3'
        edge 'e1', 1/3, from: 'g1', to: 'p1'
        edge 'e1', from: 'g1', to: 'p2', label: 1/3
        edge 'e1', from: 'g1', to: 'p3', label: 1/3
      end


      d.run! 20
      #this gate is conservative - each resource necessarily goes to
      #either p1, p2 or p3 so the sum must be equal to the total amount
      #created by the source
      expect(d.p1.resource_count + d.p2.resource_count + d.p3.resource_count).to eq 20

    end

    it 'runs a comprehensive example' do

      d = diagram 'stable_state' do
        source 's1'
        gate 'g1'
        pool 'p1'
        pool 'p2'
        pool 'p3'
        sink 'sink1', activation: :automatic, condition: lambda { p1.resource_count > 30 }
        edge from: 's1', to: 'g1'
        edge from: 'g1', to: 'p1', label: 2/4
        edge from: 'g1', to: 'p2', label: 1/4
        edge from: 'g1', to: 'p3', label: 1/4
        edge from: 'p2', to: 'sink1'
      end

      d.run 300

      expect(d.p3.resource_count).to be_within(40).of(d.p1.resource_count / 2)
      expect(d.p2.resource_count).to be_within(5).of(1)

    end

    it 'new simpler syntax'do

      d = diagram 'd1' do
        pool 'p1', 10, :automatic, :push_any
        pool 'p2'
        edge from: 'p1', to: 'p2'
      end

      d.run 5

      expect(d.p1.resource_count).to eq(5)
      expect(d.p2.resource_count).to eq(5)


    end

  end
end