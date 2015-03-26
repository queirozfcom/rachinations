require_relative '../spec_helper'

describe 'monografia spec' do

  describe 'examples without dsl' do

  end

  describe 'examples with dsl' do

    it 'example_3' do

      diagram 'exemplo_3' do

        source 's1'
        gate 'g1', :probabilistic
      end

    end

  end

  describe 'full specification' do

    context ' when creating diagram' do

      it 'is created with no name or options' do

        diagram do
          pool
        end

      end

      it 'is created with name but no options' do

        diagram 'my_diagram' do
          pool 98
        end

      end

      it 'is created with all supported options' do

        [:default, :silent, :verbose].each do |runmode|

          diagram 'test', mode: runmode do
            pool 89
          end

        end

      end

      it 'complains if given option is invalid' do

        expect {
          diagram 'test', mode: :foo do
            pool
          end
        }.to raise_error(BadDSL)

      end

    end

  end

end