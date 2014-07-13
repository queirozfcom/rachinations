require_relative '../../domain/nodes/pool'

class Source < ResourcefulNode

  attr_reader :type

  def options
    [:type, :mode, :activation, :diagram, :conditions, name: :required]
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

  alias_method :support?, :supports?

  def typed?
    !@type.nil?
  end

  def untyped?
    !typed?
  end

  def to_s
    "Source '#{@name}':  #{@resources.to_s}"
  end

  def add_resource!;
  end

  def remove_resource!(type=nil)

    if type.nil? && untyped?
      res = Token.new.lock!
      type_taken = nil
    elsif !type.nil? && supports?(type)
      res = type.new.lock!
      type_taken = type
    else
      res = self.type.new.lock!
      type_taken = self.type
    end

    @resources_removed[type_taken] += 1

    fire_triggers!

    res

  end

  def types
    [type]
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
