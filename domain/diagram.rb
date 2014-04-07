require_relative 'modules/invariant'
require_relative 'edges/edge'
require_relative 'nodes/node'
require_relative 'nodes/resourceful_node'
require_relative 'nodes/pool'
require_relative 'nodes/source'
require_relative 'node_collection'
require_relative 'edge_collection'
require_relative 'exceptions/no_elements_of_given_type'

#noinspection RubyArgCount
class Diagram

  include Invariant

  attr_accessor :name

  def initialize(name)
    @nodes = NodeCollection.new
    @edges = EdgeCollection.new
    @name = name
  end

  def get_node(name)
    nodes.each do |node|
      if node.name == name
        return node
      end
    end

    raise RuntimeError, "Node with name='#{name}' not found."
  end

  #destrutivo
  def add_node!(node_klass, params)

    #TODO assert that node_klass responds_to the methods we're going to call

    #make the diagram available to the node
    params.store(:diagram, self)

    node = node_klass.new(params)

    nodes.push(node)

    nil
  end

  #destrutivo
  def add_edge!(edge_klass, params)

    #TODO assert that edge_klass responds_to the methods we're going to call

    params.store(:diagram, self)

    #we need to send the actual noded, not their names
    from = get_node(params.fetch(:from))
    to = get_node(params.fetch(:to))

    params.store(:from, from)
    params.store(:to, to)

    edge = edge_klass.new(params)

    from.attach_edge(edge)
    to.attach_edge(edge)

    edges.push(edge)

    nil
  end

  def run!(rounds=5, reporting=false)

    run_while!(reporting) do |i|
      i<=rounds
    end

  end

  def run_while!(reporting=false)

    print "\033[1;32m===== INITIAL STATE =====\e[00m\n\n" if reporting

    puts self if reporting

    i=1

    while yield i do
      print "======= ROUND #{i} =======\n\n" if reporting
      run_round! reporting
      i+=1
    end

    print "\033[1;32m====== FINAL STATE ======\e[00m\n\n" if reporting

    puts self if reporting

    print "\033[1;31m========== END ==========\e[00m\n\n" if reporting

    self

  end

  def to_s
    nodes.reduce("") { |carry, n| carry+n.to_s }
  end

  private

  def run_round!(reporting=false)

    nodes.shuffle.each do |node|
      node.stage! reporting
    end

    nodes.each{ |n| n.commit! }

    puts nodes if reporting
  end

  def nodes
    @nodes
  end

  def nodes=(what)
    @nodes=what
  end

  def edges
    @edges
  end

  def edges=(what)
    @edges=what
  end

end
