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

  it 'notifies the user when no parameters were given' do
    expect{Double.new}.to raise_error BadOptions
  end

  it 'notifies the user when given parameter was not a hash' do
    expect{Double.new Array.new}.to raise_error BadOptions
    expect{Double.new Object.new}.to raise_error BadOptions
    expect{Double.new String.new}.to raise_error BadOptions
  end

  it 'runs ok on simple case' do
    expect{Double.new bar: 'someval'}.not_to raise_error
  end

  it 'raises errors if required options are not given' do
    expect{Double.new foo: 'foo'}.to raise_error BadOptions
  end

  it 'raises errors on invalid options' do
    expect{Double.new bar: 'name', ajsdasdsad: :alkjdasdsad}.to raise_error BadOptions
  end

  it 'correctly infers aliases for non-required options' do
    expect{Double.new bar: 'bar', resistro: 'foo bar'}.not_to raise_error
  end

  it 'correctly infers aliases for required options' do
    expect{Double.new boo: 'bar'}.not_to raise_error
  end

end