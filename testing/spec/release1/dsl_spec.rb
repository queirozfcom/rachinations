require_relative '../spec_helper'

describe Diagram do

  context 'diagram tests using the dsl' do

    it 'runs a simple example diagram' do
      d = diagram do
        source 's1'
        pool 'p1', :push_any, :automatic
        pool 'p2'
        edge from: 's1', to: 'p1'
        edge from: 'p1', to: 'p2'
      end
      d.run 5

      expect(d.p1.resource_count).to eq 1
      expect(d.p2.resource_count).to eq 4

    end

    it 'runs with one pool with no name' do
      d = diagram do
        pool
      end

      d.run! 5

    end


    it 'runs with one pool with some params' do

      d = diagram do
        pool 'p', 9, :pull_all
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

    it 'accepts new simpler syntax' do

      d = diagram 'd1' do
        pool 'p1', 10, :automatic, :push_any
        pool 'p2'
        edge from: 'p1', to: 'p2'
      end

      d.run 5

      expect(d.p1.resource_count).to eq(5)
      expect(d.p2.resource_count).to eq(5)

    end

    it 'example using push_all, activators and triggers' do

      d = diagram do
        pool 'p1'
        pool 'p2'
        pool 'p3'
        source 's2', :automatic
        pool 'p5'
        source 's1', :automatic, condition: expr { p5.resource_count > 5 }
        pool 'p4', :push_all, initial_value: 11, triggered_by: 's1'
        edge from: 'p4', to: 'p1'
        edge from: 'p4', to: 'p2'
        edge from: 'p4', to: 'p3'
        edge from: 's2', to: 'p5'
      end

      d.run 10

      expect(d.p5.resource_count).to eq 10

      expect(d.p1.resource_count).to eq 3
      expect(d.p2.resource_count).to eq 3
      expect(d.p3.resource_count).to eq 3

      expect(d.p4.resource_count).to eq 2


    end

    it "accepts procs for edge labels" do

      d = diagram do
        source 's'
        pool 'p'
        edge from: 's', to: 'p', label: expr { rand(10) }
      end

      d.run 2

      # this is clearly not an exhaustive test but itll do for now

      expect(d.p.resource_count).to be <= 20
      expect(d.p.resource_count).to be >= 0

    end

    it 'accepts :triggers' do

      # see how it gets confusing when you to turn your logic
      # around in your head and define stuff in the wrong order

      d = diagram do
        pool 'p2'
        pool 'p1', :push_any, initial_value: 7
        source 's', triggers: 'p1'
        edge from: 'p1', to: 'p2'
      end

      d.run 10

      expect(d.p2.resource_count).to eq 7

    end

    it "accepts declaring forward-referencing of non existing nodes" do

      expect do
        # triggered_by forward referencing a node
        diagram do
          pool 'p2', 7, triggered_by: 'p3'
          pool 'p3'
        end
      end.not_to raise_error

      expect do
        # edge forward referencing its connected nodes
        d = diagram do
          pool 'p2', initial_value: 7 # this will be triggered 10 times
          edge from: 'p2', to: 'p3'
          pool 'p3'
        end

      end.not_to raise_error

    end

    it 'runs diagrams using forward-referencing' do

      d = diagram do
        pool 'p2', :automatic, :push_any, initial_value: 7 # this will be triggered 10 times
        edge from: 'p2', to: 'p3'
        pool 'p3'
      end

      d.run 10

      expect(d.p3.resource_count).to eq 7

      d2 = diagram do
        pool :automatic, triggers: 'p2'
        pool 'p2', :push_any, initial_value: 10
        pool 'p3'
        edge from: 'p2', to: 'p3'
      end

      d2.run 10
      expect(d2.p3.resource_count).to eq 10
      expect(d2.p2.resource_count).to eq 0

    end

    it 'runs until safeguard clauses have been met if run method is called with no params' do

      expect {

        d = diagram do
          source 's1'
          edge from: 's1', to: 'p1'
          pool 'p1'
        end

        d.run

      }.not_to raise_exception
    end

    it 'stops when a single stopping condition turns true' do

      d = diagram 'win_lose' do

        sink 'sink'

        source 'green_shots', :automatic
        edge from: 'green_shots', to: 'g1'
        gate 'g1'
        edge from: 'g1', to: 'green_points', label: 40.percent
        # it feels a bit weird having to add a sink just to make labels add up to 1
        edge from: 'g1', to: 'sink', label: 60.percent
        pool 'green_points'

        source 'red_shots', :automatic
        edge from: 'red_shots', to: 'g2'
        gate 'g2'
        edge from: 'g2', to: 'red_points', label: 50.percent
        # it feels a bit weird having to add a sink just to make labels add up to 1
        edge from: 'g2', to: 'sink', label: 50.percent
        pool 'red_points'

        stop 'green wins', expr { green_points.resource_count >= 10 }
        stop 'red wins', expr { red_points.resource_count >= 10 }

      end

      d.run
      expect(d.green_points.resource_count == 10 || d.red_points.resource_count == 10).to be true

    end

    it 'probabilistic gates' do

      d = diagram 'exemplo_3_monografia' do
        source 's1'
        gate 'g1', :probabilistic
        pool 'p1'
        pool 'p2'
        pool 'p3'
        sink 's2', :automatic, condition: expr { p2.resource_count > 30 }
        edge from: 's1', to: 'g1'
        edge from: 'g1', to: 'p1'
        edge 2, from: 'g1', to: 'p2'
        edge from: 'g1', to: 'p3'
        edge from: 'p3', to: 's2'

      end

      d.run

      # after a lot of turns, the sink will dominate other nodes
      # using a range because in the last turn p3 may have received one resource and
      # maybe the sink hasn't pulled it yet
      expect(d.p3.resource_count).to be_within(1).of(0)

    end

    it 'deterministic gates' do

      # this example was taken from gate_spec.rb and adapted to use the DSL instead.

      d = diagram do
        source 's'
        gate 'g', :deterministic
        pool 'p1'
        pool 'p2'
        pool 'p3'
        edge from: 's', to: 'g'
        edge 2, from: 'g', to: 'p1'
        edge from: 'g', to: 'p2'
        edge from: 'g', to: 'p3'
      end

      d.run 12

      expect(d.p1.resource_count).to eq(6)
      expect(d.p2.resource_count).to eq(3)
      expect(d.p3.resource_count).to eq(3)


    end

    it 'diagram output modes' do
      # making sure it doesn't just terminate and print nothing!

      expect {

        d=diagram 'a_diagram', mode: :default do
          source 's'
          edge from: 's', to: 'p'
          pool 'p'
        end
        d.run 100
      }.to output(/total\stime\selapsed/i).to_stdout


      expect {

        d=diagram 'a_diagram', mode: :silent do
          source 's'
          edge from: 's', to: 'p'
          pool 'p'
        end
        d.run 100
      }.to output("").to_stdout

      expect {

        d=diagram 'a_diagram', mode: :verbose do
          source 's'
          edge from: 's', to: 'p'
          pool 'p'
        end
        d.run 20
      }.to output(/round/i).to_stdout # in search of a better regex...

    end

  end

end