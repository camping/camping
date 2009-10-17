require 'rdoc/task'

module Camping
  # Adds after_running_rdoc
  class RDocTask < RDoc::Task
    def after_running_rdoc(&block)
      @after_running_rdoc = block
    end

    def define
      pre = @before_running_rdoc
      ran = false
      @before_running_rdoc = proc { ran = true; pre.call if pre }
      
      super
      return unless after = @after_running_rdoc
    
      task = Rake::Task[rdoc_task_name.to_sym]
      target = Rake::Task[rdoc_target.to_sym]
    
      task.clear.enhance do
        begin
          target.invoke
        ensure
          after.call if ran
        end
      end
    end
  end                                
end