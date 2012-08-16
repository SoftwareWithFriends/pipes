module Pipes
  class SshPipe < SystemPipe

    attr_reader :command, :hosts

    def initialize(ssh_hosts, user = nil)
      @hosts = ssh_hosts.clone
      @command = initial_ssh_command(ssh_hosts.shift,user)

      ssh_hosts.each do |host|
        @command += "ssh #{host} "
      end
      super(command)
    end

    def initial_ssh_command(host,user)
      ssh_command =  "ssh #{ssh_options}"
      ssh_command += "#{user}@" if user_specified(user)
      ssh_command += "#{host} "
      ssh_command
    end


    def ssh_options
      options  = "-o 'StrictHostKeyChecking no' "
      options += "-o 'UserKnownHostsFile=/dev/null' "
      options += "-o 'ConnectionAttempts 5' "
      options += "-o 'CheckHostIP no' "
      options += "-o 'PasswordAuthentication no' "
      options += "-o 'ForwardAgent true' "
      options
    end

    def user_specified(user)
      user && (not user.empty?)
    end

    def close
      puts "exit"
      super
    end

  end
end
