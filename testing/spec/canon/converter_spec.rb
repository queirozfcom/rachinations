require_relative '../spec_helper'

describe 'Converter cannonical behavior' do

  context "there's just one pool on each side" do

    before(:each) {
      @d = Diagram.new 'foo'
      @d.add_node! Pool, name: 'p9', initial_value: 9, mode: :push
      @d.add_node! Pool, name: 'p0'
      @d.add_node! Converter, name: 'c'
      @d.add_edge! Edge, name:'e1', from: 'p9', to: 'c'
      @d.add_edge! Edge, name:'e2',from: 'c', to: 'p0'
    }
    it 'is triggered by itself' do

      c = @d.get_node 'c'
      5.times{ c.trigger! }

      expect(@d.get_node('p9').resource_count).to eq 4
      expect(@d.get_node('p0').resource_count).to eq 5

    end

  end
end