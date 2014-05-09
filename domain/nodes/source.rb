require_relative '../../domain/nodes/pool'

class Source < ResourcefulNode

  attr_reader :type

  def options
    [ :type, :mode, :activation,:diagram,:conditions, name: :required]
  end

  def defaults
    {
        type: nil,
        mode: :push,
        activation: :automatic
    }
  end

  def initialize(hsh={})

    check_options!(hsh)
    params = set_defaults(hsh)

    @type = params[:type]
    @mode = params[:mode]
    @activation = params[:activation]
    @name = params[:name]

    super

  end

  def supports?(a_type)
    if type.eql?(Token)
      untyped?
    else
      #untyped nodes support everything.
      if untyped?
        true
      else
        typed? && type.eql?(a_type)
      end
    end
  end


  alias_method :support?, :supports?

  def typed?
    !@type.nil?
  end

  def untyped?
    !typed?
  end

  # def types
  #   [type]
  # end

  def to_s
    "Source '#{@name}':  #{@resources.to_s}"
  end

  def add_resource!; end

  def remove_resource!(type=nil,run_hooks=true)

     if type.nil?
       res = Token.new.lock!
     else
       res = type.new.lock!
     end

     @resources_removed[type] += 1

    return res

  end

  def remove_resource_where!

    # all i can give is my type!

    if typed?
      res = type.new.lock!
    else
      res = Token.new.lock!
    end

    @resources_removed[type] += 1

    trigger!

    res

  end

  def resources_added
    0
  end

  def resources_removed(type=nil)
    @resources_removed[type]
  end

  def resource_count(type=nil)
    return 0
  end
end
