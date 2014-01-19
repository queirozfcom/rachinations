require_relative 'node'

class Source < Pool

  def initialize(name,hsh={})


    if hsh.has_key?(:types)
      values = Hash.new
      hsh[:types].each do |key|
        values[key] = Float::INFINITY
      end
      hsh[:initial_value] = values
    end


    #sources are always automatic push
    hsh[:mode] = :push
    hsh[:activation] = :automatic

    #default values
    hsh = {
      :types => [],
      :initial_value => Float::INFINITY
    }.merge hsh

    super(name,hsh)

  end

  #same things as a pool, basically
  def remove_resource!(type=nil)
    if type.nil?
      #do nothing
    else
      if @resources.has_key? type
        #do nothing
      else
        raise ArgumentError.new "You tried to remove a resource of type #{type} but I don't deal with those types."
      end
    end
  end

  def to_s
    p "Source '#{@name}': Current Resources: #{@resources}"
  end

end
