# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "huginn_state_code_agent"
  spec.version       = "1.0.0"
  spec.authors       = ["5 Stones"]
  spec.email         = ["it@weare5stones.com"]

  spec.summary       = %q{Agent that derives a state code from a country & region name using Carmen.}
  spec.description   = %q{A light weight agent that leverages the Carmen gem to derive a state code given the name of a country and region.}

  spec.homepage      = "https://github.com/5-stones/huginn_state_code_agent"


  spec.files         = Dir['LICENSE.txt', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir['spec/**/*.rb'].reject { |f| f[%r{^spec/huginn}] }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "huginn_agent"
end
