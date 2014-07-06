class Token

  
  def initialize
    @lock= false
  end

  def lock!
    if locked?
      raise RuntimeError, 'Tried to lock a locked Token.'
    else
      @lock = true
    end
    self
  end

  def type
    self.class
  end

  def is_type?(type)
    self.type.eql? type
  end

  def unlock!
    if unlocked?
      raise RuntimeError, 'Tried to unlock an unlocked Token.'
    else
      @lock = false
    end
    self
  end

  def locked?
    @lock == true
  end

  def unlocked?
    @lock == false
  end

  #hooks which can be overridden in child classes
  def reached_node(node); end

  def left_node(node); end

  def reached_edge(edge); end

  def left_edge(edge); end

end