require_relative '../../domain/nodes/pool'
class Sink < Pool
  # A sink is a Pool that you can´ remove anything

  def remove_resource!(type=nil, run_hooks=true)
    # do nothing
  end

  def remove_resource_where! &expression
    # do nothing
  end

end