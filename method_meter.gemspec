lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'method_meter/version'

Gem::Specification.new do |spec|
  spec.name          = 'method_meter'
  spec.version       = MethodMeter::VERSION
  spec.authors       = ['Wilfrido T. Nuqui Jr.']
  spec.email         = ['nuqui.dev@gmail.com']

  spec.summary       = 'MethodMeter is a library module that instruments methods defined in a given object.'
  spec.description   = 'MethodMeter is a library module that instruments methods defined in a given object.'
  spec.homepage      = 'https://github.com/wnuqui/method_meter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'byebug', '~> 9.1.0' # can be put in Gemfile
end
