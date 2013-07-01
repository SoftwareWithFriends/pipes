Gem::Specification.new do|spec|

  spec.name = 'swf-pipes' 
  spec.version = '0.3.9'
  spec.summary = 'Pipes for doing things'
  spec.description = 'Various classes for dealing with system type pipes in linux'
  spec.files = Dir['lib/**/*.rb']
  spec.files += Dir['test/**/*']
  spec.authors = ["Ryan McGarvey, Tim Johnson"]
  spec.homepage = "https://github.com/SoftwareWithFriends/pipes"
  spec.require_path = 'lib'
  spec.add_dependency("escape", [">= 0.0.4"])
end
