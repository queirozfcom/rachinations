require_relative '../../domain/nodes/resourceful_node'
require_relative '../../domain/resources/token'
require_relative '../resource_bag'
require_relative '../../domain/exceptions/no_elements_matching_condition_error'
require 'active_support/all'

class Pool < ResourcefulNode



  def initialize(hsh={})



    #set nil to stuff that wasn't initialized
    params=normalize(hsh)

    #nothing set so it's Tokens
    if params[:initial_value] === 0 && params[:types].empty?
      @resources = ResourceBag.new
      @types = []
      # implicit declaration of types
    elsif params[:types].empty? && params[:initial_value].is_a?(Hash)
      @resources = ResourceBag.new
      @types = []

      params[:initial_value].each do |klass, quantity|
        @types.push klass

        quantity.times do
          @resources.add!(klass.new)
        end
      end
    elsif params[:types].is_a?(Array) && (not params[:types].empty?) && params[:initial_value] === 0
      @resources = ResourceBag.new
      @types = params[:types]

      #both types and initial values were set!
    elsif params[:types].is_a?(Array) && (not params[:types].empty?) && params[:initial_value].is_a?(Hash)
      @resources = ResourceBag.new
      @types = params[:types]

      params[:types].each do |resource_klass|
        #set custom initial value if provided
        if params[:initial_value].has_key?(resource_klass)

          quantity = params[:initial_value][resource_klass]

          quantity.times do
            @resources.add!(resource_klass.new)
          end

        end
      end

      #no types, just initial value for integer (or float in case of infinity for sources)
    elsif params[:initial_value].is_a? Numeric
      @resources = ResourceBag.new
      @types = []
      params[:initial_value].times do
        @resources.add!(Token.new)
      end

    else
      raise ArgumentError.new "You've tried to create a Pool passing the following parameters: #{params}"
    end

    #reference to the overlying diagram
    @diagram = params[:diagram]

    #this node's identifier
    @name = params[:name]

    #whether this node is passive or automatic (active)
    @activation = params.fetch(:activation, :passive)

    #pull or push
    @mode = params.fetch(:mode, :pull)

    # @types and @resources are set within the previous big loop

    #calling parent constructor to setup another variables.
    super(hsh)

  end


  def resource_count(type=nil)

    if type.nil?
      @resources.count_where { |r| r.unlocked? }
    else

      if supports? type
        @resources.count_where { |r|
          r.unlocked? && r.instance_of?(type)
        }
      else
        raise UnsupportedTypeError.new "Unsupported type: #{type.name}"
      end
    end

  end

  def commit!

    @resources.each_where { |r|
      if r.locked?
        r.unlock!
      end
    }

    self
  end

  def add_resource!(obj)

    if supports? obj.class
      @resources_added[obj.class]=@resources_added[obj.class]+1
      @resources.add!(obj)
    else
      #it's not an error - no action
    end

  end

  #return the object (it'll probably be added to another node)
  def remove_resource!(type=nil, run_hooks=true)

    #just take any resource youe find
    if type.nil?
      if @resources.count_where { |r| r.unlocked? } > 0
        @resources_removed[type]=@resources_removed[type]+1
        @resources.get_where { |r| r.unlocked? }
      else
        raise NoElementsOfGivenTypeError, "No resources found in node '#{name}'"
      end
    else
      if supports? type
        if @resources.count_where { |r| r.instance_of?(type) && r.unlocked? } > 0
         @resources_removed[type]=@resources_removed[type]+1
          @resources.get_where { |r|
            r.instance_of?(type) && r.unlocked?
          }
        else
          raise NoElementsOfGivenTypeError, "No resources of type #{type} found in node '#{name}'."
        end
      else
        # TODO decide if I should raise an Error or not here
        nil
      end
    end
  end

  def remove_resource_where! &expression

    begin
      res = @resources.get_where(&expression).lock!
      @resources_removed[res.class]= @resources_removed[res.class]+1
    rescue NoElementsMatchingConditionError
      raise NoElementsFound.new
    end
    res

  end

  # this should be at node?
  def typed?
    !untyped?
  end

  def untyped?
    types.empty?
  end

  def to_s
    "Pool '#{@name}':  #{@resources.to_s}"
  end

  #this method is revealing too much.. it's exposing too much.
  def each_type &blk
    @types.each &blk
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

  def types
    @types
  end

  private



  def normalize(hsh)

    accepted_options =  [:@conditions, :name, :activation, :mode, :types, :initial_value, :diagram]
    #watch out for unknown options - might be typos!
    hsh.each_pair do |key, value|

      if accepted_options.exclude?(key)
        raise ArgumentError.new "Unknown option: in parameter hash: #{key} "
      end

    end

    #in case the user hasn't passed full parameters to the constructor
    hsh = {
        activation: :passive,
        mode: :pull,
        types: [],
        initial_value: 0
    }.merge hsh

    hsh

  end


end