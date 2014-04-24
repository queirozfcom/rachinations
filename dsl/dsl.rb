require_relative '../domain/diagrams/diagram'
require_relative '../domain/diagrams/verbose_diagram'
require_relative '../domain/diagrams/non_deterministic_diagram'
require_relative '../domain/modules/verbose'

module DSL

  class ::Diagram

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


   def diagram(name,verbose=:silent,&blk)

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
     if verbose === :verbose
       dia.extend(Verbose)
     end

     dia.instance_eval &blk

     dia

   end

  #add these methods to existing class Diagram here
  #because it doesn't need to know about it



end