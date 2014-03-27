class Token

  def initialize
    @lock= FALSE
  end

  def lock!
    if locked?
      raise RuntimeError.new 'Tried to lock a locked Token.'
    else
      @lock = TRUE
    end
  end
end

def unlock!
  if unlocked?
    raise RuntimeError.new 'Tried to unlock an unlocked Token.'
  else
    @lock = FALSE
  end
end

def locked?
  @lock == TRUE
end

def unlocked?
  @lock == FALSE
end

#hooks which can be overridden in child classes
def reached_node(node)
  #do nothing
end

def left_node(node)
  #do nothing
end


end