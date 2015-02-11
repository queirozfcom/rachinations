require_relative '../../domain/modules/common/invariant'
require_relative '../../domain/modules/common/hash_init'

# @abstract Subclass and override {#take_resource!} and
#   {#put_resource!} to implement nodes
class Node

  include Invariant
  include HashInit

  attr_reader :name, :types

  # Tries to figure out this Node's types based upon what's passed as
  # parameters. If types were given then just set those as this Node
  # types. If initial_values were given then try to work out the types
  # from those.
  #
  # @param initial_value [Hash,Fixnum] initial values for this  node
  # @param given_types [Array] provided types
  # @return [Array] the computed types for this node
  def get_types(initial_value: 0, given_types: [])
    inv { !self.instance_variable_defined?(:@types) }

    actual_types = given_types

    if initial_value.is_a?(Fixnum) && given_types.empty?
      # nothing to do
    elsif initial_value == 0 && !given_types.empty?
      # nothing to do
    elsif initial_value.is_a?(Hash)
      initial_value.each_key { |type| actual_types.push(type) }
    else
      raise ArgumentError.new
    end

    actual_types.uniq

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
    edges.select { |e| e.to == self }
  end

  def outgoing_edges
    edges.select { |e| e.from == self }
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
      raise RuntimeError "This #{self.class} does not include this #{edge.class}"
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

  def attach_condition(&blk)
    conditions.push(blk)
  end

  def conditions
    @conditions = @conditions || Array.new
    @conditions
  end


  def attach_trigger(target_node)
    triggers.push(target_node)
  end

  def triggers
    @triggers = @triggers || Array.new
    @triggers
  end

  # Call trigger! on each node stored in self.triggers
  #
  def fire_triggers!
    triggers.each { |node| node.trigger! }
  end

  def enabled?
    status=true
    conditions.each do |condition|
      if condition.is_a? Proc
        status = (status && condition.call)
      elsif condition === false
        return false
      elsif condition === true
        # do nothing
      end
    end
    status
  end

  def disabled?
    !enabled?
  end

  def commit!
    # clear_triggers
    #self
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
  def put_resource!(res, edge=nil)
    raise NotImplementedError, "Please update class #{self.class} to respond to: :#{__callee__}"
  end

end