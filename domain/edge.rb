class Edge

  attr_reader :from_node_name, :to_node_name, :name, :label, :types

  def initialize(name, from_node_name, to_node_name, hsh={})

    @name = name

    @from_node_name = from_node_name

    @to_node_name = to_node_name

    #setting default values
    hsh = defaults.merge hsh

    @label = hsh[:label]
    @types = hsh[:types]


    #these are used to make sure that an edge sends resources
    #from a node to another only once per round.
    @sent = false
    @received = false

  end

  def has_type?(type)
    types.empty? || types.include?(type)
  end

  def reset
    #should be called at the end of a round
    @sent = @received = false
  end

  def connects?(node_name)
    @to_node_name === node_name || @from_node_name === node_name
  end

  def sent?
    sent
  end

  def set_sent
    @sent = true
  end

  def set_received
    @received = true
  end

  private

  def sent
    @sent
  end

  def received
    @received
  end

  def defaults
    {
        :label => 1,
        :types => []
    }
  end

end