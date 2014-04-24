require_relative 'diagram'


class NonDeterministicDiagram < Diagram

  def run_round!

    node = nodes.sample
    node.stage!

    #only after all nodes have run do we update the actual resources and changes, to be used in the next round.
    #nodes.shuffle.each{ |n| n.commit! }
    nodes.each{ |n| n.commit! }

  end

end