require_relative '../domain/diagrams/diagram'
require_relative '../domain/diagrams/verbose_diagram'
require_relative '../domain/diagrams/non_deterministic_diagram'
require_relative '../domain/modules/diagrams/verbose'
require_relative '../utils/string_helper'

module DSL

  # this isn't a refiner because there are some methods (like diagram) which shouldn't be
  # added to the Diagram class itself, but to the global scope instead.
  class ::Diagram

    alias_method :run, :run!


    def pool(name='anonymous', initial_value: 0, mode: :pull_any, activation: :passive, triggered_by: nil, condition: lambda { true })

      hsh = {}
      hsh[:name] = validate_name!(name)
      hsh[:initial_value] = initial_value
      hsh[:mode] = mode
      hsh[:activation] = activation
      hsh[:condition] = condition
      hsh[:triggered_by] = triggered_by

      add_node! Pool, hsh


    end

    def source(name= 'anonymous', mode: :push_any, activation: :automatic, triggered_by: nil, condition: lambda { true })

      hsh = {}
      hsh[:name] = validate_name!(name)
      hsh[:mode] = mode
      hsh[:activation] = activation
      hsh[:condition] = condition
      hsh[:triggered_by] = triggered_by
      add_node! Source, hsh

    end

    def sink(name='anonymous', mode: :pull_any, activation: :passive, triggered_by: nil, condition: lambda { true })

      hsh = {}
      hsh[:name] = validate_name!(name)
      hsh[:mode] = mode
      hsh[:activation] = activation
      hsh[:condition] = condition
      hsh[:triggered_by] = triggered_by

      add_node! Sink, hsh

    end

    def converter(name='anonymous', mode: :pull_any, activation: :passive, triggered_by: nil, condition: lambda { true })

      hsh = {}
      hsh[:name] = validate_name!(name)
      hsh[:mode] = mode
      hsh[:activation] = activation
      hsh[:condition] = condition
      hsh[:triggered_by] = triggered_by

      add_node! Converter, hsh

    end

    def trader(name='anonymous', mode: :pull_any, activation: :passive, triggered_by: nil, condition: lambda { true })

      hsh = {}
      hsh[:name] = validate_name!(name)
      hsh[:mode] = mode
      hsh[:activation] = activation
      hsh[:condition] = condition
      hsh[:triggered_by] = triggered_by

      add_node! Trader, hsh

    end

    def gate(name='anonymous', activation: :passive, triggered_by: nil, condition: lambda { true })

      hsh = {}
      hsh[:name] = validate_name!(name)
      hsh[:activation] = activation
      hsh[:condition] = condition
      hsh[:triggered_by] = triggered_by

      add_node! Gate, hsh

    end

    # methods to create edges
    def edge(name='anonymous', label: 1, from:, to:)

      hsh = {}
      hsh[:name] = validate_name!(name)
      hsh[:label] = label
      hsh[:from] = from
      hsh[:to] = to

      add_edge! Edge, hsh

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

    def node(name, klass, hsh={})

      hsh[:name] = name

      add_node! klass, hsh
    end

    # def edge(name, klass, from, to, hsh={})
    #
    #   hsh[:name] = name
    #   hsh[:from] = from
    #   hsh[:to] = to
    #
    #   add_edge! klass, hsh
    # end

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

  private

  def validate_name!(name)
    if StringHelper.valid_ruby_variable_name?(name)
      name
    else
      raise BadDSL.new("Invalid name: '#{name}'")
    end
  end

  #add these methods to existing class Diagram here
  #because it doesn't need to know about it


end