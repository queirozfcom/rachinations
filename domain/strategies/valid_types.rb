require_relative 'strategy'

class ValidTypes < Strategy

  # @note from_node_types are only included in the constructor's argument
  #  list for completeness, because they aren't used anywhere.
  def initialize(from_node_types,edge_types, to_node_types)
    @edge_types = edge_types
    @to_node_types = to_node_types
  end

  # Returns the expression block which can used by from_node in order
  # to select a resource that is supported by both the edge and the node
  # to which the resource will be pulled (i.e. to_node).
  #
  # @return [Proc] the expression block.
  def pull_condition

    if @edge_types.empty? && @to_node_types.empty?
      Proc.new{|res| true }
    else
      if @edge_types.empty? && (not @to_node_types.empty?)
        Proc.new{|res| @to_node_types.include?(res.type) }
      elsif @to_node_types.empty? && (not @edge_types.empty?)
        Proc.new{|res| @edge_types.include?(res.type) }
      else
        Proc.new{|res| @edge_types.include?(res.type) && @node_types.include?(res.type) }
      end
    end

  end

  # Returns an expression block which can be used to decide whether a given
  # resource is supported both by the edge and by to_node.
  #
  # @return [Proc] the expression block
  def push_condition
    pull_condition
  end

end