require_relative '../../domain/modules/invariant'


class Node

  include Invariant

  attr_reader :name

  def initialize(hsh=nil)
    # do nothing
  end

  def attach_condition(condition)
    conditions.push(condition)
  end

  def conditions
    if @conditions.is_a? Array
      @conditions
    else
      @conditions = Array.new
      @conditions
    end
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

  def enabled?
    res=true
    conditions.each do |cond|
      if cond.is_a? Proc
        res=res && cond.call
      elsif cond === false
        return false
      elsif cond === true
        # do nothing
      end
    end
    res
  end

  def stage!; end
  def trigger_stage!; end
  def commit!; end

end