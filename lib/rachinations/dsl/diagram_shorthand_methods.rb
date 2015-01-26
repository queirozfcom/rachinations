require_relative '../domain/diagrams/diagram'
require_relative '../domain/diagrams/verbose_diagram'
require_relative '../domain/diagrams/non_deterministic_diagram'
require_relative '../domain/modules/diagrams/verbose'
require_relative '../domain/modules/common/refiners/proc_convenience_methods'
require_relative './bad_dsl'
require_relative '../utils/string_helper'
require_relative 'helpers/parser'

module DSL

  module DiagramShorthandMethods

    using ProcConvenienceMethods

    # if you can turn this into a refiner and still keep all tests passing,
    # send a PR for me :smile:
    class ::Diagram

      alias_method :run, :run!

      def pool(*args)

        hash = Parser.parse_arguments(args)

        add_node! Pool, hash

      end

      def source(*args)

        hash = Parser.parse_arguments(args)

        add_node! Source, hash

      end

      def sink(*args)

        hash = Parser.parse_arguments(args)

        add_node! Sink, hash

      end

      def converter(*args)

        hash = Parser.parse_arguments(args)

        add_node! Converter, hash

      end

      def trader(*args)

        hash = Parser.parse_arguments(args)

        add_node! Trader, hash

      end

      def gate(*args)
        # gate is different because it doesn't take some arguments
        hash = Parser.parse_gate_arguments(args)

        add_node! Gate, hash

      end

      # methods to create edges
      def edge(*args)

        hash = Parser.parse_edge_arguments(args)

        add_edge! Edge, hash

      end

      # so that I can easily access elements which have been given a name
      # (mostly nodes and maybe edges too)
      def method_missing(method_sym, *args, &block)
        super if method_sym.to_s == 'anonymous' #these aren't actual node names

        begin
          #does a node with that name exist?
          node=get_node(method_sym.to_s)
        rescue RuntimeError => err_node
          #what about an edge?
          begin
            edge = get_edge(method_sym.to_s)
          rescue RuntimeError => err_edge
            #no luck, sorry
            super
          else
            edge
          end
        else
          node
        end
      end

    end

  end

end