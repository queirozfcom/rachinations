require_relative '../../domain/nodes/node'
require_relative '../../domain/nodes/resourceless_node'

class Converter < ResourcelessNode

# VEJA O DIAGRAMA BEHAVIOR CONVERTER, inclusive com o equivalente dele

# um converter, ao ser ativado, deve tirar de um lugar e passar para outro
# nada fica guardado em um converter no sentido do pool, porém algumas coisas podem ficar
# temporariamente anotadas nele porque não foi completado ainda o & ou todos os recursos necessários

# um converter pode ser ativado de 3 maneiras
# por si mesmo
# quando um no que empurra empurra algo para ele
# quando um no que puxa puxa dele

# O tipo do conversor define o tipo de saida padrao
# porem o tipo do edge tem vantagem na definicao da saida
# O exemplo com 3 saidas mostra isso


  def initialize(hsh={})
    check_options!(hsh)
    hsh = set_defaults(hsh)
    @name = hsh.fetch(:name)
    @mode = hsh.fetch(:mode)

    # each edge may have contributed with some resources at any given time
    @resources_contributed = init_resources

  end

  # Activates this Converter. It will try to pull from
  #  incoming nodes and, if successful, will push into
  #  outgoing nodes.
  def trigger!

    if all?

      if incoming_edges.all? { |edge| edge.test_ping? } && outgoing_edges.all? { |edge| edge.test_ping? }
        pull_all_in!
        push_all_out!
      else
        # does not trigger
      end

    elsif any?

      incoming_edges.shuffle.each do |edge|
        if edge.test_ping?
          edge.ping!
        end
      end

      if in_conditions_satisfied? && outgoing_edges.all?{|edge| edge.test_ping? }
        push_all_out!
        reset_resources!
      end

    end

  end

  # Puts a Resource into a Converter. The Edge may be used
  #  as index for internal states and the Resource may be
  #  used in case not all edge conditions have been met
  #  (only applicable when in pull_any mode).
  #
  def put_resource!(edge,res)
    inv{edge.frozen?}
    if all?
      if outgoing_edges.all? { |edge| edge.test_ping? }
        push_all_out!
      end
    elsif any?

    end

  end

  def take_resource!(type=nil, &blk)
    if incoming_edges.shuffle.reduce(true) { |acc, edge| acc && edge.test_ping? }
      pull_all_in!
    end
  end

  # This method is used to test whether a Converter
  # has had the conditions for incoming edges met.
  #
  # @return [Boolean] true if conditions for pull_any
  #  have all been met, false otherwise
  def in_conditions_met?
    incoming_edges
    .all? { |edge| @resources_contributed.include?(edge) }
    .all? { |edge| @resources_contributed.fetch(edge).count >= edge.label }
  end

  # This removes from the internal store just enough
  # resources to accomplish one push_all (only applicable when in pull_any mode)
  def pop_stored_resources!
    #TODO
  end

  private

  def pull_all_in!
    incoming_edges.shuffle.each { |e| e.ping! }
  end

  def push_all_out!
    outgoing_edges.shuffle.each { |e| e.ping! }
  end

  # A Converter may receive its needed resources across turns
  # so there must be a way to keep count of which edges have already
  # 'given their contribution' to this Converter.
  def store_resource(edge, resource)
    @resources_contributed.fetch(edge).add(resource)
  end

  def init_resources
    edges.reduce(Hash.new) { |acc, edge| acc.store(edge, Set.new) }
  end

  def options
    [:name, :diagram, :mode, :activation]
  end

  def defaults
    {
        mode: 'pull_any',
        activation: 'passive'
    }
  end

end