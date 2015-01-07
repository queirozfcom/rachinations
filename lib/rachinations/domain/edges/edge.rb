require_relative '../strategies/valid_types'
require_relative '../../domain/exceptions/no_elements_found'
require_relative '../../../../lib/rachinations/domain/modules/common/hash_init'
require_relative '../../../../lib/rachinations/domain/modules/common/refiners/number_modifiers'

class Edge
  include HashInit
  using NumberModifiers


  attr_reader :from, :to, :name, :label, :types


  def initialize(hsh)

    check_options!(hsh)

    params = set_defaults(hsh)

    @name = params.fetch(:name, 'anonymous')

    @from = params.fetch(:from)

    @to = params.fetch(:to)

    @label = params.fetch(:label)

    @types = params.fetch(:types)

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
  def test_ping?(require_all:false)
    return false if from.disabled? || to.disabled?

    condition = strategy.condition

    available_resources = from.resource_count(expr: condition)

    if available_resources == 0
      false
    elsif available_resources >= label
      true
    elsif available_resources < label && require_all
      false
    else
      # only some resources are able to pass but it's not require_all,
      # so the ping takes place
      true
    end

  end

  # the code is the same but sometimes it helps to specify what action
  # we are talking about so as to make code more understandable
  alias_method :test_pull?, :test_ping?
  alias_method :test_push?, :test_ping?


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
  # @param res [Token] the resource to send.
  def push!(res)
    raise RuntimeError, "This Edge does not support type: #{res.type}" unless supports?(res.type)

    begin
      to.put_resource!(res, self)
    rescue UnsupportedTypeError
      raise RuntimeError, "unsupported type"
    end
  end

  # Tries to take a resource matching given block
  # from the node at the other end.
  #
  # @param [Proc] blk  block that will define what resource the other node
  #  should send.
  # @raise [RuntimeError] in case the other node could provide no resources
  #  that satisfy this condition block.
  # @return [Token,nil] a Resource that satisfies the given block or nil,
  #  if the pull was not performed for some reason (e.g. it's probabilistic)
  def pull!(blk)

    begin
      res=from.take_resource!(blk)
    rescue => e
      # just to make it clear that it bubbles
      raise RuntimeError.new("Pull failed")
    else
      res
    end

  end

  def to_s
    "Edge '#{@name}', from '#{from.name}' to '#{to.name}'"
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

  def options
    [:name,:label,:types,:from,:to,:diagram]
  end

end