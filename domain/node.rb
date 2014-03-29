require 'set'
require_relative '../domain/resources/token'
require_relative '../domain/resource_bag'

class Node

  include Invariant

  def initialize_copy(orig)
    super

    #need to clone the resource bag as well...
    @resources = @resources.clone()

    #don't need this. takes too much space
    @diagram = nil

  end

end