require 'forwardable'

class NodeCollection
  extend Forwardable

  def_delegators :@array, :[], :<<, :each, :push, :map, :select, :detect

  def initialize(init_array=nil)

    if init_array.nil?
      @array = []
    else
      @array = init_array
    end
  end

  def passive
    @array.select{|el| el.passive?}
  end

  def automatic
    @array.select{|el| el.automatic?}
  end

  #def clone_to_array
  #  # i know i could use map
  #  ary = Array.new
  #  @array.each { |el| ary.push(el) }
  #  ary
  #end

  def detect_by_name(name)
    @array.detect{|el| el.name === name}
  end

end