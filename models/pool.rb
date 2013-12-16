require_relative 'node'

class Pool < Node

  attr_reader :name, :activation, :mode, :types

  def initialize(name, hsh={})

    accepted_options = [:activation, :mode, :types, :initial_value]

    #watch out for unknown options - might be typos!
    hsh.each_pair do |key, value|

      if !accepted_options.include?(key)
        raise ArgumentError.new "Unknown option: in parameter hash: #{key} "
      end

    end

    hsh = {
        activation: :passive,
        mode: :pull,
        types: [],
        initial_value: 0
    }.merge hsh

    #this node's identifier
    @name = name

    #whether this node is passive or automatic (active)
    @activation = hsh[:activation]

    # an empty array means resources are just numbers
    @types = hsh[:types]

    #need to set each type to zero
    if !@types.empty? && hsh[:initial_value] == 0
      @resources = Hash.new

      @types.each do |value|
        @resources[value] = 0
      end

      # implicit declaration of types
    elsif @types.empty? && hsh[:initial_value].is_a?(Hash)
      @resources = Hash.new

      hsh[:initial_value].each do |key, value|
        @types.push key
        @resources[key] = value
      end
      #both types and initial values were set!
    elsif !types.empty? && hsh[:initial_value].is_a?(Hash)
      @resources = Hash.new
      hsh[:types].each do |key|
        #set zero
        @resources[key] = 0
        #and set custom initial value if provided
        if hsh[:initial_value].has_key?(key)
          @resources[key] = hsh[:initial_value][key]
        end
      end

      #no types, just initial value for integer (or float in case of infinity for sources)
    elsif hsh[:initial_value].is_a? Numeric
      @resources = hsh[:initial_value]
    else
      raise ArgumentError.new
    end


    #pull or push
    @mode = hsh[:mode]

  end

  def resource_count(type=nil)

    if type.nil?

      #this means the user is thinking this is a simple node
      if @resources.is_a? Hash
        raise ArgumentError.new 'This node has non-trivial types but you\'ve tried to access it like it only had numbers.'
      else
        @resources
      end

    else

      @resources.each_key do |key|
        if key == type
          return @resources[key]
        end
      end

      raise ArgumentError.new

    end

  end

  def add_resource!(type=nil)

    if type.nil?
      @resources += 1
    else
      if @resources.has_key? type
        @resources[type] += 1
      else
        raise ArgumentError.new
      end
    end

  end

  #if obj is an actual object (as opposed to nil, which indicates the resource is just a number)
  #return the object (it'll probably be added to another node)
  def remove_resource!(type=nil)
    if type.nil?
      @resources -= 1
    else
      if @resources.has_key? type
        @resources[type] -= 1
      else
        raise ArgumentError.new
      end
    end
  end

  def has_type?(type)
    @resources.is_a?(Numeric) || @resources.keys.include?(type)
  end

  def typed?
    @resources.is_a? Hash
  end

  def to_s
    p "Pool '#{@name}': Current Resources: #{@resources}"
  end

end