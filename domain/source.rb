require_relative 'node'

class Source < Pool

  def initialize(hsh={})

    if hsh.has_key?(:types)
      values = Hash.new
      hsh[:types].each do |key|
        #TODO think of a better way to create nodes with infinite resources.. maybe create Tokens on demand would be good.
        values[key] = 999
      end
      hsh[:initial_value] = values
    end

    #sources are always automatic push
    hsh[:mode] = :push
    hsh[:activation] = :automatic

    #default values
    hsh = {
        :types => [],
        :initial_value => 999
    }.merge hsh

    super(hsh)

  end

  def to_s
    p "Source '#{@name}': Current Resources: #{@resources}"
  end

end
