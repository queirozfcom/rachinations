require_relative '../../domain/nodes/resourceful_node'
require_relative '../../domain/nodes/node'
require_relative '../../domain/resources/token'
require_relative '../resource_bag'
require_relative '../../domain/exceptions/no_elements_matching_condition_error'


class Pool < ResourcefulNode

  def initialize(hsh={})

    check_options!(hsh)
    params = set_defaults(hsh)

    @resources = get_initial_resources(params[:initial_value])

    @types = get_types(params[:initial_value], params[:types])

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


  def resource_count(type=nil,&block)

    raise ArgumentError.new('Please provide either a type or a block, but not both.') if block_given? && !type.nil?

    if type.nil? && !block_given?
      @resources.count_where { |r| r.unlocked? }
    elsif type.is_a?(Class) && type <= Token

      if supports? type
        @resources.count_where { |r|
          r.unlocked? && r.instance_of?(type)
        }
      else
        raise UnsupportedTypeError.new "Unsupported type: #{type.name}"
      end
    elsif block_given?

      # client doesn't need to know about locked vs unlocked resources
      unlock_condition = Proc.new{|r| r.unlocked? }

      @resources.count_where{ |r| unlock_condition.call(r) && block.call(r) }

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


  def add_resource!(obj)

    if supports? obj.class
      @resources_added[obj.class] += 1
      ans=@resources.add!(obj)
      fire_triggers!
      ans
    else
      #it's not an error - no action
    end
  end

  #return the object (it'll probably be added to another node)
  def remove_resource!(type=nil)

    if type.nil?
      blk = Proc.new { |r| r.instance_of?(Token) }
    else
      blk = Proc.new { |r| r.instance_of?(type) }
    end

    remove_resource_where! &blk

  end

  def remove_resource_where!(&expression)

    begin
      res = @resources.get_where(&expression).lock!
      @resources_removed[res.class] += 1
    rescue NoElementsMatchingConditionError
      raise NoElementsFound.new
    end
    fire_triggers!
    res

  end

  def to_s
    "Pool '#{@name}':  #{@resources.to_s}"
  end

  def take_upto(no_resources, type=nil)

    no_resources.times do

      begin
        obj = remove_resource!(type).lock!
      rescue NoElementsOfGivenTypeError
        return
      end

      yield obj

    end

  end

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

  def get_types(initial_value, given_types)
    inv { !self.instance_variable_defined?(:@types) }

    if initial_value.is_a?(Fixnum) && given_types.empty?
      # nothing to do
    elsif initial_value == 0 && !given_types.empty?
      # nothing to do
    elsif initial_value.is_a?(Hash)
      initial_value.each_key { |type| given_types.push(type) }
    else
      raise ArgumentError.new
    end

    given_types.uniq

  end


  def types
    @types
  end

  def options
    [:conditions, :name, :activation, :mode, :types, :initial_value, :diagram]
  end

  def defaults
    {
        activation: :passive,
        mode: :pull,
        types: [],
        initial_value: 0
    }
  end

  def aliases
    {:initial_values => :initial_value}
  end
end