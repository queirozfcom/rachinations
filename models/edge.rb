class Edge

  attr_reader :from_node_name, :to_node_name, :name, :label, :types

  def initialize(name, from_node_name, to_node_name, hsh={})

    @name = name

    @from_node_name = from_node_name

    @to_node_name = to_node_name



    #doesn't make sense to set both
    if hsh.has_key?(:types_allowed) && hsh.has_key?(:types_disallowed)

      # unless it's the default case obviously
      unless hsh[:types_allowed] === :all && hsh[:types_disallowed] === :none
        raise ArgumentError.new 'Please set either :types_allowed or :types_disallowed, but not both'
      end
    end

    if hsh.has_key?(:types_allowed)
      @types_allowed = hsh[:types_allowed]
      @types_disallowed = nil
    elsif hsh.has_key?(:types_disallowed)
      @types_disallowed = hsh[:types_disallowed]
      @types_allowed = nil
    else
      @types_allowed = :all
      @types_disallowed = :none
    end

    #setting default values
    hsh = {
        :label => 1
    }.merge hsh

    @label = hsh[:label]

  end

end