require_relative 'strategy'

class ValidTypes < Strategy


  def initialize(edge_types, target_node_types)

    @edge_types = edge_types
    @node_types = target_node_types

  end


  def condition

    if @edge_types.empty? && @node_types.empty?
      Proc.new{|res| true == true }
    else
      if @edge_types.empty? && (not @node_types.empty?)
        Proc.new{|res| @node_types.include?(res.type) }
      elsif @node_types.empty? && (not @edge_types.empty?)
        Proc.new{|res| @edge_types.include?(res.type) }
      else
        Proc.new{|res| @edge_types.include?(res.type) && @node_types.include?(res.type) }
      end
    end

  end

end