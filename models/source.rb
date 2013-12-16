require_relative 'node'

class Source < Pool

  def initialize(name,hsh={})

    #sources are always automatic push
    hsh = {
      :mode => :push,
      :initial_value => Float::INFINITY,
      :activation => :automatic
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
        raise ArgumentError.new
      end
    end
  end

  def to_s
    p "Source '#{@name}': Current Resources: #{@resources}"
  end

end
