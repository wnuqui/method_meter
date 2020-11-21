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

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'awesome_print'
  spec.add_runtime_dependency 'defined_methods'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
