require 'system_pipe'

module Pipes
  class SshPipe < SystemPipe

    attr_reader :command

    def initialize(ssh_hosts, user = nil)

      @command = initial_ssh_command(ssh_hosts.shift,user)

      ssh_hosts.each do |host|
        @command += "ssh #{host} "
      end
      super(command)
    end

    def initial_ssh_command(host,user)
      ssh_command =  "ssh #{ssh_options}"
      ssh_command += "#{user}@" if user
      ssh_command += "#{host} "
      ssh_command
    end


    def ssh_options
      options  = "-o 'StrictHostKeyChecking no' "
      options += "-o 'UserKnownHostsFile=/dev/null' "
      options += "-o 'ConnectionAttempts 5' "
      options += "-o 'CheckHostIP no' "
      options += "-o 'PasswordAuthentication no' "
      options
    end

    def close
      puts "exit"
      super
    end

  end
end
