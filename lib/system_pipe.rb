require 'forwardable'

module Pipes
  class SystemPipe

    extend Forwardable

    class ReturnCodeException < Exception;
    end

    attr_reader :pipe
    def_delegators :pipe, :puts, :readline, :close, :each, :readlines, :write

    def initialize(command)
      @pipe = open_pipe_for_writing(command)
      ensure_started
      @pipe
    end

    def ensure_started
      run_command_and_ensure_return_code("whoami")
    end

    def write_file(file_path, contents)
      escaped_contents = Escape.shell_single_word(contents)

      write_file_command = "echo -n #{escaped_contents} > #{file_path}"
      run_command_and_ensure_return_code(write_file_command)
    end

    def make_path(path)
      run_command_and_ensure_return_code "mkdir -p #{path}"
    end

    def run_command_and_ensure_return_code(command)
      puts command
      puts "echo Return Code: $?"
      return_code_line = flush_until("Return Code:")
      raise ReturnCodeException, "Failed to run command:#{command} because #{return_code_line}" unless return_code_line.match /Return Code: 0/
    end

    def puts_with_output_to_dev_null(command)
      puts "#{command} 2>&1 >/dev/null"
    end

    def puts_limit_one_line(command)
      puts "#{command} | head -1"
    end

    def follow_file(file_name)
      trigger = "FINISHED LINE"
      puts follow_file_command(file_name, trigger)
      while line = readline
        yield line
      end
    ensure
      puts trigger
  end

  def follow_file_command(file_name, finished_trigger)
    "control ()
      {
          while read line; do
              if [[ \"$line\" == \"#{finished_trigger}\" ]]; then
                  exit
              fi
          done
      }

      control <&0 &
      CONTROL_PID=$!
      tail --pid $CONTROL_PID -qF #{file_name} 2>&1
      "
  end

  def flush_until(expected)
    output = ""
    until output.match(expected)
      output = readline
    end
    output.chomp
  end

  def cp(source, destination)
    copy_file_command = "cp #{source} #{destination}"
    run_command_and_ensure_return_code(copy_file_command)
  end

  private

  def open_pipe_for_writing(command)
    IO.popen(command, "w+")
  end


end
end
