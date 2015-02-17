require_relative '../../domain/nodes/resourceful_node'
require_relative '../../domain/nodes/node'
require_relative '../../domain/resources/token'
require_relative '../resource_bag'
require_relative '../../domain/exceptions/no_elements_matching_condition_error'
require_relative '../../domain/modules/common/refiners/proc_convenience_methods'
require_relative '../../../../lib/rachinations/helpers/edge_helper'

using ProcConvenienceMethods

class Pool < ResourcefulNode

  EdgeHelper = Helpers::EdgeHelper

  def initialize(hsh={})

    check_options!(hsh)
    params = set_defaults(hsh)

    @resources = get_initial_resources(params[:initial_value])

    @types = get_types(initial_value: params[:initial_value],
                       given_types: params[:types])

    #reference to the underlying diagram
    @diagram = params[:diagram]

    #this node's identifier
    @name = params[:name]

    #whether this node is passive or automatic (active)
    @activation = params.fetch(:activation)

    #pull or push
    @mode = params.fetch(:mode)

    #calling parent constructor to setup other variables.
    super(hsh)

  end

  def trigger!

    if enabled?
      if push? && any?

        push_any!

      elsif pull? && any?

        pull_any!

      elsif push? && all?

        push_all!

      elsif pull? && all?

        pull_all!

      else
        raise BadConfig, "Invalid config for this node's mode"
      end
      fire_triggers!
    end
  end

  def resource_count(type: nil, expr: nil)

    raise ArgumentError.new('Please provide either a type or a block, but not both.') if !expr.nil? && !type.nil?

    if type.nil? && expr.nil?
      resources.count_where { |r| r.unlocked? }
    elsif type.is_a?(Class) && type <= Token

      if supports? type
        resources.count_where { |r|
          r.unlocked? && r.is_type?(type)
        }
      else
        raise UnsupportedTypeError.new "Unsupported type: #{type.name}"
      end
    elsif !expr.nil?

      # client doesn't need to know about locked vs unlocked resources
      unlock_condition = proc { |r| r.unlocked? }

      resources.count_where { |r| unlock_condition.match?(r) && expr.match?(r) }

    else
      raise ArgumentError.new("Wrong parameter types passed to #{__callee__}")
    end
  end

  def instant_resource_count(type=nil)
    if type.nil?
      @resources.count_where { true }
    else

      if supports? type
        @resources.count_where { |r|
          r.instance_of?(type)
        }
      else
        raise UnsupportedTypeError.new "Unsupported type: #{type.name}"
      end
    end
  end


  def commit!

    unlock_resources!

    super

  end


  def put_resource!(obj, edge=nil)

    inv { obj.unlocked? }

    if supports? obj.class
      @resources_added[obj.class] += 1
      resources.add!(obj.lock!)
      fire_triggers!
    else
      raise UnsupportedTypeError.new
    end
  end

  def take_resource!(expression=nil)

    if expression.nil?
      # if no conditions given, then anything goes.
      expression = Proc.new { |res| true }
    end

    raise RuntimeError.new unless resources.count_where(&expression) > 0

    res=remove_resource! expression

    fire_triggers!

    res

  end

  def to_s
    "Pool '#{@name}': #{resources} "
  end

  # TODO this smells. where is this used? can i do without it?
  def get_initial_resources(initial_value)
    inv { !self.instance_variable_defined?(:@resources) }

    bag = ResourceBag.new

    if initial_value.is_a?(Fixnum)
      initial_value.times { bag.add!(Token.new) }
    elsif initial_value.is_a?(Hash)
      initial_value.each do |type, quantity|
        quantity.times { bag.add!(type.new) }
      end
    end

    return bag

  end

  def types
    @types
  end

  private

  attr_reader :resources

  # Tries to remove a Resource that matches given expression from this node.
  # @param [Proc] expression the expression to match against Resources
  # @raise [RuntimeError] In case it was not possible to remove a Resource
  def remove_resource!(expression)

    # client doesn't need to know about locked vs unlocked resources
    unlocked_expression = Proc.new { |r| r.unlocked? }

    begin
      # the original expression plus the expression that specifies that only unlocked
      # resources may be retrieved
      res=resources.get_where { |r| unlocked_expression.call(r) && expression.call(r) }
    rescue ArgumentError
        raise RuntimeError, 'wrong arguments'
    rescue NoElementsMatchingConditionError
        raise RuntimeError, 'no elements matching'
    else
      @resources_removed[res.class] += 1
      res
    end


  end

  def add_resource!(res)

    resources.add!(res) and @resources_added[res.type]+=1

  end

  def push_any!

    outgoing_edges.shuffle.each do |edge|

      blk = edge.push_expression

      edge.label.times do
        begin
          res = remove_resource!(blk)
        rescue RuntimeError
          # Failed to remove this resource. Let's try another Edge, perhaps?
          break
        else
          edge.push!(res)
        end

      end

    end
  end

  def pull_any!
    incoming_edges.shuffle.each do |edge|

      blk = edge.pull_expression

      edge.label.times do
        begin
          res = edge.pull!(blk)
        rescue RuntimeError
          # Let's try another Edge, perhaps?
          break
        else
          add_resource!(res.lock!)
        end

      end

    end
  end

  def pull_all!

    enabled_incoming_edges = incoming_edges.select { |edge| edge.enabled? }

    if enabled_incoming_edges.all? { |edge| edge.test_ping? }

      enabled_incoming_edges.each do |edge|
        blk = edge.pull_expression

        edge.label.times do
          res = edge.pull!(blk)

          add_resource!(res.lock!)

        end

      end
      fire_triggers!
    end

  end

  def push_all!

    enabled_outgoing_edges = outgoing_edges.select { |edge| edge.enabled? }


    if EdgeHelper.all_can_push?(edges, require_all: true)

      enabled_outgoing_edges.each do |edge|

        expression = edge.push_expression

        edge.label.times do

          res = remove_resource!(expression)

          edge.push!(res)

        end

      end
      fire_triggers!
    end


  end

  def options
    [:conditions, :name, :activation, :mode, :types, :initial_value, :diagram]
  end

  def defaults
    {
        activation: :passive,
        mode: :pull_any,
        types: [],
        initial_value: 0
    }
  end

  def aliases
    {
        :initial_values => :initial_value
    }
  end

end