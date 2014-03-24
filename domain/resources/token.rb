class Token

  def initialize
  end

  #hooks which can be overridden in child classes
  def reached_node(node)
    #do nothing
  end

  def left_node(node)
    #do nothing
  end


end