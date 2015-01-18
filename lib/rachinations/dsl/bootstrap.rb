require_relative '../../../lib/rachinations/domain/diagrams/diagram'
require_relative 'diagram_shorthand_methods'
require_relative 'bad_dsl'
require_relative 'helpers/parser'

# Bootstraping a diagram using the DiagramShorthandMethods
module DSL
  module Bootstrap

    def diagram(name='new_diagram', mode: :silent, &blk)

      # cant verbose be a simple boolean instead?
      if mode == :silent || mode == 'silent'
        dia= Diagram.new(Parser.validate_name!(name))
      elsif mode == :verbose || mode == 'verbose'
        dia = VerboseDiagram.new(Parser.validate_name!(name))
      else
        raise BadDSL, "Unknown diagram mode: #{mode.to_s}"
      end

      # methods in the block get run as if they were called on
      # the diagram (augmented by the DiagramShorthandMethods module) itself
      dia.instance_eval(&blk)

      dia

    end


    def non_deterministic_diagram(name, verbose=:silent, &blk)

      dia=NonDeterministicDiagram.new(Parser.validate_name!(name))

      # cant verbose be a simple boolean instead?
      if verbose === :verbose
        dia.extend(Verbose)
      end

      dia.instance_eval &blk

      dia

    end

    # This is just a convenience method to create a proc in a way that's more
    #  intuitive for ends users.
    # @example Create a proc, equivalent to proc{|x| x+1 }
    #   expr{|x| x+1 }
    def expr(&blk)
      if !block_given?
        raise ArgumentError, "expected a block, but none was given"
      else
        Proc.new(&blk)
      end
    end

  end

end