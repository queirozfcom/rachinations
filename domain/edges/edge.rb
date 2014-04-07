class Edge

  attr_reader :from, :to, :name, :label, :types

  def initialize(hsh)

    @name = hsh.fetch(:name)

    @from = hsh.fetch(:from)

    @to = hsh.fetch(:to)

    #setting default values if needed.
    hsh = defaults.merge hsh

    @label = hsh.fetch(:label)
    @types = hsh.fetch(:types)

    #these are used to make sure that an edge sends resources
    #from a node to another only once per round.
    @sent = false
    @received = false

  end

  def stage_carry!

  end

  #alias
  def supports?(type)
    has_type?(type)
  end

  #alias
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

  def connects?(obj)
    to.equal?(obj) || from.equal?(obj)
  end

  def from?(obj)
    from.equal?(obj)
  end

  def to?(obj)
    to.equal?(obj)
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