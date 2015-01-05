require_relative '../domain/diagrams/diagram'
require_relative '../domain/diagrams/verbose_diagram'
require_relative '../domain/diagrams/non_deterministic_diagram'
require_relative '../domain/modules/diagrams/verbose'
require_relative '../domain/modules/common/refiners/proc_convenience_methods'
require_relative './bad_dsl'
require_relative '../utils/string_helper'
require_relative 'helpers/parser'

module DSL
  using ProcConvenienceMethods

  # this isn't a refiner because there are some methods (like diagram) which shouldn't be
  # added to the Diagram class itself, but to the global scope instead.
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

  # These methods aren't within the refiner because they aren't methods
  # on class Diagram but rather 'global' methods.

  def diagram(name='new_diagram', mode: :silent, &blk)

    # cant verbose be a simple boolean instead?
    if mode == :silent || mode == 'silent'
      dia= Diagram.new(Parser.validate_name!(name))
    elsif mode == :verbose || mode == 'verbose'
      dia = VerboseDiagram.new(Parser.validate_name!(name))
    else
      raise BadDSL, "Unknown diagram mode: #{mode.to_s}"
    end

    # methods in the block get run as if they were called on
    # the diagram itself
    dia.instance_eval &blk

    dia

  end


  def non_deterministic_diagram(name, verbose=:silent, &blk)

    dia=NonDeterministicDiagram.new(Parser.validate_name!(name))

    # cant verbose be a simple boolean instead?
    if verbose === :verbose
      dia.extend(Verbose)
    end

    dia.instance_eval &blk

    dia

  end

  # This is just a convenience method to create a proc in a way that's more
  #  intuitive for ends users.
  # @example Create a proc, equivalent to proc{|x| x+1 }
  #   expr{|x| x+1 }
  def expr(&blk)
    if !block_given?
      raise BadDSL, "expected a block, but none was given"
    else
      Proc.new(&blk)
    end
  end

end