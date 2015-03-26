require 'fraction'

module Utils
  module MathUtils

    # Returns an array containing references to the objects, in the correct
    #   order, such that it can be used to represent the minimum possible cycle
    #   that can be implemented using these objects.
    # 
    # @example Simple example
    #   {"foo"=>3,"bar"=>2} yields ["foo","foo","foo","bar","bar"]
    # @param [Hash<Object,Numeric>] weights A hash where the keys are
    #   objects and the values their respective weights
    # @return [Array[Object]] the lineup for the given weight hash
    def self.get_cycle_lineup(weights)
      raise ArgumentError.new('Weights should be supplied as a Hash') unless weights.is_a?(Hash)
      raise ArgumentError.new('Weights should be numbers') unless weights.values.all?{|v| v.is_a?(Fixnum) || v.is_a?(Float) }

      if weights.values.all?{|v| v.is_a?(Fixnum) }
        get_integer_lineup(weights)
      elsif weights.values.all?{|v| v.is_a?(Float) }
        get_float_lineup(weights)
      end

    end

    # takes an enumerable of fractions
    def self.add_up_to_one?(fractions)

      numerators = fractions.map{|el| el[0] }
      denominators = fractions.map{|el| el[1] }

      # lowest_common_multiple
     # lcm(denominators)

      sum=numerators.map.with_index do |elem,i|
        multiplier = (lcm(denominators) / denominators[i]).to_i
        multiplier * elem
      end.reduce(:+)

      sum == lcm(denominators)

    end

    private

    # used when weights are integers
    def self.get_integer_lineup(weights)
      weights.reduce(Array.new) do |acc,(key,val)|
        val.times{|i| acc.push(key) }
        acc
      end
    end

    # used when weights are floats (will be turned to fractions)
    def self.get_float_lineup(weights)
      weights_as_fractions = weights.reduce(Hash.new){|acc,(key,val)| acc[key] = val.to_fraction(100); acc }
      raise RuntimeError('Fractional weights must add up to one') unless add_up_to_one?(weights_as_fractions.values)

      lcm = lcm(weights_as_fractions.values.map{|el| el[1] } )

      # the higher its weight, the more times the object appears
      weights_as_fractions.reduce(Array.new) do |acc,(key,val)|
        numerator = val[0]
        denominator = val[1]
        error = val[2] # not used so far
        appearances = ( (lcm / denominator) * numerator ).to_i

        # one reference for each appearance
        appearances.times{ acc.push(key) }
        acc
      end

    end

    def self.lcm(integers)
      integers.reduce do |acc,elem|
        acc.to_i.lcm(elem)
      end
    end

  end
end