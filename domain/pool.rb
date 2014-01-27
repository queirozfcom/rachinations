require_relative 'node'
require 'active_support/all'

class Pool < Node

  attr_reader :name, :activation, :mode, :types

  def initialize(hsh={})

    accepted_options = [:name, :activation, :mode, :types, :initial_value, :diagram]

    #watch out for unknown options - might be typos!
    hsh.each_pair do |key, value|

      if accepted_options.exclude?(key)
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
    @name = hsh[:name]

    #whether this node is passive or automatic (active)
    @activation = hsh[:activation]

    # an empty array means resources are just numbers
    @types = hsh[:types]

    #need to set each type to zero
    if !hsh[:types].empty? && hsh[:initial_value] == 0
      @resources = ResourceBag.new(hsh[:types])

      # implicit declaration of types
    elsif hsh[:types].empty? && hsh[:initial_value].is_a?(Hash)
      @resources = ResourceBag.new(hsh[:types])

      hsh[:initial_value].each do |klass, quantity|
        @types.push klass

        quantity.times do

          @resources.add(klass.new)

        end

      end
      #both types and initial values were set!
    elsif !hsh[:types].empty? && hsh[:initial_value].is_a?(Hash)
      @resources = ResourceBag.new(hsh[:types])
      hsh[:types].each do |resource_klass|
        #set custom initial value if provided
        if hsh[:initial_value].has_key?(resource_klass)

          quantity = hsh[:initial_value][resource_klass]

          quantity.times do
            @resources.add(resource_klass.new)
          end

        end
      end

      #no types, just initial value for integer (or float in case of infinity for sources)
    elsif hsh[:initial_value].is_a? Numeric
      @resources = ResourceBag.new

      hsh[:initial_value].times do
        @resources.add(Token.new)
      end

    else
      raise ArgumentError.new "You've tried to create a Pool passing the following parameters: #{hsh}"
    end

    #pull or push
    @mode = hsh[:mode]

    #reference to the overlying diagram
    @diagram = hsh[:diagram]

  end

  def resource_count(type=nil)

    #TODO raise a warning if user sends no type but resources are typed

    if type.nil?

      if !@resources.allow? Token
        raise ArgumentError.new "This Pool does not support untyped tokens."
      end

      @resources.count(Token)
    else

      if !@resources.allows? type
        raise ArgumentError.new "This Pool is typed."
      end

      @resources.count(type)
    end

  end

  def add_resource!(type=nil)

    if type.nil?
      @resources.add(Token.new)
    else
      if @resources.allow? type
        @resources.add(type.new)
      else
        raise ArgumentError.new
      end
    end

  end

  #if obj is an actual object (as opposed to nil, which indicates the resource is just a number)
  #return the object (it'll probably be added to another node)
  def remove_resource!(type=nil)
    if type.nil?
      @resources.get(Token)
    else
      if @resources.allows? type
        @resources.get(type)
      else
        raise ArgumentError.new
      end
    end
  end

  def has_type?(type)
    @resources.allows?(type)
  end

  def typed?
    @resources.is_a? Hash
  end

  def push?
    @mode === :push
  end

  def automatic?
    @activation === :automatic
  end

  #this method is revealing too much.. it's exposing too much.
  def each_type &blk
    @types.each &blk
  end

  def to_s
    p "Pool '#{@name}': Current Resources: #{@resources}"
  end

end