require_relative '../../domain/modules/common/invariant'
require_relative '../../domain/modules/common/hash_init'

class Node

  include Invariant
  include HashInit

  attr_reader :name,:types


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

  def incoming_edges
    edges.select{|e| e.to == self}
  end

  def outgoing_edges
    edges.select{|e| e.from == self}
  end

  def attach_edge(edge)
    edges.push(edge)
  end

  def attach_edge!(edge)
    attach_edge(edge)
    self
  end

  def detach_edge(edge)
    if edges.include?(edge)
      edges.pop(edge)
    else
      raise RuntimeError, "This #{self.class} does not include this #{edge.class}"
    end
  end

  def detach_edge!(edge)
    detach_edge(edge)
    self
  end

  def typed?
    !untyped?
  end

  def untyped?
    types.empty?
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

  def fire_triggers!
    triggers.each do |n|
      if (n[0].is_a? Proc) && n[2]
        if n[0].call
          n[2]=false
          n[1].trigger!
        end
      elsif n[0] && n[2]
        n[2]=false
        n[1].trigger!
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

  def disabled?
    !enabled?
  end

  def commit!
    clear_triggers
    self
  end

  def pull?
    @mode === :pull || @mode === :pull_any || @mode === :pull_all
  end

  def push?
    @mode === :push || @mode === :push_any || @mode === :push_all
  end

  def automatic?
    @activation === :automatic
  end

  def passive?
    @activation === :passive
  end

  def start?
    @activation === :start
  end

  def any?
    @mode === :push_any || @mode === :pull_any
  end

  def all?
    @mode === :push_all || @mode === :pull_all
  end

  # Tries to take any resource that, when yielded to expression, returns true.
  # In other words, tries to take any resource which matches the expression
  # block given as parameter.
  #
  # @raise [RuntimeError] in case no resources in this node match given
  #  expression block.
  # @param expression [Proc] the expression
  def take_resource!(&expression)
    raise NotImplementedError, "Please update class #{self.class} to respond to: :#{__callee__}"
  end

  # Places a single resource into this Node. Each subclass may then
  # decide what to do with it; examples are to store the resource and/or to
  # fire triggers.
  #
  # @raise [RuntimeError] in case this node won't take the resource
  def put_resource!(res)
    raise NotImplementedError, "Please update class #{self.class} to respond to: :#{__callee__}"
  end

end