require_relative '../../domain/nodes/node'
require_relative '../../domain/nodes/resourceless_node'

class Converter < ResourcefulNode

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
    @types = hsh.fetch(:types)
    @activation = hsh.fetch(:activation)

    # each edge may have contributed with some resources at any given time
    @resources_contributed = init_resources

  end

  # Activates this Converter. It will try to pull from
  #  incoming nodes and, if successful, will push into
  #  outgoing nodes.
  def trigger!

    if all?

      if incoming_edges.all? { |edge| edge.test_pull?(true) } && outgoing_edges.all? { |edge| edge.test_push?(true) }
        pull_all!
        push_all!
      else
        # does not trigger
      end

    elsif any?

      pull_any!

      if in_conditions_met?
        if outgoing_edges.all? { |edge| edge.test_push?(true) }
          push_all!
          pop_stored_resources!
        end # converters are always push_all
      end # conditions weren't met this turn

    else
      raise ArgumentError.new "Unsupported mode :#{mode}"
    end

  end

  # Puts a Resource into a Converter. The Edge may be used
  #  as index for internal states and the Resource may be
  #  used in case not all edge conditions have been met
  #  (only applicable when in pull_any mode).
  #
  def put_resource!(res, edge=nil)
    inv { !edge.nil? }
    if all?
      if incoming_edges.all? { |e| e.test_push? }
        push_all!
      end
    elsif any?
      add_to_contributed_resources!(res, edge)
      if in_conditions_met?
        push_all!
      end
    end

  end

  # An override for the original method. The reason for this is
  # that, when an Edge is attached to a Converter after it's been
  # created, a key for it (frozen) needs to be created.
  #
  # @param [Edge] edge
  def attach_edge!(edge)
    #TODO use argument (edge) on the call to super and make sure tests still pass
    # that way it's clearer that it is being passed on to super
    super
    resources_contributed.store(edge, Fifo.new)
    self
  end

  def take_resource!(type=nil, &blk)
    if incoming_edges.shuffle.all? { |edge| edge.test_pull? }
      pull_all!
    end
  end


  def resource_count(type=nil,&block)
    return Float::INFINITY
  end

  def to_s
    "Converter '#{@name}'"
  end

  private

  # This method is used to test whether a Converter
  # has had the conditions for incoming edges met.
  #
  # @return [Boolean] true if conditions for pull_any
  #  have all been met, false otherwise
  def in_conditions_met?

    edges = incoming_edges

    incoming_edges
    .all? { |edge| resources_contributed.keys.include?(edge) && resources_contributed.fetch(edge).length >= edge.label }
  end

  # This removes from the internal store just enough
  # resources to accomplish one push_all (only applicable when in pull_any mode)
  def pop_stored_resources!
    #TODO
  end


  attr_accessor :resources_contributed

  def pull_any!
    incoming_edges
    .shuffle
    .each do |edge|
      begin
        blk = edge.pull_expression
      rescue RuntimeError => ex
        puts "Could not get a block for one Edge, but this is pull_any so I'll go ahead."
        next #other edges might still be able to serve me.
      end

      edge.label.times do
        begin
          res = edge.pull!(&blk)
        rescue RuntimeError => ex
          puts "Let's try another Edge, perhaps?"
          break
        end

        # right here we would add the returned resource to the store,
        # but with converters we dont store the resources;  we just
        # record that this edge has contributed one resource:
        add_to_contributed_resources!(res, edge)

      end

    end

  end

  def pull_all!

    incoming_edges
    .shuffle
    .each do |edge|
      begin
        blk = edge.pull_expression
      rescue RuntimeError => ex
        raise RuntimeError.new "One edge failed to provide an expression; the whole operation failed."
      end

      edge.label.times do
        begin
          res = edge.pull!(&blk)
          res=nil # we do not store the results
        rescue RuntimeError => ex
          raise RuntimeError.new "One edge failed to pull; the whole operation failed."
        end

      end

    end

  end

  def push_all!
    outgoing_edges
    .shuffle
    .each do |edge|
      begin
        exp = edge.push_expression
      rescue RuntimeError => ex
        raise RuntimeError.new "One edge failed to provide an expression; the whole operation failed."
      end

      edge.label.times do

        begin
          res = make_resource(&exp)
        rescue RuntimeError => ex
          raise RuntimeError.new "This Converter cannot provide any suitable Resource."
        end

        begin
          edge.push!(res)
        rescue RuntimeError => e
          raise RuntimeError.new e.message+" SO "+"One push over an edge failed; the whole operation failed."
        end

      end

    end


  end

  def push_any!
    raise NotImplementedError.new "Converters cannot push_any. Only push_all."
  end

  # Try to produce a Resource matching given condition.
  #
  # @return [Token] a token resource or any of its subtypes
  # @raise [RuntimeError] in case this Converter cannot produce any
  #  Resource that matches the condition.
  def make_resource(&condition)

    if untyped?
      res = Token.new
      if condition.match_resource?(res)
        res
      else
        raise RuntimeError.new "Failed to make Resource matching given conditions."
      end
    else
      types.shuffle.each do |type|
        res = type.new
        if condition.match_resource?(res)
          return res
        end
      end
      raise RuntimeError.new "Failed to make Resource matching given conditions."
    end

  end

  # A Converter may receive its needed resources across turns
  # so there must be a way to keep count of which edges have already
  # 'given their contribution' to this Converter.
  def add_to_contributed_resources!(resource, edge)
    resources_contributed.fetch(edge).put!(resource)
  end

  def init_resources
    edges.reduce(Hash.new) { |hash, edge| hash.store(edge.object_id, Fifo.new) }
  end

  def options
    [{name: :required}, :diagram, :mode, :activation, :types]
  end

  def defaults
    {
        mode: :pull_any,
        activation: :passive,
        types: []
    }
  end

end