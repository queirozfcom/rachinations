module ProcConvenienceMethods

  # A few extra methods
  # to make code read more intuitively.
  refine Proc do

    alias_method :accepts?, :call
    alias_method :accept?, :call

    alias_method :match?, :call
    alias_method :matches?, :call

    alias_method :match_resource?, :call
    alias_method :matches_resource?, :call

  end

end