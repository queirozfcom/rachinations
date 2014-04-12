require_relative 'resourceful_node'
require 'active_support/all'

class Pool < ResourcefulNode

  def initialize(hsh={})

    #set nil to stuff that wasn't initialized
    params=normalize(hsh)

    #nothing set so it's Tokens
    if params[:initial_value].nil? && params[:types].nil?
      @resources = ResourceBag.new
      @types = nil
      # implicit declaration of types
    elsif params[:types].nil? && params[:initial_value].is_a?(Hash)
      @resources = ResourceBag.new
      @types = Array.new

      params[:initial_value].each do |klass, quantity|
        @types.push klass

        quantity.times do
          @resources.add(klass.new)
        end

      end
    elsif params[:types].is_a?(Array) && params[:initial_value].nil?
      @resources = ResourceBag.new
      @types = params[:types]

      #both types and initial values were set!
    elsif params[:types].is_a?(Array) && params[:initial_value].is_a?(Hash)
      @resources = ResourceBag.new
      params[:types].each do |resource_klass|
        #set custom initial value if provided
        if params[:initial_value].has_key?(resource_klass)

          quantity = params[:initial_value][resource_klass]

          quantity.times do
            @resources.add(resource_klass.new)
          end

        end
      end

      #no types, just initial value for integer (or float in case of infinity for sources)
    elsif params[:initial_value].is_a? Numeric
      @resources = ResourceBag.new

      params[:initial_value].times do
        @resources.add(Token.new)
      end

    else
      raise ArgumentError.new "You've tried to create a Pool passing the following parameters: #{params}"
    end


    #reference to the overlying diagram
    @diagram = params[:diagram]

    #this node's identifier
    @name = params[:name]

    #whether this node is passive or automatic (active)
    @activation = params[:activation] ||= :passive

    #pull or push
    @mode = params[:mode] ||= :pull

    # @types and @resources are set within the previous big loop

    #calling parent constructor to setup aother variables.
    super()

  end


  def resource_count(type=nil)

    if type.nil?

      if typed?
        raise ArgumentError.new 'This is a typed Node'
      else
        @resources.count(Token)
      end

    else

      if supports? type
        @resources.count(type)
      else
        raise ArgumentError.new "Unsupported type: #{type.name}"
      end
    end

  end

  def add_resource!(obj)

    inv { obj.unlocked? }

    if supports? obj.class
      @resources.add(obj)
    else
      #it's not an error - no action
    end

  end

  #return the object (it'll probably be added to another node)
  def remove_resource!(type=nil)

    if type.nil?
      if untyped?
        @resources.get(Token)
      end
    else
      if supports? type
        @resources.get(type)
      else
        # TODO decide if I should raise an Error or not here
        nil
      end
    end
  end


  # this should be at node?
  def typed?
    !untyped?
  end

  def untyped?
    types.nil?
  end


  def to_s
    "Pool '#{@name}':  #{@resources.to_s}"
  end

  #this method is revealing too much.. it's exposing too much.
  def each_type &blk
    @types.each &blk
  end


  private

  def normalize(hsh)
    accepted_options = [:name, :activation, :mode, :modetype, :types, :initial_value, :diagram]

    #watch out for unknown options - might be typos!
    hsh.each_pair do |key, value|

      if accepted_options.exclude?(key)
        raise ArgumentError.new "Unknown option: in parameter hash: #{key} "
      end

    end

    #in case the user hasn't passed full parameters to the constructor
    hsh = {
        activation: nil,
        mode: nil,
        types: nil,
        initial_value: nil
    }.merge hsh

    hsh

  end

  # controlling the resources

  def types
    @types
  end



end