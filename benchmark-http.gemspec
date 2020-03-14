require_relative "lib/benchmark/http/version"

Gem::Specification.new do |spec|
	spec.name          = "benchmark-http"
	spec.version       = Benchmark::HTTP::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]

	spec.summary       = "An asynchronous benchmark toolbox for modern HTTP servers."
	spec.homepage      = "https://github.com/socketry/benchmark-http"

	spec.files         = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(test|spec|features)/})
	end
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]

	spec.required_ruby_version = '~> 2.4'

	spec.add_dependency("async-io", "~> 1.5")
	spec.add_dependency("async-http", "~> 0.45")
	spec.add_dependency("async-await")
	
	spec.add_dependency("trenni-sanitize")
	
	spec.add_dependency('samovar', "~> 2.0")
	
	spec.add_development_dependency "covered"
	spec.add_development_dependency "async-rspec"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end
