require_relative 'spec_helper'

# a class double so as not to bring in extra stuff we don't want to test
#http://martinfowler.com/articles/mocksArentStubs.html
class Double
  include HashInit

  def options
    #isto é um array com 2 symbols e uma hash
    [:foo, :registro, bar: :required]
  end

  def defaults
    {
        foo: 'foo',
        registro: 'foobar'
    }
  end

  def aliases
    { resistro: :registro, boo: :bar }
  end

end



describe 'Passing of options to Nodes' do

  it 'runs ok on simple case' do
    #no news is good news
    Double.new bar: 'someval'
  end

  it 'should raise errors if required options are not given' do
    expect{Double.new foo: 'foo'}.to raise_error BadOptions
  end

  it 'should raise errors on invalid options' do
    expect{Double.new bar: 'name', ajsdasdsad: :alkjdasdsad}.to raise_error BadOptions
  end

  it 'should correctly infer aliases for non-required options' do
    #no news is good news
    Double.new bar: 'bar', resistro: 'foo bar'
  end

  it 'should correctly infer aliases for required options' do
    #no news is good news
    Double.new boo: 'bar'
  end

end