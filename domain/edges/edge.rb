require_relative '../strategies/valid_types'
require_relative '../../domain/exceptions/no_elements_found'

class Edge

  attr_reader :from, :to, :name, :label, :types


  def initialize(hsh)

    @name = hsh.fetch(:name)

    @from = hsh.fetch(:from)

    @to = hsh.fetch(:to)

    #setting default values if needed.
    hsh = defaults.merge hsh

    @label = hsh.fetch(:label)
    @types = hsh.fetch(:types)

  end

  # Simulates a ping!, but no resources get actually
  # moved.
  #
  # @param [Boolean] require_all whether to require that the maximum
  #  number of Resources allowed (as per this Edge's label) be
  #  able to pass in order to return true.
  #
  # @return [Boolean] true in case a ping! on this Edge
  #  would return true. False otherwise.
  def test_ping?(require_all=false)
    return false if from.disabled? || to.disabled?

    condition = strategy.condition

    available_resources = from.resource_count(&condition)

    if available_resources == 0
      false
    elsif available_resources >= label
      true
    elsif available_resources < label && require_all
      false
    else
      # only some resources are able to pass
      true
    end

  end

  def supports?(type)
    types.empty? || types.include?(type)
  end

  alias_method :support?, :supports?

  def enabled?
    true
  end

  def disabled?
    not enabled?
  end

  def untyped?
    types.empty?
  end

  def typed?
    not untyped?
  end

  def from?(obj)
    from.equal?(obj)
  end

  def to?(obj)
    to.equal?(obj)
  end

  # Returns a block which will be later used by the calling node to search
  # for a suitable resource.
  #
  # @return [Proc] a condition block
  def push_expression
    strategy.push_condition
  end

  # Returns a block which will be later used as a parameter
  # to method pull!.
  #
  # @return [Proc] a condition block
  def pull_expression
    strategy.pull_condition
  end

  # Takes a resource and puts it into the node at the other
  # end of this Edge.
  #
  # @raise [RuntimeError] in case the receiving node or this Edge
  #  won't accept the resource sent.
  # @param res the resource to send.
  def push!(res)
    raise RuntimeError.new "This Edge does not support type: #{res.type}" unless supports?(res.type)

    begin
      to.put_resource!(res)
    rescue => e
      # just to make it clear that it bubbles
      raise RuntimeError.new('Push failed')
    end
  end

  # Tries to take a resource matching given block
  # from the node at the other end.
  #
  # @param [Proc] blk  block that will define what resource the other node
  #  should send.
  # @raise [RuntimeError] in case the other node could provide no resources
  #  that satisfy this condition block.
  # @return a resource that satisfies the given block.
  def pull!(&blk)
    begin
      res=from.take_resource!(&blk)
    rescue => e
      # just to make it clear that it bubbles
      raise RuntimeError.new("Pull failed")
    else
      res
    end

  end

  private

  def strategy
    ValidTypes.new(from, self, to)
  end

  def defaults
    {
        :label => 1,
        :types => []
    }
  end

end