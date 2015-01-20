require_relative '../../domain/modules/common/invariant'
require_relative '../edge_collection'
require_relative '../node_collection'

class Diagram

  include Invariant

  attr_accessor :name, :max_iterations, :nodes, :edges

  def initialize(name='Anonymous diagram')
    @nodes = NodeCollection.new
    @edges = EdgeCollection.new
    @name = name
    @max_iterations = 999
  end


  def get_node(name)

    nodes.each do |node|
      if node.name == name
        return node
      end
    end

    raise RuntimeError, "Node with name='#{name}' not found."
  end

  def get_edge(name)
    edges.each do |edge|
      if edge.name == name
        return edge
      end
    end

    raise RuntimeError, "Edge with name='#{name}' not found."
  end

  def add_node!(node_klass, params)

    params.store(:diagram, self)

    # if there's a condition, return it, otherwise return default condition
    condition = params.delete(:condition) { lambda { true } }

    # similarly, if nodes are supposed to be triggered by another node
    triggered_by = params.delete(:triggered_by) { nil }

    # akin to :triggered_by, but it's defined in the triggerER
    # rather than in the trigerrEE
    triggers = params.delete(:triggers) { nil }

    node = node_klass.new(params)

    node.attach_condition &condition

    if !triggered_by.nil?
      # ask the current class (diagram) to evaluate what node it is
      triggerer = self.send(triggered_by.to_sym)
      triggerer.attach_trigger(node)
    end

    if !triggers.nil?
      # ask the current class (diagram) to evaluate what node it is
      triggeree = self.send(triggers.to_sym)
      node.attach_trigger(triggeree)
    end

    nodes.push(node)

    self

  end

  def add_edge!(edge_klass, params)

    params.store(:diagram, self)

    #we need to send the actual nodes, not their names
    from = get_node(params.delete(:from))
    to = get_node(params.delete(:to))

    params.store(:from, from)
    params.store(:to, to)

    edge = edge_klass.new(params)

    from.attach_edge!(edge)
    to.attach_edge!(edge)

    edges.push(edge)

    self
  end

  def run!(rounds=5)

    run_while! do |i|
      i<=rounds
    end

  end

  # Runs the diagram until given block returns false
  #
  # @yieldparam i [Fixnum] The current round.
  # @yieldreturn [Boolean] True if diagram should keep on running, false if it should stop.
  # @return [Diagram] The diagram itself.
  def run_while!

    before_run

    i=1

    # if given condition block turned false, it's time to stop
    while yield i do

      break unless sanity_check? i

      before_round i

      if i == 1
        # some things are different for the first round, namely nodes with activation = start
        run_first_round!
      else
        run_round!
      end

      after_round i
      i+=1
    end

    after_run

    self

  end


  def resource_count(klass=nil)
    total=0
    @nodes.each do |n|
      total+=n.resource_count(type: klass)
    end
    total
  end

  private

  def to_s
    nodes.reduce('') { |carry, n| carry+n.to_s }
  end

  def sanity_check?(round_no)
    if round_no > @max_iterations
      sanity_check_message
      false
    else
      true
    end
  end

  def run_first_round!

    enabled_nodes.select { |node| node.automatic? || node.start? }.shuffle.each { |node| node.trigger! }

    commit_nodes!

  end

  def run_round!

    enabled_nodes.select { |node| node.automatic? }.shuffle.each { |node| node.trigger! }

    commit_nodes!

  end

  def commit_nodes!
    #only after all nodes have run do we update the actual resources and changes, to be used in the next round.
    nodes.shuffle.each { |node| node.commit! }

  end

  def enabled_nodes
    nodes.select { |node| node.enabled? }

  end

  #template method
  def before_round(node_no)
  end

  #template method
  def after_round(node_no)
  end

  #template method
  def before_run;
  end

  #template method
  def after_run;
  end

  #template method
  def sanity_check_message;
  end

end
