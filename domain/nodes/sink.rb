require_relative '../../domain/nodes/pool'
# You can send anything to a Sink.
# Think of it like a Blackhole for resources.

class Sink < Pool


  def remove_resource!(type=nil, &expression)
    # do nothing
  end

  def put_resource!(obj)
    # do nothing
  end

end