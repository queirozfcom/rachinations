class Node

  attr_accessor  :name

  def initialize_copy(orig)
    super

    #need to clone the resource bag as well...
    @resources = @resources.clone()

    #don't need this. takes too much space
    @diagram = nil

  end

 def run! # should be called by diagram
    if @activation==:automatic
      execute!
    elsif @is_start and @activation == :start
      execute!
    else
      # do nothing for a while
    end
  end


  def commit! # should be called by diagram
    @state=:before
    false
  end

  def execute! # can be called by any node/thing
    @state=:after
    false
  end



end