require 'test_helper'
require 'escape'

module Pipe
  class SystemPipeTest < Test::Unit::TestCase

      attr_reader :system_pipe

      TEST_FILE = "/tmp/test_file"
      TEST_DIR  = "/tmp/foo"

      def setup
        File.delete(TEST_FILE) if File.exist?(TEST_FILE)
        Dir.delete(TEST_DIR) if Dir.exist?(TEST_DIR)
        @system_pipe = SystemPipe.new("bash")
      end

      def teardown
        @system_pipe.close
      end

      def test_run_command_through_pipe
        system_pipe.puts("echo test_string")

        assert_equal "test_string", system_pipe.readline.chomp
      end


      def test_can_write_file_through_pipe_and_get_return_code

        contents = "This is the content of a Test File\nAnd a second line"
        system_pipe.write_file(TEST_FILE, contents)
        actual = File.read(TEST_FILE)
        assert_equal contents, actual
      end

      def test_can_make_path
        system_pipe.make_path(TEST_DIR)
        assert Dir.exist?(TEST_DIR)
      end

      def test_can_block_for_return_code
        assert_raise SystemPipe::ReturnCodeException do
          system_pipe.run_command_and_ensure_return_code("false")
        end
      end

  end
end
