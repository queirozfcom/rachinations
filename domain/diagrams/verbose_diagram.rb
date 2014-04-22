class VerboseDiagram < Diagram

  #useful to see round-to-round changes, to help debugging for instance.

  def before_run
    print "\033[1;32m===== INITIAL STATE =====\e[00m\n\n"

    puts self
  end

  def after_run
    print "\033[1;32m====== FINAL STATE ======\e[00m\n\n"

    puts self

    print "\033[1;31m========== END ==========\e[00m\n\n"
  end

  def before_round(round_no)
    print "======= ROUND #{round_no} =======\n\n"
  end

  def after_round (round_no)
    puts self
  end

  def sanity_check?(round_no)
    if round_no >= 999
      print "\033[1;31m= SAFEGUARD CONDITION REACHED - ABORTING EXECUTION =\e[00m\n\n"
      false
    else
      true
    end
  end

end