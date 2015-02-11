require_relative '../spec_helper'

describe 'Special diagram examples' do

  it 'ticket #77' do

    skip

    p=diagram 'strongerpingpong', mode: :verbose do

      pool 'left', :automatic, initial_value: 1
      pool 'right', :automatic

      source 'newleft', activation: :passive
      source 'newright', activation: :passive

      pool 'rightpoint', triggers: 'newright'
      pool 'leftpoint', triggers: 'newleft'

      gate 'lgame'
      gate 'rgame'

      edge from: 'left', to: 'lgame'
      edge from: 'lgame', to: 'right', label: 3/7
      edge from: 'lgame', to: 'rightpoint', label: 4/5

      edge from: 'right', to: 'rgame'
      edge from: 'rgame', to: 'left', label: 3/5
      edge from: 'rgame', to: 'leftpoint', label: 2/5

      edge from: 'newleft', to: 'left', label: 1
      edge from: 'newright', to: 'right', label: 1

    end

    p.run 10

  end
end