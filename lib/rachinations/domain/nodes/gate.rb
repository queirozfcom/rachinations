require_relative '../../domain/nodes/node'
require_relative '../../domain/nodes/resourceless_node'

require 'weighted_distribution'

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

    inv("Edges must be either all defaults or all probabilities") { outgoing_edges.all?{|e| e.label == 1 } || outgoing_edges.all?{|e| e.label.class == Float} }
    inv("If probabilities given, their sum must not exceed 1"){ outgoing_edges.reduce(0){|acc,el| acc + el.label } <= 1 || !outgoing_edges.all?{|e| e.label.class == Float}  }

    maybe_edge = pick_one(outgoing_edges)

    if(maybe_edge.nil?)
      # do nothing - resource has 'vanished' - happens every other day
    else
      maybe_edge.push!(res)
    end

  end

  def to_s
    "Gate '#{@name}'\n\n"
  end

  private

  def pick_one(edges)

    if(edges.all?{|e| e.label == 1})
      #edges is probably an enumerable but only arrays can be sample()'d
      edges.to_a.sample
    elsif(edges.all?{|e| e.label.class == Float})
      #{edge=>weight} is the shape required by WeightedRandomizer
      weights = edges.reduce(Hash.new){|acc,el| acc[el] = el.label; acc }

      sum = edges.reduce(0){|acc,el|acc + el.label }

      remaining = 1.0 - sum

      #resource 'vanishes'
      weights[nil] = remaining

      edge_distribution = WeightedDistribution.new(weights)
      edge_distribution.sample
    else
      raise RuntimeError.new('Invalid setup')
    end

  end

  def options
    [:name, :diagram, :activation, :mode, :types]
  end

  def aliases
    {}
  end

  def defaults
    {
        activation: :passive,
        mode: :push_any,
        types: []
    }
  end

end