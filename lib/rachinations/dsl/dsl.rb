require_relative '../domain/diagrams/diagram'
require_relative '../domain/diagrams/verbose_diagram'
require_relative '../domain/diagrams/non_deterministic_diagram'
require_relative '../domain/modules/diagrams/verbose'

module DSL

  # this isn't a refiner because there are some methods (like diagram) which shouldn't be
  # added to the Diagram class itself, but added to the global scope.
  class ::Diagram


    # methods to create nodes
    # I would probably not need so many method if I used metaprogramming
    def pool(name: 'anonymous',initial_value:0,mode: :pull_any, activation: :passive)

      hsh = {}
      hsh[:name] = name
      hsh[:initial_value] = initial_value
      hsh[:mode] = mode
      hsh[:activation] = activation

      add_node! Pool, hsh

    end

    def source(name: 'anonymous',mode: :push_any, activation: :automatic)

      hsh = {}
      hsh[:name] = name
      hsh[:mode] = mode
      hsh[:activation] = activation

      add_node! Source, hsh

    end

    def sink(name: 'anonymous',mode: :pull_any, activation: :passive)

      hsh = {}
      hsh[:name] = name
      hsh[:mode] = mode
      hsh[:activation] = activation

      add_node! Sink, hsh

    end

    def converter(name: 'anonymous',mode: :pull_any, activation: :passive)

      hsh = {}
      hsh[:name] = name
      hsh[:mode] = mode
      hsh[:activation] = activation

      add_node! Converter, hsh

    end

    def trader(name: 'anonymous',mode: :pull_any, activation: :passive)

      hsh = {}
      hsh[:name] = name
      hsh[:mode] = mode
      hsh[:activation] = activation

      add_node! Trader, hsh

    end

    def gate(name: 'anonymous', activation: :passive)

      hsh = {}
      hsh[:name] = name
      hsh[:activation] = activation

      add_node! Gate, hsh

    end

    # methods to create edges
    def edge(name: 'anonymous',label: 1)

      hsh = {}
      hsh[:name] = name
      hsh[:label] = label

      add_edge! Edge, hsh

    end


    # so that I can easily access elements which have been given a name
    # (mostly nodes and maybe edges too)
    def method_missing(method_sym,*args,&block)
      super unless method_sym.to_s != 'anonymous' #these aren't actual node names

      begin
        #does a node with that name exist?
        element=get_node(method_sym.to_s)
      rescue RuntimeError => err_node
        #what about an edge?
        begin
          element = get_edge(method_sym.to_s)
        rescue RuntimeError => err_edge
          #no luck, sorry
          super
        else
          element
        end
      else
        element
      end

    end

    # convenience method
    def node(name,klass,hsh={})

      hsh[:name] = name

      add_node! klass, hsh
    end

    # convenience method
    def edge(name,klass,from,to,hsh={})

      hsh[:name] = name
      hsh[:from] = from
      hsh[:to] = to

      add_edge! klass,hsh
    end

  end


   def diagram(name='new diagram',verbose=:silent,&blk)

    # cant verbose be a simple boolean instead?
    if verbose === :verbose
      dia= VerboseDiagram.new name
    else
      dia = Diagram.new name
    end

    dia.instance_eval &blk

    dia

   end

   def non_deterministic_diagram(name,verbose=:silent,&blk)

     dia=NonDeterministicDiagram.new name

     # cant verbose be a simple boolean instead?
     if verbose === :verbose
       dia.extend(Verbose)
     end

     dia.instance_eval &blk

     dia

   end

  #add these methods to existing class Diagram here
  #because it doesn't need to know about it



end