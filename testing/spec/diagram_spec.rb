require_relative 'spec_helper'

describe Diagram do
  using NumberModifiers
  using ProcConvenienceMethods


  context 'integration' do

    it 'can be empty' do
      d = Diagram.new 'empty'
      expect(d.name).to eq 'empty'
    end

    it 'should be created with a source and a pool and run n times with no errors' do

      d=Diagram.new 'simples'

      d.add_node! Source, {
          :name => 'fonte'
      }

      d.add_node! Pool, {
          :name => 'depósito',
          :initial_value => 0
      }

      d.add_edge! Edge, {
          :name => 'conector',
          :from => 'fonte',
          :to => 'depósito'
      }

      d.run!(10)

      expect(d.resource_count).to eq 10
      expect(d.get_node('depósito').resource_count).to eq 10

    end

    it "runs for 2 turns with two pools using PULL and there's the correct amount of resources at the end" do

      d = Diagram.new 'some_name'

      d.add_node! Pool, name: 'pool1', initial_value: 5

      d.add_node! Pool, name: 'pool2', activation: :automatic

      d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

      d.run!(2)

      expect(d.get_node('pool1').resource_count).to eq 3
      expect(d.get_node('pool2').resource_count).to eq 2

    end

    it "runs for 2 turns with two pools using PULL and add  the correct amount" do

      d = Diagram.new

      d.add_node! Pool, name: 'pool1', initial_value: 5

      d.add_node! Pool, name: 'pool2', activation: :automatic

      d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

      d.run!(2)

      expect(d.get_node('pool1').resources_added).to eq 0
      expect(d.get_node('pool2').resources_added).to eq 2
      expect(d.get_node('pool2').resources_removed).to eq 0
      expect(d.get_node('pool1').resources_removed).to eq 2

    end

    it "runs for 2 turns with source and pool using PULL and add and remove the correct amount" do

      d = Diagram.new 'some_name'

      d.add_node! Source, name: 's1', activation: :automatic

      d.add_node! Pool, name: 'pool2'

      d.add_edge! Edge, name: 'edge', from: 's1', to: 'pool2'

      d.run!(2)


      expect(d.get_node('s1').resources_added).to eq 0
      expect(d.get_node('pool2').resources_added).to eq 2
      expect(d.get_node('pool2').resources_removed).to eq 0
      expect(d.get_node('s1').resources_removed).to eq 2

    end

    it "runs for two turns with two pools using PUSH and there's the correct amount of resources at the end" do

      d = Diagram.new 'some_name'

      d.add_node! Pool, name: 'pool1', initial_value: 5, mode: :push_any, activation: :automatic

      d.add_node! Pool, name: 'pool2'

      d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

      d.run!(2)

      expect(d.get_node('pool1').resource_count).to eq 3
      expect(d.get_node('pool2').resource_count).to eq 2

    end

    it "runs for a single turn with one source and two pools and there's the correct amount of resources at the end" do
      p = Diagram.new('one source two pools')

      p.add_node!(Source, {name: 'source'})

      p.add_node!(Pool, {name: 'pool1'})

      p.add_node!(Pool, {name: 'pool2', activation: :automatic})

      p.add_edge!(Edge, {name: 'edge1', from: 'source', to: 'pool1'})

      p.add_edge!(Edge, {name: 'connector2', from: 'pool1', to: 'pool2'})

      p.run!(1)

      expect(p.get_node('pool1').resource_count).to eq 1
      expect(p.get_node('pool2').resource_count).to eq 0

    end

    it 'takes staging and commit steps into account when run with 3 pools for 1 turn only' do

      d = Diagram.new

      d.add_node! Pool, name: 'pool1', initial_value: 2, mode: :push_any, activation: :automatic

      d.add_node! Pool, name: 'pool2'

      d.add_node! Pool, name: 'pool3', activation: :automatic

      d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool2'

      d.add_edge! Edge, name: 'edge2', from: 'pool2', to: 'pool3'

      d.run!(1)

      expect(d.get_node('pool1').resource_count).to eq 1
      expect(d.get_node('pool2').resource_count).to eq 1
      expect(d.get_node('pool3').resource_count).to eq 0

    end

    it 'takes staging and commit steps into account when run with 3 pools for 4 turns' do

      d = Diagram.new

      d.add_node! Pool, name: 'pool1', initial_value: 10, mode: :push_any, activation: :automatic

      d.add_node! Pool, name: 'pool2'

      d.add_node! Pool, name: 'pool3', activation: :automatic

      d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool2'

      d.add_edge! Edge, name: 'edge2', from: 'pool2', to: 'pool3'


      d.run!(4)

      expect(d.get_node('pool1').resource_count).to eq 6
      expect(d.get_node('pool2').resource_count).to eq 1
      expect(d.get_node('pool3').resource_count).to eq 3


    end

    it 'runs with a source and a pool and have the expected amount of resources at the end' do

      d=Diagram.new


      d.add_node! Source, {
          :name => 'source'
      }

      d.add_node! Pool, {
          :name => 'deposit',
      }

      d.add_edge! Edge, {
          :name => 'connector',
          :from => 'source',
          :to => 'deposit'
      }

      d.run!(10)

      expect(d.get_node('deposit').resource_count).to eq 10

    end

    it 'can be run until a given condition is true' do

      d=Diagram.new

      d.add_node! Pool, {
          :name => 'deposit',
          :initial_value => 0
      }
      d.add_node! Source, {
          :name => 'source'
      }
      d.add_edge! Edge, {
          :name => 'connector',
          :from => 'source',
          :to => 'deposit'
      }

      d.run_while! { d.get_node('deposit').resource_count < 10 }
      expect(d.get_node('deposit').resource_count).to eq 10

    end

    it 'aborts after specified turns as a safeguard against infinite loops given as stopping condition' do

      d=Diagram.new

      d.max_iterations=9

      d.add_node! Pool, {
          :name => 'deposit',
          :initial_value => 0
      }
      d.add_node! Source, {
          :name => 'source'
      }
      d.add_edge! Edge, {
          :name => 'connector',
          :from => 'source',
          :to => 'deposit'
      }

      d.run_while! { true == true }

      #not hanging on forever is the success condition.
      expect(d.get_node('deposit').resource_count).to eq 9

    end

    it 'does not raise errors when active pushes or pulls are not possible' do

      d = Diagram.new 'no errors'

      d.add_node! Pool, name: 'Poor fella', initial_value: 5

      d.add_node! Pool, name: 'Hungry fella', activation: :automatic

      d.add_edge! Edge, from: 'Poor fella', to: 'Hungry fella'

      expect { d.run! 10 }.not_to raise_error

      expect(d.get_node('Hungry fella').resource_count).to eq 5

    end

    it "raises an error in case users try to access a node that doesn't exist" do

      p = Diagram.new('get invalid node')

      p.add_node! Source, name: 'source'

      p.add_node! Pool, name: 'pool1'

      p.add_edge! Edge, {
          name: 'connector1',
          from: 'source',
          to: 'pool1'
      }

      # use curly brackets instead of parentheses here.
      expect { p.get_node('pool') }.to raise_error RuntimeError

    end

    it 'runs with typed nodes connected by typeless edges' do

      p = Diagram.new('one source one pool typed')

      p.add_node!(Source, name: 'source', :type => Green)
      p.add_node!(Pool, name: 'pool1', :types => [Green, Red])
      p.add_edge!(Edge, name: 'connector1', from: 'source', to: 'pool1')

      p.run!(5)

      expect(p.get_node('pool1').resource_count(type: Green)).to eq 5
      expect(p.get_node('pool1').resource_count(type: Red)).to eq 0

    end

    it "allows untyped nodes to receive typed resources sent to them via untyped edges" do

      p = Diagram.new 'balls'

      p.add_node!(Source, name: 'source', :type => Football)

      p.add_node!(Pool, name: 'pool1')

      p.add_edge!(Edge, name: 'connector1', from: 'source', to: 'pool1')

      p.run!(5)

      expect(p.get_node('pool1').resource_count(type: Football)).to eq 5

    end

    it "allows untyped nodes to receive typed resources sent to them via typed edges" do

      p = Diagram.new 'fruits'

      #by declaring initial values, we're implicitly declaring types.
      p.add_node! Pool, name: 'pool1', initial_value: {Peach => 20, Mango => 99}

      p.add_node! Pool, name: 'pool2', activation: :automatic

      p.add_edge!(Edge, name: 'connector1', from: 'pool1', to: 'pool2', types: [Peach])

      p.run!(5)

      expect(p.get_node('pool1').resource_count(type: Peach)).to eq 15
      expect(p.get_node('pool1').resource_count(type: Mango)).to eq 99
      expect(p.get_node('pool2').resource_count(type: Peach)).to eq 5

    end

    it "executes start nodes only once" do

      d=Diagram.new 'simple'

      d.add_node! Source, {
          :name => 'source',
          :activation => :start
      }

      d.add_node! Pool, {
          :name => 'deposit',
          :initial_value => 0
      }

      d.add_edge! Edge, {
          :name => 'connector',
          :from => 'source',
          :to => 'deposit'
      }

      d.run!(10)

      expect(d.get_node('deposit').resource_count).to eq 1

    end


    it ' makes a train run' do

      d = Diagram.new 'dia'

      d.add_node! Pool, {
          name: 'p1',
          mode: :push_any,
          activation: :automatic,
          initial_value: 8
      }

      d.add_node! Pool, {
          name: 'p2',
          mode: :push_any,
          activation: :automatic
      }

      d.add_node! Pool, {
          name: 'p3',
          mode: :push_any,
          activation: :automatic
      }

      d.add_node! Pool, {
          name: 'p4',
          mode: :push_any,
          activation: :automatic
      }

      d.add_edge! Edge, {
          name: 'e1',
          from: 'p1',
          to: 'p2'
      }
      d.add_edge! Edge, {
          name: 'e2',
          from: 'p2',
          to: 'p3'
      }
      d.add_edge! Edge, {
          name: 'e3',
          from: 'p3',
          to: 'p4'
      }

      d.run!(30)

      expect(d.get_node('p1').resource_count).to eq 0
      expect(d.get_node('p2').resource_count).to eq 0
      expect(d.get_node('p3').resource_count).to eq 0
      expect(d.get_node('p4').resource_count).to eq 8

    end

    it 'runs an untyped converter connected to two pools' do

      d=Diagram.new 'simple'

      d.add_node! Pool, {
          :name => 'from',
          :initial_value => 5
      }

      d.add_node! Pool, {
          :name => 'to',
          :initial_value => 0
      }

      d.add_node! Converter, {
          :name => 'c',
          :activation => :automatic
      }

      d.add_edge! Edge, {
          :name => 'c1',
          :from => 'from',
          :to => 'c'
      }

      d.add_edge! Edge, {
          :name => 'c2',
          :from => 'c',
          :to => 'to'
      }

      d.run!(4)

      expect(d.get_node('to').resource_count).to eq 4

    end

    describe 'diagrams with probabilistic edges' do

      it 'accepts random edges with percentages' do

        d = Diagram.new

        d.add_node! Sink, name: 'sink'
        d.add_node! Source, name: 's'
        d.add_node! Gate, name: 'g'
        d.add_node! Pool, name: 'p'
        d.add_edge! Edge, from: 's', to: 'g'
        d.add_edge! Edge, from: 'g', to: 'p', label: 50.percent
        d.add_edge! Edge, from: 'g', to: 'sink', label: 50.percent

        d.run!(20)

        expect(d.p.resource_count).to (be > 1).and(be < 20)

      end
    end

    describe 'stop conditions' do

      it 'should stop when a stop condition is met before all turns run' do

        d = Diagram.new

        d.add_node! Source, name: 's'
        d.add_node! Gate, name: 'g'
        d.add_node! Pool, name: 'po'
        d.add_edge! Edge, from: 's', to: 'g'
        d.add_edge! Edge, from: 'g', to: 'po'

        d.add_stop_condition! message: 'first', condition: expr { d.po.resource_count >= 5 }

        # useless but still
        d.add_stop_condition! message: 'second', condition: expr { d.po.resource_count >= 10 }

        d.run!(20)

        expect(d.po.resource_count).to eq 5
      end

      it 'should continue until the last round if no stop conditions are met' do
        d = Diagram.new

        d.add_node! Source, name: 's'
        d.add_node! Gate, name: 'g'
        d.add_node! Pool, name: 'po'
        d.add_edge! Edge, from: 's', to: 'g'
        d.add_edge! Edge, from: 'g', to: 'po'

        d.add_stop_condition! message: 'first', condition: expr { d.po.resource_count > 99 }

        # also useless but still
        d.add_stop_condition! message: 'second', condition: expr { d.po.resource_count < -1 }

        d.run!(20)

        expect(d.po.resource_count).to eq 20

      end

      it 'complains' do
        # when users try to add two stop conditions but give them no names

        expect {
          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'po'
          d.add_edge! Edge, from: 's', to: 'g'
          d.add_edge! Edge, from: 'g', to: 'po'

          d.add_stop_condition! condition: expr { d.po.resource_count > 99 }
          d.add_stop_condition! condition: expr { d.po.resource_count < -1 }

        }.to raise_error

      end

    end

    describe 'Comprehensive examples' do

      it 'example using pull_all and activators' do

        d = Diagram.new

        d.add_node! Pool, mode: :pull_all, name: 'p1', activation: :automatic
        d.add_node! Pool, name: 'p2', initial_value: 7
        d.add_node! Pool, name: 'p3', initial_value: 2
        d.add_node! Pool, name: 'p4', initial_value: 2
        d.add_node! Pool, name: 'p5', activation: :automatic, initial_value: 6, mode: :push_any

        d.add_edge! Edge, from: 'p2', to: 'p1'
        d.add_edge! Edge, from: 'p3', to: 'p1'
        d.add_edge! Edge, from: 'p4', to: 'p1'

        d.add_edge! Edge, from: 'p5', to: 'p3'
        d.add_edge! Edge, from: 'p5', to: 'p4'

        d.p5.attach_condition { d.p3.resource_count < 1 && d.p4.resource_count < 1 }

        d.run! 8

        expect(d.p1.resource_count).to eq 15
        expect(d.p2.resource_count).to eq 2
        expect(d.p3.resource_count).to eq 0
        expect(d.p4.resource_count).to eq 0
        expect(d.p5.resource_count).to eq 0

      end


    end

  end

end