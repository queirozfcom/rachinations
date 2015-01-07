module Helpers
  module EdgeHelper

    # Returns true if all edges passed as arguments can execute a push
    #  when called in the same round. The difference between calling this
    #  method and calling Edge#test_ping? on each edge is that this method
    #  knows that each edge removes at least one Resource when it performs
    #  a push.
    # @param [Array<Edge>] edges the edges
    # @param [Boolean] require_all whether to require that the maximum amount
    #  of resources supported by each edge (i.e. its label) be available in
    #  order to succeed.
    # @return [Boolean]
    def self.all_can_push?(edges, require_all: false)
      initial = {
          partial_success: true,
          number_of_resources: 0
      }

      raise NotImplementedError, 'only require_all is implemented so far' unless require_all

      final = edges.inject(initial) do |accumulator, edge|
        accumulator[:number_of_resources] += edge.label

        resources_available = edge.from.resource_count(expr: edge.push_expression)

        if resources_available >= accumulator[:number_of_resources]
          accumulator[:partial_success] &&= true
        else
          accumulator[:partial_success] &&= false
        end
        accumulator
      end

      final[:partial_success]

    end

  end
end