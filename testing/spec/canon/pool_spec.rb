require_relative '../spec_helper'

describe 'Pool canonical behaviour' do

  context 'untyped pools' do

    context 'push_any' do

      before(:each) do

        @p1 = Pool.new name: 'p1', initial_value: 2, mode: :push_any
        @p2 = Pool.new name: 'p2'

        @e = Edge.new name: 'e', from: @p1, to: @p2
        @p1.attach_edge!(@e)
        @p2.attach_edge!(@e)

      end

      it 'pushes one' do

        @p1.trigger!

        expect(@p1.resource_count).to eq 1

        # because it's just received the resource, it'll be blocked
        expect(@p2.instant_resource_count).to eq 1

      end

    end

    context 'pull_any' do

      before(:each) do
        @p1 = Pool.new name: 'p1', mode: :pull_any
        @p2 = Pool.new name: 'p2', initial_value: 2

        @e = Edge.new name: 'e', from: @p2, to: @p1
        @p1.attach_edge!(@e)
        @p2.attach_edge!(@e)


      end

      it 'pulls one' do
        @p1.trigger!

        expect(@p2.resource_count).to eq 1

        # # because it's just received the resource, it'll be blocked
        expect(@p1.instant_resource_count).to eq 1

      end

    end

    context 'push_all' do

    end

    context 'pull_all' do

    end

  end

end