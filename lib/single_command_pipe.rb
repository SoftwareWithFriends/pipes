module Pipes
  class SingleCommandPipe
    def put_synchronously(command)
      `#{command}`
    end
  end
end