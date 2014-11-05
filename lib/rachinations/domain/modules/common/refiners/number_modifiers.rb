module NumberModifiers


  # allow user to modify Numbers in order to express
  # percentages ( 12.percent ) and also fractions, for
  # example.
  refine Fixnum do

    def percent
      # i would like to add an instance variable to this number
      # so that i can know whether the user has explicitly called #percent
      # but Fixnums are frozen by default so they can't change state.
      to_f/100
    end

  end

end