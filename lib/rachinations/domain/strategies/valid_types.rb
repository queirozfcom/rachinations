require_relative 'strategy'

class ValidTypes < Strategy

  # @note from_node is only included in the constructor's argument
  #  list to check whether it is enabled, but it isn't used anywhere lese.
  def initialize(from_node, edge, to_node)
    @from_node = from_node
    @edge = edge
    @to_node = to_node
  end

  # Returns the expression block which can used by from_node in order
  # to select a resource that is supported by both the edge and the node
  # to which the resource will be transferred.
  #
  # @return [Proc] the expression block.
  def condition

    return match_none_expression if [@from_node, @edge, @to_node].any? {|el| el.disabled? }

    edge_types = @edge.types
    to_node_types = @to_node.types

    if edge_types.empty? && to_node_types.empty?
      match_all_expression
    else
      if edge_types.empty? && (not to_node_types.empty?)
        Proc.new { |res| to_node_types.include?(res.type) }
      elsif to_node_types.empty? && (not edge_types.empty?)
        Proc.new { |res| edge_types.include?(res.type) }
      else
        Proc.new { |res| edge_types.include?(res.type) && node_types.include?(res.type) }
      end
    end

  end

  # Returns an expression block which can be used to decide whether a given
  # resource is supported both by the edge and by to_node.
  #
  # @return [Proc] the expression block
  def push_condition
    condition
  end

  # Returns an expression block which can be used to decide whether a given
  # resource is supported both by the edge and by from_node.
  #
  # @return [Proc] the expression block
  def pull_condition
    condition
  end

  private

  def unsatisfiable_expression
    Proc.new { true == false }
  end

  def any_satisfiable_expression
    Proc.new { true == true }
  end

  alias_method :match_all_expression, :any_satisfiable_expression
  alias_method :match_none_expression, :unsatisfiable_expression


end