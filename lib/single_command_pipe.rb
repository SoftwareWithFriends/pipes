module Pipes
  class SingleCommandPipe

    attr_reader :command_pid

    def put_synchronously(command)
      setup_trap

      @pipe = IO.popen(command)
      @command_pid = @pipe.pid
      output = @pipe.readlines
      @command_pid = nil
      output
    end

    def setup_trap
      if previous_term_trap = trap("TERM") { kill_current_process_tree }
        trap("TERM") { kill_current_process_tree; previous_term_trap.call }
      end

      if previous_exit_trap = trap("EXIT") { kill_current_process_tree }
        trap("EXIT") { kill_current_process_tree; previous_exit_trap.call }
      end
    end

    def kill_current_process_tree
      kill_process_tree command_pid if command_pid
    end

    def kill_process_tree(starting_pid)
      child_pids(starting_pid).each do |child_pid|
        kill_process_tree(child_pid)
      end
      Process.kill("TERM", starting_pid) rescue nil
    end

    def child_pids(parent_pid)
      pgrep_parent_pid(parent_pid).split.map(&:to_i)
    end

    def pgrep_parent_pid(parent_pid)
      `pgrep -P #{parent_pid}`
    end


  end
end
