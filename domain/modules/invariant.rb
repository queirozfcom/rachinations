module Invariant

  #used to insert assertions into code
  #remember that assertions should not be used to control program flow!!! assert things that should ALWAYS be false.

  class AssertionError < RuntimeError

  end

  def invariant &block
    raise AssertionError unless yield
  end

  #alias of invariant
  def inv &block
    invariant &block
  end

end
