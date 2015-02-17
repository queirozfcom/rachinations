require_relative 'bad_options'
#use this for classes you want to be able to instantiate
#using a hashful of parameters
module HashInit

  class ::Array

    def include_option? opt

      each do |el|
        if el == opt
          return true
        elsif el.is_a?(Hash) && el.has_key?(opt)
          return true
        end
      end

      false
    end

  end

  def initialize(hsh={})

    raise BadOptions.new 'This class requires a hash as parameter to its constructor.'  if !hsh.is_a?(Hash)

    check_options!(hsh)
    hsh=set_defaults(hsh)
  end

  def check_options!(hsh)

    #watch out for unknown options - might be typos!
    hsh.each_pair do |key, value|

      if !options.include_option?(key) && aliases_for(key).none?{|ali| options.include_option?(ali) }
        raise BadOptions.new "Class #{self.class}: unknown option in constructor: :#{key} (using HashInit)"
      end

    end

    # make sure all required ones are there
    options.each do |el|
      if el.is_a? Hash

        #we know for sure it's got only one key and one value
        k = el.keys[0]
        v = el.values[0]

        if v == :required

          if !hsh.has_key?(k) && hsh.keys.all?{|opt| aliases_for(opt).none?{|ali| ali == k } }
            raise BadOptions.new "Required option #{k} was not found in parameter hash."
          end
        end

      end
    end

  end

  def aliases_for(opt)
    aliases.select{|k,v| k == opt }.values
  end

  def set_defaults(hsh)
    #in case the user hasn't passed full parameters to the constructor
    defaults.merge hsh
  end

  # This method should be implemented by each client to indicate the options accepted.
  #@return [Array] An array of accepted options.
  #@example Many client Classes specify a :name option:
  #  def options
  #    [:name]
  #  end
  def options
    []
  end

  def defaults
    {}
  end

  def aliases
    {}
  end

end