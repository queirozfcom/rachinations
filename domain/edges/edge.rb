class Edge

  attr_reader :from_node_name, :to_node_name, :name, :label, :types

  def initialize(hsh={})

    #TODO assert that hsh has at least the required keys: :name, :from and :to

    @name = hsh[:name]

    @from_node_name = hsh[:from]

    @to_node_name = hsh[:to]

    #setting default values
    hsh = defaults.merge hsh

    @label = hsh[:label]
    @types = hsh[:types]


    #these are used to make sure that an edge sends resources
    #from a node to another only once per round.
    @sent = false
    @received = false

  end

  def supports?(type)
    has_type?(type)
  end

  def support?(type)
    has_type?(type)
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

  def from?(node_name)
    node_name === @from_node_name
  end

  def to?(node_name)
    node_name === @to_node_name
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