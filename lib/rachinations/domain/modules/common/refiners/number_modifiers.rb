module NumberModifiers


  # allow user to modify Numbers in order to express
  # percentages ( 12.percent ) and also fractions, for
  # example.
  refine Fixnum do

    def /(other)
      fdiv(other)
    end

    #   # but Fixnums are frozen by default so they can't change state.
    #   # so that i can know whether the user has explicitly called #percent
    #   # i would like to add an instance variable to this number
    def percent
      fdiv(100)
    end

  end

end