Gem::Specification.new do |spec|
  spec.files       = %w( README LICENSE HISTORY )
  spec.files       += Dir.glob("lib/**/*")
  spec.files       += Dir.glob("bin/**/*")
  spec.files       += Dir.glob("test/**/*")
  spec.files       += Dir.glob("spec/**/*")
  spec.bindir = "bin"
  spec.executables = %w{syslog-shipper}

  spec.name = "syslog-shipper"
  spec.version = "1.1"
  spec.summary = "syslog-shipper - a tool for streaming logs from files to a remote syslog server"
  spec.description = "Ship logs from files to a remote syslog server over TCP"
  
  spec.author = "Neil Matatall"
  spec.email = "neil@matatall.com"
  spec.homepage = "https://github.com/oreoshake/syslog-shipper"
  spec.add_dependency "eventmachine-tail"
  spec.add_dependency "trollop"
end

