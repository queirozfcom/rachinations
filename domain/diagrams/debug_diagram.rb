class DebugDiagram < Diagram

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

  def after_round

  end

end