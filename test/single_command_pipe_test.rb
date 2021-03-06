require_relative "test_helper"

module Pipes
  class SingleCommandPipeTest < Test::Unit::TestCase

    def test_give_block_threw_thread
      pipe = SingleCommandPipe.new
      test_string = "FOO"

      assert_equal test_string, pipe.put_synchronously("echo #{test_string}").first.chomp
    end

    def test_can_kill_process_tree
      pipe = SingleCommandPipe.new

      pipe.stubs(:command_pid).returns(9998)
      pipe.expects(:pgrep_parent_pid).with(9998).returns("9999\n")
      pipe.expects(:pgrep_parent_pid).with(9999).returns("10000\n")
      pipe.expects(:pgrep_parent_pid).with(10000).returns("")

      Process.expects(:kill).with("TERM", 10000)
      Process.expects(:kill).with("TERM", 9999)
      Process.expects(:kill).with("TERM", 9998)

      pipe.kill_current_process_tree
    end

    def test_sets_up_term_trap
      pipe = SingleCommandPipe.new

      pipe.expects(:trap).returns("DEFAULT")

      pipe.put_synchronously("ls")

    end

    def test_calls_previous_term_proc
      pipe = SingleCommandPipe.new

      @term_count = 0
      old_proc = Proc.new { @term_count = 1 }
      pipe.expects(:trap).once.with("TERM", anything).returns(old_proc)
      pipe.expects(:trap).with do |sig, new_proc|
        new_proc.call
        sig == "TERM" && @term_count == 1
      end
      pipe.put_synchronously("ls")
    end


  end
end