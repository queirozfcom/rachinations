require_relative '../../domain/nodes/node'
require_relative '../../domain/nodes/resourceless_node'

require 'weighted_distribution'
require 'fraction'

class Gate < ResourcelessNode

  EdgeHelper = Helpers::EdgeHelper

  attr_reader :mode, :activation

  def initialize(hsh={})
    check_options!(hsh)
    params = set_defaults(hsh)

    @diagram = params[:diagram]
    @name = params[:name]
    @activation = params[:activation]
    # for gates, :mode has different semantics
    @mode = params[:mode]
    @types = get_types(given_types: params[:types])

    super(hsh)
  end

  def put_resource!(res, from_edge)

    raise BadConfig.new('All outgoing Edges must be of the same kind') unless EdgeHelper.all_labels_of_same_kind?(outgoing_edges)
    raise BadConfig.new('If probabilities are given, they must add up to 1') unless EdgeHelper.labels_valid?(outgoing_edges)

    maybe_edge = EdgeHelper.pick_one(edges: outgoing_edges, mode: mode, index: next_edge_index)

    if (maybe_edge.nil?)
      # no outgoing edges. resource disappears
    else
      maybe_edge.push!(res)
    end

  end

  def take_resource!(res, edge)
    # no action
  end

  def to_s
    "Gate '#{@name}'\n\n"
  end

  private

  # used to indicate what edge index
  # when in :deterministic mode
  def next_edge_index
    # starting at zero
    @next_edge_index ||= 0

    @next_edge_index += 1

    (@next_edge_index - 1)
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
        mode: :deterministic,
        types: []
    }
  end

end