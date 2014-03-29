require_relative '../domain/diagram'

module DSL

  def diagram(name, &blk)
    dia = Diagram.new name
    dia.instance_eval &blk

    dia

  end

  #add these methods to existing class Diagram here
  #because it doesn't need to know about it

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

end