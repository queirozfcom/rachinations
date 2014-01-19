require 'forwardable'

class NodeCollection
  extend Forwardable

  def_delegators :@nodes, :[], :<<, :each, :push, :map, :select, :detect

  def initialize
    @nodes = []
  end

end