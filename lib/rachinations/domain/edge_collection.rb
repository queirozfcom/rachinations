require 'forwardable'

class EdgeCollection
  extend Forwardable

  def_delegators :@edges, :[], :<<, :each, :push, :map, :select, :detect, :reduce

  def initialize
    @edges = []
  end

end