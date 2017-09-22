lib = File.expand_path('.', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "mikutter"
  spec.version       = '3.5.0-dev'
  spec.authors       = ["toshi_a"]
  spec.email         = ["yo-wakaran@example.com"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "http://mikutter.hachune.net/"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_dependency 'oauth', '>= 0.5.1'
  spec.add_dependency 'json_pure', '~> 1.8'
  spec.add_dependency 'addressable', '~> 2.3'
  spec.add_dependency 'memoist', '~> 0.14'
  spec.add_dependency 'ruby-hmac', '~> 0.4'
  spec.add_dependency 'typed-array', '~> 0.1'
  spec.add_dependency 'delayer', '~> 0.0'
  spec.add_dependency 'diva'
  spec.add_dependency 'pluggaloid', '>= 1.1.1', '< 2.0'
  spec.add_dependency 'delayer-deferred', '>= 1.0.3', '< 2.0'
  spec.add_dependency 'twitter-text'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
end
