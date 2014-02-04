require 'active_support/all'

class ResourceBag
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
    store.select{ |el| el.is_a?(klass) }.length
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
      raise NoElementsOfGivenTypeError
    end

  end

end