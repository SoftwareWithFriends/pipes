require "test_helper"

module Pipe
  class SshPipeTest < Test::Unit::TestCase

    def test_can_nest_ssh_hosts
      SshPipe.any_instance.expects(:open_pipe_for_writing).with {|value| value.match /hosta ssh hostb/ }
      SshPipe.new(['hosta','hostb'])
    end

    def test_can_exit_an_ssh_session
      mock_pipe = {}
      SshPipe.any_instance.expects(:open_pipe_for_writing).returns(mock_pipe)
      ssh_pipe = SshPipe.new(['localhost'])
      mock_pipe.expects(:puts).with("exit")
      mock_pipe.expects(:close)
      ssh_pipe.close
    end

    def test_can_specify_user_for_initial_ssh_session
      SshPipe.any_instance.expects(:open_pipe_for_writing).with {|value| value.match /testuser@hosta ssh hostb/ }
      SshPipe.new(["hosta", "hostb"],'testuser')
    end

  end
end
