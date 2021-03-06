require_relative '../../domain/nodes/pool'
# You can send anything to a Sink.
# Think of it like a Blackhole for resources.

class Sink < Pool


  def take_resource!(type=nil, &expression)
    # do nothing
  end

  def put_resource!(obj, edge=nil)
    inv{obj.unlocked?}
    # do nothing
  end

  def to_s
    "Sink '#{@name}'\n\n"
  end
end