module Pipes
  class FakePipe < Pipes::SystemPipe
    attr_reader :inputs, :outputs

    def initialize(outputs = [])
      @inputs = []
      @outputs = outputs
    end

    def puts(input)
      inputs << input
    end

    def readline
      outputs.shift
    end

    def readlines
      outputs
    end

    def each(&block)
      outputs.each(&block)
    end

    def fill(output_lines)
      output_lines.each_line do |line|
        outputs << line
      end
    end

    def close
      outputs << "close"
    end

    def write(string)
      outputs << string
    end

  end
end