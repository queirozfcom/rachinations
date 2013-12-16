class Resource

  attr_reader :quantity,:type

  def initialize(type=Fixnum)

    #raise ArgumentError.new (":quantity must be a non-negative number, got #{hsh[:quantity]}") if hsh[:quantity] < 0 || ! hsh[:quantity].is_a?(Fixnum)
  	raise ArgumentError.new ("type must be an instance of Class, got #{type.class}") if type.class != Class

    @type = type

  end

  #def increment; raise NoMethodError("Implement method #{__method__} for class #{self.class.name}");end;
  #def decrement; raise NoMethodError("Implement method #{__method__} for class #{self.class.name}");end;

end