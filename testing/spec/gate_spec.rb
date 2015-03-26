require_relative 'spec_helper'

describe 'Diagrams with gates' do


  context 'general tests' do

    it 'works' do

      d = Diagram.new

      d.add_node! Source, name: 's'
      d.add_node! Gate, name: 'g'
      d.add_node! Pool, name: 'p'
      d.add_edge! Edge, from: 's', to: 'g'
      d.add_edge! Edge, from: 'g', to: 'p'

      d.run!(5)

      expect(d.get_node('p').resource_count).to eq 5

    end

    it 'has default settings' do


      g = Gate.new name: 'g'

      expect(g.mode).to eq(:deterministic)
      expect(g.name).to eq('g')
      expect(g.activation).to eq(:passive)
    end

  end

  context 'specific features' do

    # in other words,
    #   either all floats adding up to 1 (which will be interpreted as probabilities that one will be chosen)
    #   or all integers (which will be interpreted )
    context 'outgoing edges' do

      it 'errors when one is fraction and another integer' do

        expect {

          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'p1'
          d.add_node! Pool, name: 'p2'


          d.add_edge! Edge, name: 'e1', from: 's', to: 'g'
          d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 1/2
          d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 4

          d.run! 10

        }.to raise_error(BadConfig)
      end

      it 'compiles when both are integer' do

        expect {

          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'p1'
          d.add_node! Pool, name: 'p2'


          d.add_edge! Edge, name: 'e1', from: 's', to: 'g'
          d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 5
          d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 4

          d.run! 10

        }.not_to raise_error

      end

      it 'compiles when both are fractions and add up to 1' do

        # well-behaved labels
        expect {

          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'p1'
          d.add_node! Pool, name: 'p2'


          d.add_edge! Edge, name: 'e1', from: 's', to: 'g'
          d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 1/2
          d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 1/2

          d.run! 10

        }.not_to raise_error

        # badly behaved labels
        expect {

          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'p1'
          d.add_node! Pool, name: 'p2'


          d.add_edge! Edge, name: 'e1', from: 's', to: 'g'
          d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 3/21
          d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 18/21

          d.run! 10

        }.not_to raise_error

      end

      it "errors when fraction labels don't add up to one" do
        # less than 1
        expect{
          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'p1'
          d.add_node! Pool, name: 'p2'
          d.add_node! Pool, name: 'p3'


          d.add_edge! Edge, name: 'e1', from: 's', to: 'g'
          d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 1/9
          d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 8/77
          d.add_edge! Edge, name: 'e4', from: 'g', to: 'p3', label: 2/17

          d.run! 10
        }.to raise_error(BadConfig)

        # greater than 1 but each one not greater than 1
        expect{
          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'p1'
          d.add_node! Pool, name: 'p2'


          d.add_edge! Edge, name: 'e1', from: 's', to: 'g'
          d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 4/9
          d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 11/12

          d.run! 10
        }.to raise_error(BadConfig)

        # greater than 1 but a single label is greater than 1
        expect{
          d = Diagram.new

          d.add_node! Source, name: 's'
          d.add_node! Gate, name: 'g'
          d.add_node! Pool, name: 'p1'
          d.add_node! Pool, name: 'p2'


          d.add_edge! Edge, name: 'e1', from: 's', to: 'g'
          d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 22/9
          d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 1/12

          d.run! 10
        }.to raise_error(BadConfig)
      end

    end

    it 'probabilistic gates send resources in a non-deterministic way' do

      no_of_turns = 100

      d = Diagram.new

      d.add_node! Source, name: 's'
      d.add_node! Gate, name: 'g', mode: :probabilistic

      d.add_node! Pool, name: 'p1'
      d.add_node! Pool, name: 'p2'
      d.add_node! Pool, name: 'p3'

      d.add_edge! Edge, name: 'e1', from: 's', to: 'g'

      d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 1/2
      d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 1/4
      d.add_edge! Edge, name: 'e4', from: 'g', to: 'p3', label: 1/4

      d.run! no_of_turns

      # have to deal with probabilities here
      expect(d.get_node('p1').resource_count).to be_within(10).of(50)
      expect(d.get_node('p2').resource_count).to be_within(10).of(25)
      expect(d.get_node('p3').resource_count).to be_within(10).of(25)

      # this should work in  most cases
      expect(d.get_node('p2').resource_count).not_to eq(d.get_node('p3').resource_count)

      # the sum must remain constant
      p1_res = d.get_node('p1').resource_count
      p2_res = d.get_node('p2').resource_count
      p3_res = d.get_node('p3').resource_count

      sum_res = p1_res + p2_res + p3_res
      expect(sum_res).to eq no_of_turns

    end

    it 'deterministic gates always distribute resources in the same order (integer labels)' do

      d = Diagram.new

      d.add_node! Source, name: 's'
      d.add_node! Gate, name: 'g', mode: :deterministic

      d.add_node! Pool, name: 'p1'
      d.add_node! Pool, name: 'p2'
      d.add_node! Pool, name: 'p3'

      d.add_edge! Edge, name: 'e1', from: 's', to: 'g'

      d.add_edge! Edge, name: 'e2', from: 'g', to: 'p1', label: 2
      d.add_edge! Edge, name: 'e3', from: 'g', to: 'p2', label: 1
      d.add_edge! Edge, name: 'e4', from: 'g', to: 'p3', label: 1

      # if resources are shared deterministically and the number of turns
      # is a multiple of the number of outgoing edges then there should be
      # a predictably defined number of resources in each pool
      d.run! 12

      expect(d.get_node('p1').resource_count).to eq(6)
      expect(d.get_node('p2').resource_count).to eq(3)
      expect(d.get_node('p3').resource_count).to eq(3)

    end

  end


end