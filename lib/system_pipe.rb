require 'forwardable'

module Pipes
  class SystemPipe

    extend Forwardable

    class ReturnCodeException < Exception; end

    attr_reader :pipe
    def_delegators :pipe, :puts, :readline, :close, :each, :readlines, :write

    def initialize(command)
      @pipe = open_pipe_for_writing(command)
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

    private

    def open_pipe_for_writing(command)
      IO.popen(command, "w+")
    end

    def flush_until(expected)
      until(match = readline.match(expected)); end
      match.string.chomp
    end

  end
end
