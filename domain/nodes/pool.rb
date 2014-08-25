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

  def trigger!

    if enabled?
      if push? && any?

        push_any!

      elsif pull? && any?

        pull_any!

      end

    end
  end

  def resource_count(type=nil, &block)

    raise ArgumentError.new('Please provide either a type or a block, but not both.') if block_given? && !type.nil?

    if type.nil? && !block_given?
      resources.count_where { |r| r.unlocked? }
    elsif type.is_a?(Class) && type <= Token

      if supports? type
        resources.count_where { |r|
          r.unlocked? && r.is_type?(type)
        }
      else
        raise UnsupportedTypeError.new "Unsupported type: #{type.name}"
      end
    elsif block_given?

      # client doesn't need to know about locked vs unlocked resources
      unlock_condition = Proc.new { |r| r.unlocked? }

      resources.count_where { |r| unlock_condition.match?(r) && block.match?(r) }

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

  def take_resource!(&expression)

    unless block_given?
      # if no conditions given, then anything goes.
      expression = Proc.new{ |res| true }
    end

    raise RuntimeError.new unless resources.count_where(&expression) > 0

    res=remove_resource! &expression

    fire_triggers!

    res

  end

  def to_s
    "Pool '#{@name}':  #{@resources.to_s}"
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

  # TODO document this or else refactor it out
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

  private

  attr_reader :resources

  def remove_resource!(&expression)

    # client doesn't need to know about locked vs unlocked resources
    unlocked_expression = Proc.new { |r| r.unlocked? }

    res=resources.get_where { |r| unlocked_expression.call(r) && expression.call(r) }

    @resources_removed[res.class] += 1

    res
  end

  def add_resource!(res)

    resources.add!(res) and @resources_added[res.type]+=1

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
    {:initial_values => :initial_value}
  end

  def push_any!

    outgoing_edges.shuffle.each do |edge|
      begin
        blk = edge.push_expression
      rescue => ex
        puts "Could not get a block for one Edge, but this is push_any so I'll go ahead."
        next #other edges might still be able to serve me.
      end

      edge.label.times do
        begin
          res = remove_resource!(&blk)
        rescue => ex
          puts "Failed to remove this resource. Let's try another Edge, perhaps?"
          break
        end

        edge.push!(res)

      end

    end
  end

  def pull_any!
    incoming_edges.shuffle.each do |edge|
      begin
        blk = edge.pull_expression
      rescue RuntimeError => ex
        puts "Could not get a block for one Edge, but this is pull_any so I'll go ahead."
        next #other edges might still be able to serve me.
      end

      edge.label.times do
        begin
          res = edge.pull!(&blk)
        rescue RuntimeError => ex
          puts "Let's try another Edge, perhaps?"
          break
        end

        add_resource!(res.lock!)

      end

    end
  end

end