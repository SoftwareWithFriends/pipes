require_relative 'system_pipe'
require_relative 'ssh_pipe'
require_relative 'single_command_pipe'
require_relative 'fake_pipe'
require 'escape'

module Pipes
  GEM_PATH = File.join(File.dirname(__FILE__), "..")
end

