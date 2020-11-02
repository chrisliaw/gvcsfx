require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = "gvcsfx"
  spec.version       = GvcsFx::VERSION
  spec.authors       = ["Chris"]
  spec.email         = ["chrisliaw@antrapol.com"]

  spec.summary       = %q{Generic Version Control System - JavaFX}
  spec.description   = %q{Simple and effective VCS workflow management}
  spec.homepage      = "https://github.com/chrisliaw/gvcsfx"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  #spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  #spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables   = "gvcsfx"
  spec.require_paths = ["lib"]

  spec.add_dependency 'tlogger', '>= 0.21'
  spec.add_dependency 'jrubyfx', '>= 1.2.0'
  spec.add_dependency 'toolrack', '~> 0.4'
  spec.add_dependency 'gvcs', '~> 0.1.0'
  spec.add_dependency 'git_cli', '~> 0.4.0'
  
end
