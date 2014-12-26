module Extras

  # A normal hash except that it raises RuntimeErrors
  #  if a key gets assigned twice
  class ConstantHash < Hash

    def []=(key, value)

      if has_key?(key)
        raise RuntimeError, "key :#{key} has already been set"
      end

      super
    end

    def store(key, value)
      if has_key?(key)
        raise RuntimeError, "key :#{key} has already been set"
      end

      super
    end

  end
end