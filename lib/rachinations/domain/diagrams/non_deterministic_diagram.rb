
class NonDeterministicDiagram < Diagram


  # This version of run_round! triggers only one node
  #  per turn.
  def run_round!

    node = nodes.sample
    node.trigger!

    nodes.each{ |n| n.commit! }

  end

end