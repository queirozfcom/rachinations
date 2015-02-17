require_relative '../../../lib/rachinations/domain/diagrams/diagram'
require_relative 'bad_dsl'
require_relative 'helpers/parser'

# Bootstraping a diagram using the DiagramShorthandMethods
module DSL
  module Bootstrap

    def diagram(name='new_diagram', mode: :default, &blk)

      supported_modes = [:default, :silent, :verbose]

      raise BadDSL, "Unknown diagram mode: #{mode.to_s}" unless supported_modes.include? mode

      # right now silent and default are the same thing
      if mode == :default || mode == :silent
        dia= Diagram.new(Parser.validate_name!(name))
      elsif mode == :verbose || mode == 'verbose'
        dia = VerboseDiagram.new(Parser.validate_name!(name))
      end

      # This is a modified version of Diagram#add_edge!. It defers some method
      #   calls that involve other nodes until after the end of the block that
      #   builds the diagram. this is done because, when these options are set,
      #   the nodes may not have been created yet.
      # @param [Class] the edge class. probably Edge
      # @param [Hash] params params to be passed to the constructor of given class
      def dia.add_edge!(edge_klass, params)

        params.store(:diagram, self)

        from_node_name = params.fetch(:from)
        to_node_name = params.fetch(:to)

        edge = edge_klass.new(params)

        # this method may contain nodes that may not yet exist
        edge_attach_from = lambda do |edge, node_name, diagram|
          # ask the diagram to evaluate what node it is
          node = diagram.get_node(node_name)
          node.attach_edge!(edge)
          edge.from = node
        end

        # this method may contain nodes that may not yet exist
        edge_attach_to = lambda do |edge, node_name, diagram|
          # ask the diagram to evaluate what node it is
          node = diagram.get_node(node_name)
          node.attach_edge!(edge)
          edge.to = node
        end

        # so they need to be scheduled and run later
        schedule_task(edge_attach_from, edge, from_node_name, self)
        schedule_task(edge_attach_to, edge, to_node_name, self)

        edges.push(edge)

        self

      end

      def dia.add_node!(node_klass, params)

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

        unless triggered_by.nil?

          attach_trigger_task = lambda do |triggeree, triggerer_name, diagram|
            # ask the diagram to evaluate what node it is
            triggerer = diagram.get_node(triggerer_name)
            triggerer.attach_trigger(triggeree)
          end
          schedule_task(attach_trigger_task, node, triggered_by, self)

        end

        unless triggers.nil?

          attach_trigger_task = lambda do |triggerer, triggeree_name, diagram|
            # ask the diagram to evaluate what node it is
            triggeree = diagram.send(triggeree_name.to_sym)
            triggerer.attach_trigger(triggeree)
          end
          schedule_task(attach_trigger_task, node, triggers, self)

        end

        nodes.push(node)

        self

      end

      # after defining all those methods we run
      dia.instance_eval(&blk)
      dia.run_scheduled_tasks

      dia

    end

    # This is just a convenience method to create a proc in a way that's more
    #  intuitive for ends users.
    # @example Create a proc, equivalent to proc{|x| x+1 }
    #   expr{|x| x+1 }
    def expr(&blk)
      if !block_given?
        raise ArgumentError, "expected a block, but none was given"
      else
        Proc.new(&blk)
      end
    end
  end
end