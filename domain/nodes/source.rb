require_relative '../../domain/nodes/pool'

INFINITY = 999

class Source < Pool

  def initialize(hsh={})

    if hsh.has_key?(:types)
      values = Hash.new
      hsh[:types].each do |key|
        # TODO think of a better way to create nodes with infinite resources.. maybe create Tokens on demand would be good.
        # LAZILY!!!!!

        values[key] = INFINITY
      end
      hsh[:initial_value] = values

    end

    #sources are  automatic push by default

    #default values
    hsh = {
        initial_value: INFINITY,
        types: [],
        mode:  :push,
        activation:  :automatic
    }.merge hsh

    super(hsh)

  end

  def to_s
    "Source '#{@name}':  #{@resources.to_s}"
  end

  def add_resource!; end

  def resource_count(klass=nil)
    return 0
  end
end
