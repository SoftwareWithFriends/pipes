require_relative 'test_helper'
require 'escape'

module Pipes
  class SystemPipeTest < Test::Unit::TestCase

    attr_reader :system_pipe

    TEST_FILE = File.join(Pipes::GEM_PATH, "/test_file")
    TEST_DIR = File.join(Pipes::GEM_PATH, "/foo")

    def setup
      File.delete(TEST_FILE) if File.exist?(TEST_FILE)
      Dir.delete(TEST_DIR) if Dir.exist?(TEST_DIR)
      @system_pipe = SystemPipe.new("bash")
    end

    def teardown
      @system_pipe.unstub(:close)
      @system_pipe.close unless @system_pipe.closed?
    end

    def test_run_command_through_pipe
      system_pipe.puts("echo test_string")
      assert_equal "test_string", system_pipe.readline.chomp
    end

    def test_ensures_started_during_initialize
      SystemPipe.any_instance.expects(:ensure_started)
      pipe = SystemPipe.new("date")
    end

    def test_times_out_instead_of_blocking
      system_pipe.puts("sleep 1")
      system_pipe.close_with_timeout(0.1)
      assert_equal 1, system_pipe.abandoned_pipes_count
    end

    def test_handles_errors_during_close_timeout
      system_pipe.expects(:close).raises(Errno::EPIPE, "Fake Message")
      system_pipe.close_with_timeout(1)
      assert_equal 1, system_pipe.abandoned_pipes_count
      assert !@system_pipe.closed?
    end

    def test_can_retry_pipe
      system_pipe.puts "echo first tube"
      system_pipe.retry_pipe
      system_pipe.puts "echo second tube"
      assert_equal "second tube", system_pipe.readline.chomp
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

    def test_can_return_output_from_good_return
      output = system_pipe.run_command_and_ensure_return_code("echo test")
      assert_equal ["test"], output
    end

    def test_can_follow_file
      max_num_lines = 3
      lines = []
      fake_log = GEM_PATH + "/test/fixtures/tailable_log_file.log"
      system_pipe.follow_file(fake_log) do |line|
        lines << line
        break if lines.size >= max_num_lines
      end

      assert_equal "Log Line 1", lines.first.chomp

      system_pipe.puts "echo TEST PASSED"

      assert_equal "Log Line 4", system_pipe.readline.chomp
      assert_equal "Log Line 5", system_pipe.readline.chomp
      assert_equal "TEST PASSED", system_pipe.readline.chomp

    end

    def test_can_send_copy_command
      source = "/foo"
      destination = "/bar"

      system_pipe.expects(:run_command_and_ensure_return_code).
          with("cp #{source} #{destination} 2>&1")

      system_pipe.cp(source, destination)
    end

    def test_can_backup_file
      source = "foo"
      test_time = DateTime.parse("2013-01-11 13:55:11")
      destination = "foo.bak_20130111_135511"

      system_pipe.expects(:current_time).returns(test_time.to_time)


      system_pipe.expects(:cp).with(source, destination)
      system_pipe.backup_file(source)
    end


    def test_can_write_command_and_read_single_number
      command = "this is the command"
      system_pipe.expects(:puts_limit_one_line).with(command)
      system_pipe.expects(:readline).returns("50.2")
      assert_equal 50.2, system_pipe.puts_command_read_number(command)
    end

    def test_deals_with_non_numberic_response
      response = system_pipe.extract_number_from_string("25.12Not A Number25.15")
      assert_nil response
    end

    def test_converts_float_string_to_number
      response = system_pipe.extract_number_from_string("25.15")
      assert_equal 25.15, response
    end

    def test_converts_single_digit_number_string_to_number
      response = system_pipe.extract_number_from_string("2")
      assert_equal 2, response
    end

    def test_converts_decimal_with_no_leading_zero_to_number
      response = system_pipe.extract_number_from_string(".5")
      assert_equal 0.5, response
    end

    def test_does_not_match_on_blank_string
      response = system_pipe.extract_number_from_string("".strip)
      assert_nil response
    end

    def test_handles_timeout
      command = "fake command"

      system_pipe.expects(:puts_limit_one_line).raises(Timeout::Error)
      system_pipe.expects(:retry_pipe)

      assert_raise Pipes::PipeReset do
        system_pipe.puts_command_read_number(command)
      end

    end

    def test_can_retry_after_timeout
      assert_raise Pipes::PipeReset do
        system_pipe.retry_after_timeout(0.1) do
          puts "sleep 1; echo 'Timeout in test did not get hit'"
          Kernel.puts readline
        end
      end
    end



  end
end
