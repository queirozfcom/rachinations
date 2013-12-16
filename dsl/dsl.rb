require_relative '../models/diagram'

module DSL

  def diagram name, &blk
    dia = Diagram.new name
    dia.instance_eval &blk
  end

  #add these methods to class Diagram just to make it cleaner

  class Diagram

    def node(name,klass,hsh={})

      add_node! klass.new(name,hsh)

    end

    def edge(name,klass,from,to,hsh)

      edge_to_add = =


    end

  end

end