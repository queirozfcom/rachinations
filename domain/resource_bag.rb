require 'active_support/all'
require_relative 'modules/invariant'


class ResourceBag
  include Invariant

  def initialize
    @store = Array.new
  end

  def initialize_copy(orig)
    super
    @store=@store.map{|el| el.clone}

  end

  def add(obj)
    @store.push(obj)
  end

  #retrieve
  def get(klass)

    if count(klass) === 0
      raise NoElementsOfGivenTypeError
    end

    obj = store.select { |el| el.is_a?(klass) }.sample

    remove_element!(obj)
    obj

  end

  def count(klass)

    inv{ klass.is_a?(Class)}

    store.select{ |el| el.is_a?(klass) }.length
  end

  def to_s
    out = ''

    classes = store.map{ |el| el.class }.uniq

    classes.each do |klass|

      name = if klass.name.nil?
                'Anonymous Klass'
             else
               klass.name
             end

      out += "\n"+'    '+ name + ' -> '+ count(klass).to_s+"\n\n"
    end

    if classes.empty?
      "\n    Empty\n\n"
    else
      out
    end


  end

  private


  def store
    @store
  end

  def remove_element!(obj)

    if @store.delete(obj).nil?
      raise NoElementsOfGivenTypeError
    end

  end

end