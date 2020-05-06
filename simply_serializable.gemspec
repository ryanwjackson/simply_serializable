# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simply_serializable/version'

Gem::Specification.new do |spec|
  spec.name          = 'simply_serializable'
  spec.version       = SimplySerializable::VERSION
  spec.authors       = ['Ryan Jackson']
  spec.email         = ['ryanwjackson@gmail.com']

  spec.summary       = 'Simply Serializable makes it easy to serialize any object.'
  spec.description   = 'Simply Serializable makes it easy to serialize any object.  It provides a configuratable way to serialize the attributes you want and ignore the ones you don\'t.'
  spec.homepage      = 'https://www.github.com/ryanwjackson/simply_serializable'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'fingerprintable', '>= 1.2.1'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bump'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug', '>= 0'
  spec.add_development_dependency 'coveralls', '>= 0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
