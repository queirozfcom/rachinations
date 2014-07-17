require_relative '../../domain/resources/token'
require_relative '../../domain/nodes/node'

class ResourcelessNode < Node

  # only for now.
  def resource_count(&blk)
    0
  end

end