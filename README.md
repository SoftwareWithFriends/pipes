pipes
=====
Pipes is yet another library for launching programs and interacting with the shell. 

Install
-------
gem install swf-pipes

Usage
-----
Base functionality is implemented in SystemPipe:

```ruby
pipe = Pipes::SystemPipe.new('bash')
pipe.puts "date"
pipe.readline
>>> "Mon Jul  1 21:47:24 EDT 2013\n"
pipe.puts_command_read_number('echo 1')
>>> 1.0
```

The primary purpose of the library is to allow nested ssh connections to access resources behind a firewall
```ruby
pipe = Pipes::SshPipe.new(['fw','logserver'],"log_admin")
pipe.puts_command_read_number 'find /var/log/ -type f |wc -l'
>>> 174
```

Developing
----------
Fork It.
Branch It.
Pull-Request It.
