class Fifo

  def initialize
    @store = Array.new
  end

  # Puts an object into the queue
  #
  # @param [Object] obj
  # @return [Fifo] The queue itself.
  def put!(obj)
    @store.push(obj)
    self
  end

  # Takes the least recently added element.
  #
  # @return [Object] whatever was stored in this queue.
  def take!
    @store.shift
  end
end