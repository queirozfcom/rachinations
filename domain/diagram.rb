require_relative 'modules/invariant'
require_relative 'edge'
require_relative 'nodes/node'
require_relative 'nodes/extended_node'
require_relative 'nodes/pool'
require_relative 'nodes/source'
require_relative 'resource'
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
    params[:diagram] = self

    node = node_klass.new(params)

    nodes.push(node)

    nil
  end

  #destrutivo
  def add_edge!(edge_klass, params)

    #TODO assert that edge_klass responds_to the methods we're going to call

    params[:diagram] = self

    edge = edge_klass.new(params)

    edges.push(edge)

    nil
  end

  def run!(rounds=5,reporting=false)

    run_while!(reporting) do |i|
      i<=rounds
    end


  end

  def run_while!(reporting=false)


    print "\033[1;32m===== INITIAL STATE =====\e[00m\n\n" if reporting

    #run_round! reporting
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
    nodes.reduce(""){|carry,n| carry+n.to_s}
  end

  private
  
  def run_round!(reporting=false)

    post_execution_nodes = nodes.map { |el| el.clone }

#    print "======= NEW ROUND =======\n\n" if reporting
#    removed (now it is caller responsability)

    nodes.shuffle.each do |node|

      #puts node if reporting


      if node.passive?
        #only automatic nodes cause changes in other nodes
        next
      end

      # if this node is in push mode and has arrows pointing
      # away from it, we need to send resources, if available.
      if node.push?

        edges
        .select { |edge| edge.from? node.name }
        .shuffle
        .each do |edge|

          if node.typed?

            #each resource type gets individual treatment

            node.each_type do |key|

              if node.resource_count(key) > 0

                if edge.has_type?(key) && nodes.detect { |el| el.name==edge.to_node_name }.supports?(key)
                  #resources leave and arrive on the other side

                  post_execution_nodes.detect { |el| el.name == edge.from_node_name }.remove_resource!(key)
                  element = nodes.detect { |el| el.name == edge.from_node_name }.remove_resource!(key)

                  unless element.nil?
                    post_execution_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!(element)
                  end

                elsif edge.has_type?(key) && !nodes.detect { |el| el.name == edge.to_node_name }.supports?(key)
                  #resources leave but don't arrive on the other side
                  post_execution_nodes.detect { |el| el.name == edge.from_node_name }.remove_resource!(key)
                  nodes.detect { |el| el.name == edge.from_node_name }.remove_resource!(key)
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

              inv { node.eql?(nodes.detect { |node| node.name === edge.from_node_name }) }

              element = nil

              post_execution_nodes.detect { |el| el.name==node.name }.remove_resource!
              element = nodes.detect { |el| el.name==node.name }.remove_resource!

              unless element.nil?
                post_execution_nodes.detect { |el| el.name === edge.to_node_name }.add_resource!(element)
              end

              # in case this inner loop runs more than once (if there is more than one edge pointing away from this node)
              # does decrement make sense? in other iterations it'll just get assigned again like in line (this - 15), no?
              available_resources -= 1
            end

          end

        end

        #finding out if there's anything to pull to this node
      elsif node.pull?

        edges
        .select { |edge| edge.to? node.name }
        .shuffle
        .each do |edge|

          # will be run for each edge pointing *to* Node node

          from_node = nodes.detect { |el| el.name==edge.from_node_name }

          if from_node.automatic? && from_node.push?
            next #otherwise this is done twice
          end

          if node.typed?
            #each resource type gets individual treatment, as with push (case above)

            #the target node is now calling the shots
            #so only types *it* has are considered

            # TODO what if I'm of type X and I want to pull from a node of type Y, even though I can't receive it? shouldn't the resources leave node type Y regardless?


            node.each_type do |key|

              #node we are pulling resources FROM
              if from_node.supports?(key)

                available_resources = from_node.resource_count(key)

                if available_resources > 0

                  if edge.has_type?(key) && nodes.detect { |n| n.name == edge.from_node_name }.supports?(key)

                    #resources leave and arrive on the other side
                    post_execution_nodes.detect { |el| el.name === edge.from_node_name }.remove_resource!(key)
                    element = nodes.detect { |el| el.name === edge.from_node_name }.remove_resource!(key)

                    unless element.nil?
                      post_execution_nodes.detect { |n| n.name == node.name }.add_resource!(element)
                    end

                    #will this elseif ever be accessed? if the current target node doesn't have that type, then this loop was never entered (node.types.each, remember?)
                  elsif edge.has_type?(key) && !post_execution_nodes.detect { |n| n.name == edge.to_node_name }.support?(key)
                    #resources leave but don't arrive on the other side
                    post_execution_nodes.detect { |n| n.name == edge.from_node_name }.remove_resource!(key)
                    nodes.detect { |n| n.name == edge.from_node_name }.remove_resource!(key)
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

              post_execution_nodes.detect { |n| n.name == from_node.name }.remove_resource!
              element = nodes.detect { |n| n.name == from_node.name }.remove_resource!

              unless element.nil?
                post_execution_nodes.detect { |n| n.name == edge.to_node_name }.add_resource!(element)
              end

            end

          end

        end

      end

    end

    self.nodes = post_execution_nodes
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
