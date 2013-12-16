class Edge

  attr_reader :from_node_name, :to_node_name, :name, :label, :types

  def initialize(name, from_node_name, to_node_name, hsh={})

    @name = name

    @from_node_name = from_node_name

    @to_node_name = to_node_name


    #setting default values
    hsh = {
        :label => 1,
        :types => []
    }.merge hsh

    @label = hsh[:label]
    @types = hsh[:types]

  end

  def has_type?(type)
    @types.empty? || @types.include?(type)
  end

end