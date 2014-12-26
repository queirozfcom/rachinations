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

      hash = DSL::Parser.parse_arguments(args)

      add_node! Pool, hash

    end

    def source(*args)

      hash = DSL::Parser.parse_arguments(args)

      add_node! Source, hash

    end

    def sink(*args)

      hash = DSL::Parser.parse_arguments(args)

      add_node! Sink, hash

    end

    def converter(*args)

      hash = DSL::Parser.parse_arguments(args)

      add_node! Converter, hash

    end

    def trader(*args)

      hash = DSL::Parser.parse_arguments(args)

      add_node! Trader, hash

    end

    def gate(*args)
      # gate is different because it doesn't take some arguments
      hash = DSL::Parser.parse_gate_arguments(args)

      add_node! Gate, hash

    end

    # methods to create edges
    def edge(*args)

      hash = DSL::Parser.parse_edge_arguments(args)

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


  def diagram(name='new_diagram', mode: :silent, &blk)

    # cant verbose be a simple boolean instead?
    if mode == :silent || mode == 'silent'
      dia= Diagram.new(validate_name!(name))
    elsif mode == :verbose || mode == 'verbose'
      dia = VerboseDiagram.new(validate_name!(name))
    else
      raise BadDSL, "Unknown diagram mode: #{mode.to_s}"
    end

    # methods in the block get run as if they were called on
    # the diagram itself
    dia.instance_eval &blk

    dia

  end


  def non_deterministic_diagram(name, verbose=:silent, &blk)

    dia=NonDeterministicDiagram.new(validate_name!(name))

    # cant verbose be a simple boolean instead?
    if verbose === :verbose
      dia.extend(Verbose)
    end

    dia.instance_eval &blk

    dia

  end


  def validate_name!(name)
    if StringHelper.valid_ruby_variable_name?(name)
      name
    else
      raise BadDSL, "Invalid name: '#{name}'"
    end
  end

end