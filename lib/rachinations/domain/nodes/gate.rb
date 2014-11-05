require_relative '../../domain/nodes/node'
require_relative '../../domain/nodes/resourceless_node'

class Gate < ResourcelessNode


  def initialize(hsh={})
    check_options!(hsh)
    params = set_defaults(hsh)

    @diagram = params[:diagram]
    @name = params[:name]
    @activation = params[:activation]
    @mode = params[:mode]
    @types = get_types(given_types: params[:types])

    super(hsh)
  end

  def put_resource!(res,edge)

    # only works for 1 outgoing edge... will think about this later on
    inv{outgoing_edges.size == 1}

    #just pass it on for now
    outgoing_edges.each{|e|
      e.push!(res) if Random.rand < e.label
    }

  end

  private

  def options
    [:name, :diagram, :activation, :mode, :types]
  end

  def aliases
    {}
  end

  def defaults
    {
        activation: :passive,
        mode: :pull_any,
        types: []
    }
  end



end