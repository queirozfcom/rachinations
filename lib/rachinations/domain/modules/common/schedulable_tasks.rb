
module SchedulableTasks
  def schedule_task(method, *params)
    task = Hash.new
    task[:method] = method
    task[:params] = params

    @scheduled_tasks ||= Array.new
    @scheduled_tasks << task
  end

  def scheduled_tasks
    @scheduled_tasks ||= Array.new
  end
  
  def run_scheduled_tasks
    scheduled_tasks.each do |task|

      method = task[:method]
      params = task[:params]


      method.call(*params)
    end
  end

end