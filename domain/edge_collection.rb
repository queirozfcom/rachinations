require 'forwardable'

class EdgeCollection
  extend Forwardable


  def_delegators :@edges, :[], :<<, :each, :push, :map, :select, :detect

  def initialize
    @edges = []
  end

end