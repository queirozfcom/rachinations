module Default

  @time = nil
  @last_round = 0

  def before_run

    @time = Time.now

    print "\n\033[1;32m===== INITIAL STATE =====\e[00m\n\n"

    puts self
  end

  def after_run

    total_time = ( Time.now - @time )

    total_rounds = @last_round

    print "\033[1;32m====== FINAL STATE ======\e[00m\n\n"

    puts self

    print "\033[1;31m========== END ==========\e[00m\n\n"

    print "Diagram '#{name}' ran for #{total_rounds} rounds.\n"

    if total_time < 1.0
      print "Total time elapsed: #{(total_time*1000).to_i} milliseconds.\n"
    else
      print "Total time elapsed: #{total_time.to_i} seconds.\n"
    end


  end

  def before_round(round_no)
  end

  def after_round (round_no)
    @last_round = round_no
  end

  def sanity_check_message
    print "\033[1;31m= SAFEGUARD CONDITION REACHED - ABORTING EXECUTION =\e[00m\n\n"
  end

end