require 'coveralls'
Coveralls.wear!

# so that i can require stuff as if these dirctories were in ruby's default PATH
#$: << File.expand_path(File.dirname(__FILE__))+"/../../domain"
#$: << File.expand_path(File.dirname(__FILE__))+"/../../dsl"

require 'rspec'

# RSpec.configure do |config|
#   config.color_enabled = true
#   config.default_path = 'testing/spec'
# end

require 'rachinations'

#resource classes to be used in tests
Blue=Class.new(Token)
Black=Class.new(Token)
Green=Class.new(Token)
Red=Class.new(Token)
Yellow=Class.new(Token)


Football=Class.new(Token)
Baseball=Class.new(Token)
Basketball=Class.new(Token)

Mango=Class.new(Token)
Peach=Class.new(Token)
Banana=Class.new(Token)
Lemon=Class.new(Token)


