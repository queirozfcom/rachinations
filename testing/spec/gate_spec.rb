require_relative 'spec_helper'

describe 'Diagrams with gates' do

  context 'simplest possible case' do

    it 'works' do

      d = Diagram.new

      d.add_node! Source, name: 's'
      d.add_node! Gate, name:'g'
      d.add_node! Pool, name: 'p'
      d.add_edge! Edge, from: 's', to: 'g'
      d.add_edge! Edge, from: 'g', to: 'p'

      d.run!(5)

      expect(d.get_node('p').resource_count).to eq 5

    end

  end


end