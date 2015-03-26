require 'fraction'

module Helpers
  module EdgeHelper
    MathUtils = ::Utils::MathUtils

    # Returns true if all edges passed as arguments can execute a push
    #  when called in the same round. The difference between calling this
    #  method and calling Edge#test_ping? on each edge is that this method
    #  knows that each edge removes at least one Resource when it performs
    #  a push.
    # @param [Enumerable<Edge>] edges the edges
    # @param [Boolean] require_all whether to require that the maximum amount
    #  of resources supported by each edge (i.e. its label) be available in
    #  order to succeed.
    # @return [Boolean]
    def self.all_can_push?(edges, require_all: false)
      initial = {
          partial_success: true,
          number_of_resources: 0
      }

      raise ::NotImplementedError, 'only require_all is implemented so far' unless require_all

      final = edges.inject(initial) do |acc, elem|

        edge = elem

        acc[:number_of_resources] += edge.label

        resources_available = edge.from.resource_count(expr: edge.push_expression)

        if resources_available >= acc[:number_of_resources]
          acc[:partial_success] &&= true
        else
          acc[:partial_success] &&= false
        end
        acc
      end

      final[:partial_success]

    end

    # Validates that labels are consistent
    def self.labels_valid?(edges)
      all_labels_integer?(edges) || (all_labels_float?(edges) && float_labels_add_up_to_one?(edges))
    end

    def self.all_labels_of_same_kind?(edges)
      all_labels_integer?(edges) || all_labels_float?(edges)
    end

    # maybe returns an edge
    def self.pick_one(edges:, mode:, index: nil)
      raise ::RuntimeError.new('Labels must be of the same kind') unless all_labels_of_same_kind?(edges)
      raise ::RuntimeError.new('Unknown mode') unless [:deterministic, :probabilistic].include?(mode)

      if edges.empty?
        nil
      else
        if mode === :deterministic
          pick_next(edges, index)
        elsif mode === :probabilistic
          pick_any(edges)
        end
      end
    end

    private

    def self.pick_next(edges, index)
      raise ::ArgumentError.new('Invalid index: '+index) unless index.is_a?(Fixnum)


      frequency_hash = edges.reduce(Hash.new) do |acc,elem|
        acc[elem] = elem.label
        acc
      end

      edge_lineup = MathUtils.get_cycle_lineup(frequency_hash)
      normalized_index = index % edge_lineup.size

      edge_lineup[normalized_index]
    end

    # pick one edge according to weights, if any
    def self.pick_any(edges)

      if  all_labels_integer?(edges) && edges.all? { |e| e.label == 1 }
        #edges is probably an enumerable but only arrays can be sample()'d
        edges.to_a.sample
      elsif all_labels_float?(edges)
        #{edge=>weight} is the shape required by WeightedDistribution
        weights = edges.reduce(Hash.new) { |acc, el| acc[el] = el.label; acc }

        sum_of_labels = edges.reduce(0) { |acc, el| acc + el.label }

        remaining = 1.0 - sum_of_labels

        # chances that a resource 'vanishes'
        weights[nil] = remaining

        WeightedDistribution.new(weights).sample

      elsif all_labels_integer?(edges)

        sum_of_labels = edges.reduce(0) { |acc, el| acc + el.label }

        # since labels are integers, we must normalize them to get probablities
        weights = edges.reduce(Hash.new) { |acc, el| acc[el] = el.label/sum_of_labels; acc }

        WeightedDistribution.new(weights).sample

      else
        raise RuntimeError.new('Invalid setup')
      end
    end

    def self.all_labels_integer?(edges)
      edges.all? { |e| e.label.is_a?(Fixnum) }
    end

    def self.all_labels_float?(edges)
      edges.all? { |e| e.label.is_a?(Float) }
    end

    def self.float_labels_add_up_to_one?(edges)

      labels_as_fractions = edges.reduce(Array.new){|acc,el| acc.push(el.label.to_fraction(100)); acc }

      MathUtils.add_up_to_one?(labels_as_fractions)

    end

  end
end