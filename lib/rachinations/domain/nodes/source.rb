require_relative '../../domain/nodes/pool'

class Source < ResourcefulNode


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
    "Source '#{@name}'\n\n"
  end

  def put_resource!;
  end

  def take_resource!(type=nil)

    if type.nil? && untyped?
      res = Token.new
      type_taken = nil
    elsif !type.nil? && supports?(type)
      res = type.new
      type_taken = type
    else
      res = self.type.new
      type_taken = self.type
    end

    @resources_removed[type_taken] += 1

    fire_triggers!

    res

  end

  def types
    [@type]
  end

  def trigger!
    if enabled?
      if push? && any?

        push_any!

      elsif pull?

        raise NotImplementedError('A pulling Source?')

      end

    end
  end

  def resources_added
    0
  end

  def resources_removed(type=nil)

    if type.nil?
      @resources_removed[Token]
    else
      @resources_removed[type]
    end

  end

  def resource_count(type=nil)
    return 0
  end

  private

  def remove_resource!(&expression)

    #we'll need to change this if source starts accepting
    # more than a single type
    inv("Sources can only have a single type") { types.size === 1 }

    if type.nil?
      res = Token.new
    else
      res = type.new
    end

    if (expression.call(res))
      @resources_removed[res.type] += 1
      res
    else
      raise RuntimeError.new("This Source cannot provide a resource matching given expression.")
    end


  end

  attr_reader :type

  private

  def push_any!
    outgoing_edges
    .shuffle
    .each do |edge|
      begin
        blk = edge.push_expression
      rescue => ex
        # Could not get a block for one Edge, but this is push_any so I'll go ahead.
        next
      end

      edge.label.times do
        begin
          res = remove_resource!(&blk)
        rescue => ex
          # Failed to remove this resource. Let's try another Edge, perhaps?
          break
        end

        edge.push!(res)

      end

    end
    fire_triggers!
  end

  def options
    [:type, :mode, :activation, :diagram, :conditions, name: :required]
  end

  def defaults
    {
        type: nil,
        mode: :push_any,
        activation: :automatic
    }
  end

end
