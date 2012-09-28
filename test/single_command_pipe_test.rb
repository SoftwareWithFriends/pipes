require_relative "test_helper"

module Pipes
  class SingleCommandPipeTest < Test::Unit::TestCase

    def test_give_block_threw_thread
      pipe = SingleCommandPipe.new

      assert pipe.put_synchronously("ls")
    end

  end
end