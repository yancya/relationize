# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relationize/version'

Gem::Specification.new do |spec|
  spec.name          = "relationize"
  spec.version       = Relationize::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ["yancya"]
  spec.email         = ["yancya@upec.jp"]

  spec.summary       = %q{We need evaluable string as relation in RDB}
  spec.description   = %q{This gem generate evaluable string as relation in RDB}
  spec.homepage      = "https://github.com/yancya/relationize"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hash-to_proc"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", ">= 3.0.0"
end
