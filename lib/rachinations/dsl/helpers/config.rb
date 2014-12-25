require_relative '../../domain/modules/common/refiners/proc_convenience_methods'
module DSL

  # This module has elements that are used in the main DSL module
  module Config
    using ProcConvenienceMethods

    # these patterns (*_EXPR) define what each parameter should look like

    IDENTIFIER_EXPR = proc { |arg| arg.is_a?(String) && valid_name?(arg) }

    INITIAL_VALUE_EXPR = proc { |arg| arg.is_a? Fixnum }

    MODE_EXPR = proc { |arg| [:pull_any, :pull_all, :push_any, :push_all].include? arg }

    ACTIVATION_EXPR = proc { |arg| [:automatic, :passive, :start].include? arg }

    PROC_EXPR = proc{ |arg| arg.is_a? Proc }

    def self.parse_arguments(arguments)
      arguments.inject(Hash.new) do |accumulator, arg|

        # we need to find out what parameter this is, since they are in
        # no particular order

        # named parameters are expressed are hashes
        if arg.is_a? Hash
          if arg.has_key? :condition
            accumulator[:condition] = arg[:condition] if PROC_EXPR.match?(arg[:condition])
          elsif arg.has_key? :triggered_by
            accumulator[:triggered_by] = arg[:triggered_by] if IDENTIFIER_EXPR.match?(arg[:triggered_by])
          end
        else
          if IDENTIFIER_EXPR.match?(arg)
            accumulator[:name] = arg
          elsif INITIAL_VALUE_EXPR.match?(arg)
            accumulator[:initial_value] = arg
          elsif MODE_EXPR.match?(arg)
            accumulator[:mode] = arg
          elsif ACTIVATION_EXPR.match?(arg)
            accumulator[:activation] = arg
          else
            raise BadDSL, "Option #{arg} doesn't fit any known signature"
          end
        end
        # passing the accumulator onto the next iteration
        accumulator
      end
    end

    def self.parse_gate_arguments(arguments)

      # mode is always pull_any so user can't choose it
      # initial_value makes no sense for gates either
      arguments.inject(Hash.new) do |accumulator, arg|
        if arg.is_a? Hash
          if arg.has_key? :condition
            accumulator[:condition] = arg[:condition] if PROC_EXPR.match?(arg[:condition])
          elsif arg.has_key? :triggered_by
            accumulator[:triggered_by] = arg[:triggered_by] if IDENTIFIER_EXPR.match?(arg[:triggered_by])
          end
        else
          if IDENTIFIER_EXPR.match?(arg)
            accumulator[:name] = arg
          elsif ACTIVATION_EXPR.match?(arg)
            accumulator[:activation] = arg
          else
            raise BadDSL, "Option #{arg} doesn't fit any known signature"
          end
        end
        accumulator
      end

    end

    # returns true for integers or floats
    LABEL_EXPR = proc { |arg| arg.is_a? Numeric }

    def self.parse_edge_arguments(arguments)

      arguments.inject(Hash.new) do |accumulator, arg|
        if IDENTIFIER_EXPR.match?(arg)
          accumulator[:name] = arg
        elsif LABEL_EXPR.match?(arg)
          accumulator[:label]=arg
        elsif arg.is_a? Hash

          if arg.has_key? :from
            accumulator[:from] = arg[:from]
          end

          if arg.has_key? :to
            accumulator[:to] = arg[:to]
          end
        end
        accumulator
      end

    end

    def self.valid_name?(name)
      StringHelper.valid_ruby_variable_name?(name)
    end

  end

end
