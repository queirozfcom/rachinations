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

  def attach_trigger(trig)
    triggers.push(trig+[true])
  end

  def triggers
    if @triggers.is_a? Array
      @triggers
    else
      @triggers = Array.new
      @triggers
    end
  end

  def clear_triggers
    triggers.each do |t|
      t[2]=true
    end
  end



  # @param [Node] b
  def trigger!
    triggers.each do | n |
      if (n[0].is_a? Proc) && n[2]
        if n[0].call
          n[2]=false
          n[1].trigger_stage!
        end
      elsif n[0] && n[2]
        n[2]=false
        n[1].trigger_stage!
      end
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
  def commit!;
    clear_triggers
    self
  end

end