require_relative 'modules/invariant'
require_relative 'edge'
require_relative 'node'
require_relative 'pool'
require_relative 'source'
require_relative 'resource'
require_relative 'node_collection'
require_relative 'edge_collection'

#noinspection RubyArgCount
class Diagram
  include Invariant


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
  def add_node!(node)
    nodes.push(node)
    nil
  end

  #destrutivo
  def add_edge!(edge)
    edges.push(edge)
    nil
  end

  def add_node(node)
    copy = self.clone
    copy.add_node!(node)
    copy
  end

  def add_edge(edge)
    copy = self.clone
    copy.add_edge!(edge)
    copy
  end

  def run!(rounds=5)
    rounds.times { run_round! }
  end

  private

  def run_round!

    post_execution_nodes = nodes.map { |el| el.clone }

    #only automatic nodes cause changes in other nodes
    automatic_nodes.each do |node|
      post_execution_nodes = perform_action node, post_execution_nodes
    end

    self.nodes = post_execution_nodes

  end

  def perform_action(node, current_round_nodes)

    # if this node is in push mode and has arrows pointing
    # away from it, we need to send resources, if available.
    if node.push?

      edges
      .select { |edge| edge.connects? node.name }
      .each do |edge|

        if node.typed?

          #each resource type gets individual treatment

          node.each_type do |key|

            available_resources = node.resource_count(key)

            if available_resources > 0

              if edge.has_type?(key) && current_round_nodes.detect { |n| n.name == edge.to_node_name }.has_type?(key)
                #resources leave and arrive on the other side
                node.remove_resource!(key)
                current_round_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!(key)
              elsif edge.has_type?(key) && !current_round_nodes.detect { |n| n.name == edge.to_node_name }.has_type?(key)
                #resources leave but don't arrive on the other side
                node.remove_resource!(key)
              else
                #if edge doesn't allow this type, nothing gets done - resources don't even leave base
              end

            else
              #no resources of this type to send, do nothing.
            end
          end
        else
          # just numbers, business as usual

          available_resources = node.resource_count

          if available_resources > 0
            current_round_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!
            current_round_nodes.detect { |n| n.name == node.name }.remove_resource!
            # in case this inner loop runs more than once (if there is more than one edge pointing away from this node)
            # does decrement make sense? in other iterations it'll just get assigned again like in line (this - 6), no?
            available_resources -= 1
          end

        end

      end

      #finding out if there's anything to pull to this node
    elsif node.mode == :pull

      edges
      .select { |edge| edge.connects? node.name }
      .each do |edge|

        # will be run for each edge pointing *to* Node node

        from_node = nodes.detect { |n| n.name == edge.from_node_name }

        if from_node.automatic? && from_node.push?
          next #otherwise this is done twice
        end

        if node.typed?
          #each resource type gets individual treatment, as with push (case above)

          #the target node is now calling the shots
          #so only types *it* has are considered
          node.types.each do |key|

            if from_node.has_type?(key)

              available_resources = from_node.resource_count(key)

              if available_resources > 0

                if edge.has_type?(key) && nodes.detect { |n| n.name == edge.from_node_name }.has_type?(key)
                  #resources leave and arrive on the other side
                  from_node.remove_resource!(key)
                  current_round_nodes.detect { |n| n.name == node.name }.add_resource!(key)
                elsif edge.has_type?(key) && !post_execution_nodes.detect { |n| n.name == edge.to_node_name }.has_type?(key)
                  #resources leave but don't arrive on the other side
                  from_node.remove_resource!(key)
                else
                  #if edge doesn't allow this type, nothing gets done - resources don't even leave base
                end

              else
                #no resources of this type to send, do nothing.
              end
            else
              #from node doesn't have this type, do nothing.
            end
          end

        else #no types

          available_resources = from_node.resource_count

          if available_resources > 0
            current_round_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!
            current_round_nodes.detect { |n| n.name == from_node.name }.remove_resource!
          end

        end

      end

    end

    current_round_nodes

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
    self.edges=what
  end

  def automatic_nodes
    nodes.select { |node| node.activation === :automatic }
  end

  def passive_nodes
    nodes.select { |node| node.activation === :passive }
  end

end
