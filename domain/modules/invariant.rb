module Invariant

  class AssertionError < RuntimeError

  end

  def invariant &block
    raise AssertionError unless yield
  end

  def inv &block
    invariant &block
  end

end
