require_relative '../../domain/modules/common/refiners/proc_convenience_methods'
require_relative '../../extras/constant_hash'

module DSL

  # This module helps with parsing arguments used in the DiagramShorthandMethods
  module Parser
    using ProcConvenienceMethods

    ConstantHash = ::Extras::ConstantHash

    # these patterns define what each argument should look like

    IDENTIFIER = proc { |arg| arg.is_a?(String) && valid_name?(arg) }

    INITIAL_VALUE = proc { |arg| arg.is_a? Fixnum }

    MODE = proc { |arg| [:pull_any, :pull_all, :push_any, :push_all].include? arg }

    ACTIVATION= proc { |arg| [:automatic, :passive, :start].include? arg }

    PROC = proc { |arg| arg.is_a? Proc }

    LABEL = proc { |arg| arg.is_a?(Numeric) || arg.is_a?(Proc) }

    SHORT_STRING = proc { |arg| arg.is_a?(String) && arg.length.between?(1, 25) }

    # Parse an arbitrary list of arguments and returns a well-formed
    #  Hash which can then be used as argument to method add_node!
    # @param [Array] arguments an array of arguments.
    # @return [Hash] a well-formed hash
    def self.parse_arguments(arguments)
      arguments.inject(ConstantHash.new) do |accumulator, arg|

        # named parameters are expressed as hashes
        # and all arguments can (also) be passed as named parameters
        if arg.is_a? Hash

          if arg.has_key? :activation
            if ACTIVATION.match? arg[:activation]
              accumulator[:activation] = arg[:activation]
            else
              raise BadDSL.new
            end
          end

          if arg.has_key? :condition
            if PROC.match? arg[:condition]
              accumulator[:condition] = arg[:condition]
            else
              raise BadDSL.new
            end
          end

          if arg.has_key? :initial_value
            if INITIAL_VALUE.match? arg[:initial_value]
              accumulator[:initial_value] = arg[:initial_value]
            else
              raise BadDSL.new
            end
          end

          if arg.has_key? :mode
            if MODE.match? arg[:mode]
              accumulator[:mode] = arg[:mode]
            else
              raise BadDSL.new
            end
          end

          if arg.has_key? :triggered_by
            if IDENTIFIER.match? arg[:triggered_by]
              accumulator[:triggered_by] = arg[:triggered_by]
            else
              raise BadDSL.new
            end
          end

          if arg.has_key? :triggers
            if IDENTIFIER.match? arg[:triggers]
              accumulator[:triggers] = arg[:triggers]
            else
              raise BadDSL.new
            end
          end

        else
          if IDENTIFIER.match?(arg) # a node's name, if present, is always the first argument
            accumulator[:name] = arg
          elsif INITIAL_VALUE.match?(arg)
            accumulator[:initial_value] = arg
          elsif MODE.match?(arg)
            accumulator[:mode] = arg
          elsif ACTIVATION.match?(arg)
            accumulator[:activation] = arg
          elsif PROC.match?(arg)
            accumulator[:condition] = arg
          else
            raise BadDSL, "Argument #{arg} doesn't fit any known signature"
          end
        end
        # passing the accumulator onto the next iteration
        accumulator
      end
    end

    def self.parse_gate_arguments(arguments)

      # mode is always pull_any so user can't choose it
      # initial_value makes no sense for gates either
      arguments.inject(ConstantHash.new) do |accumulator, arg|
        if arg.is_a? Hash
          if arg.has_key? :condition
            accumulator[:condition] = arg[:condition] if PROC.match?(arg[:condition])
          elsif arg.has_key? :triggered_by
            accumulator[:triggered_by] = arg[:triggered_by] if IDENTIFIER.match?(arg[:triggered_by])
          else
            raise BadDSL, "Named argument doesn't fit any known signature"
          end
        else
          if IDENTIFIER.match?(arg)
            accumulator[:name] = arg
          elsif ACTIVATION.match?(arg)
            accumulator[:activation] = arg
          else
            raise BadDSL, "Argument #{arg} doesn't fit any known signature"
          end
        end
        accumulator
      end

    end

    def self.parse_edge_arguments(arguments)

      arguments.inject(ConstantHash.new) do |acc, elem|
        if elem.is_a? Hash
          if elem.has_key? :from
            acc[:from] = elem[:from] if IDENTIFIER.match? elem[:from]
          end
          if elem.has_key? :to
            acc[:to] = elem[:to] if IDENTIFIER.match? elem[:to]
          end
          if elem.has_key? :label
            acc[:label] = elem[:label] if LABEL.match? elem[:label]
          end
        else
          if IDENTIFIER.match?(elem)
            acc[:name] = elem
          elsif LABEL.match?(elem)
            acc[:label]=elem
          else
            raise BadDSL, "argument #{elem} doesn't fit any known signature."
          end
        end
        acc
      end

    end

    def self.parse_stop_condition_arguments(arguments)
      arguments.inject(ConstantHash.new) do |acc, elem|

        if elem.is_a? Hash

          if elem.has_key? :message
            acc[:message] = elem[:message] if IDENTIFIER.match? elem[:message]
          end

          if elem.has_key? :condition
            acc[:condition] = elem[:condition] if PROC.match? elem[:condition]
          end

        else
          acc[:condition] = elem if PROC.match? elem
          acc[:message] = elem if SHORT_STRING.match? elem
        end

        acc
      end
    end

    # Used to validate that a string is a valid name for diagram components
    #
    # @param [String] text the name we want to validate
    # @raise [BadDSL] if given text is not a valid name
    # @return [String] the text itself, but only if it's valid. Otherwise
    #   an exception will be raised.
    def self.validate_name!(text)
      if StringHelper.valid_ruby_variable_name?(text)
        text
      else
        raise BadDSL, "Invalid name: '#{text}'"
      end
    end

    # @param [String] text the name we want to validate
    # @return [Boolean] whether or not given text is a valid name for diagram elements
    def self.valid_name?(text)
      StringHelper.valid_ruby_variable_name?(text)
    end

  end

end
