require 'modules/invariant'


class Node

  include Invariant

  attr_reader :name

  def edges
    if @edges.is_a? Array
      @edges
    else
      @edges = Array.new
      @edges
    end
  end

  def attach_edge(edge)
    edges.push(edge)
  end

  def unattach_edge(edge)
    if edges.include?(edge)
      edges.pop(edge)
    else
      raise RuntimeError, "This #{self.class} does not include this #{edge.class}"
    end

  end

  def stage!; end
  def commit!; end

end