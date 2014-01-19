require_relative '../domain/diagram'

module DSL

  def diagram(name, &blk)
    dia = Diagram.new name
    dia.instance_eval &blk
  end

  #add these methods to existing class Diagram here
  #because it doesn't need to know about it
  class ::Diagram

    # convenience method
    def node(name,klass,hsh={})

      add_node! klass.new(name,hsh)
    end

    # convenience method
    def edge(name,klass,from,to,hsh={})

      add_edge!(klass.new(name,from,to,hsh))
    end

  end

end