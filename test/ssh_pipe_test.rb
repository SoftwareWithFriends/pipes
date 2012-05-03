require_relative "test_helper"

module Pipes
  class SshPipeTest < Test::Unit::TestCase

    def test_can_nest_ssh_hosts
      SshPipe.any_instance.expects(:ensure_started)
      SshPipe.any_instance.expects(:open_pipe_for_writing).with {|value| value.match /hosta ssh hostb/ }
      SshPipe.new(['hosta','hostb'])
    end

    def test_can_exit_an_ssh_session
      mock_pipe = {}
      SshPipe.any_instance.expects(:open_pipe_for_writing).returns(mock_pipe)
      SshPipe.any_instance.expects(:ensure_started)
      ssh_pipe = SshPipe.new(['localhost'])
      mock_pipe.expects(:puts).with("exit")
      mock_pipe.expects(:close)
      ssh_pipe.close
    end

    def test_can_specify_user_for_initial_ssh_session
      SshPipe.any_instance.expects(:ensure_started)
      SshPipe.any_instance.expects(:open_pipe_for_writing).with {|value| value.match /testuser@hosta ssh hostb/ }
      SshPipe.new(["hosta", "hostb"],'testuser')
    end

    def test_nil_user_results_in_no_user
      SshPipe.any_instance.expects(:ensure_started)
      SshPipe.any_instance.expects(:open_pipe_for_writing).with {|value| value.match /\shosta ssh hostb/ }
      SshPipe.new(["hosta", "hostb"])
    end

    def test_empty_user_string_results_in_no_user
      SshPipe.any_instance.expects(:ensure_started)
      SshPipe.any_instance.expects(:open_pipe_for_writing).with {|value| value.match /\shosta ssh hostb/ }
      SshPipe.new(["hosta", "hostb"],'')
    end
  end
end
