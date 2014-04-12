require_relative '../modules/invariant'

class Node

  include Invariant

  attr_accessor :name

  def initialize_copy(orig)
    super

    #need to clone the resource bag as well...
    @resources = @resources.clone()

    #don't need this. takes too much space
    @diagram = nil

  end



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


end