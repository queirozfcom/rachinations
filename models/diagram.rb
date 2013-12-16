require_relative 'edge'
require_relative 'node'
require_relative 'pool'
require_relative 'source'
require_relative 'resource'


class Diagram

  def initialize(name)
    @nodes = Array.new
    @edges = Array.new
    @name = name
  end

  def get_node(name)
    @nodes.each do |node|
      if node.name == name
        return node
      end
    end

    raise RuntimeError, "Node with name='#{name}' not found."
  end

  #destrutivo
  def add_node!(node)
    @nodes.push(node)
    nil
  end

  #destrutivo
  def add_edge!(edge)
    @edges.push(edge)
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
    rounds.times { |i| run_round!(i) }
  end

  private

  def run_round!(round_number)

    post_execution_nodes = @nodes.map { |el| el.clone }
    post_execution_edges = @edges.map { |el| el.clone }

    #only automatic nodes cause changes in other nodes
    @nodes
    .select { |node| node.activation === :automatic }
    .each do |node|

      # if this node is in push mode and has arrows pointing
      # away from it, we need to send resources, if available.

      if node.mode === :push


        @edges
        .select { |edge| edge.from_node_name == node.name }
        .each do |edge|

          if  node.typed?

            #each resource type gets individual treatment

            node.types.each do |key|


              available_resources = node.resource_count(key)

              p node

              if available_resources > 0

                if edge.has_type?(key) && post_execution_nodes.detect { |n| n.name == edge.to_node_name }.has_type?(key)
                  #resources leave and arrive on the other side
                  node.remove_resource!(key)
                  post_execution_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!(key)
                elsif edge.has_type?(key) && !post_execution_nodes.detect { |n| n.name == edge.to_node_name }.has_type?(key)
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
              post_execution_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!
              post_execution_nodes.detect { |n| n.name == node.name }.remove_resource!
              # in case this inner loop runs more than once (if there is more than one edge pointing away from this node)
              available_resources -= 1
            end

          end

        end

        #finding out if there's anything to pull to this node
      elsif node.mode == :pull

        @edges
        .select { |edge| edge.to_node_name == node.name }
        .each do |edge|

          from_node = @nodes.detect { |n| n.name == edge.from_node_name }

          available_resources = from_node.resource_count

          if available_resources > 0
            post_execution_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!
            post_execution_nodes.detect { |n| n.name == from_node.name }.remove_resource!
          end

        end

      end

    end

#@nodes = post_execution_nodes
#@edges = post_execution_edges
#print "\n"
#p "Round Number #{round_number}:"
#@nodes.each { |n| p n }
#print "\n"

  end

end
