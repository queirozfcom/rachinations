require 'active_support/all'

class ResourceBag
  def initialize(allowed_types=nil)

    if(allowed_types.nil?)
      @allowed_classes = [Token]
    else
      @allowed_classes = allowed_types
    end

    @store = Array.new
  end

  def allows? (klass)
    allowed_classes.include?(klass)
  end

  #alias
  def allow?(klass)
    allows?(klass)
  end

  def add(obj)
    @store.push(obj)
  end

  #retrieve
  def get(klass=nil)

    if klass.nil?
      obj = store.select{|el| el.is_a?(Token)}.sample
    else
      obj = store.select{|el| el.is_a?(klass)}.sample
    end

    remove_element!(obj)
    obj

  end

  def count(klass)

    store.select{|el| el.is_a?(klass)}.length
  end

  private

  def allowed_classes
    @allowed_classes
  end

  def store
    @store
  end

  def remove_element!(obj)

    if @store.delete(obj).nil?
      raise Exception.new("Unable to remove element form ResourceBag because it couldn't be found.")
    end

end

end