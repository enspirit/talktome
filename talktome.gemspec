$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'talktome/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'talktome'
  s.version     = Talktome::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Talktome helps you talk to users by email, messaging, sms, etc."
  s.description = "Talktome helps you talk to users by email, messaging, sms, etc. It abstracts the messaging mechanisms and lets you manage message templates easily."
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['LICENSE.md', 'Gemfile','Rakefile', '{bin,lib,spec,tasks,examples}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://github.com/enspirit/talktome'
  s.license     = 'MIT'

  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3.10"
  s.add_development_dependency 'rack-test', '0.6.3'

  s.add_runtime_dependency 'path', '>= 2.0'
  s.add_runtime_dependency 'mail', '~> 2', '>= 2.6.6'
  s.add_runtime_dependency 'mustache', '~> 1'
  s.add_runtime_dependency 'redcarpet','~> 3'
  s.add_runtime_dependency 'sinatra', '>= 2.0', '< 3.0'
  s.add_runtime_dependency "finitio", "~> 0.8.0"
  s.add_runtime_dependency 'rack-robustness', '~> 1.1'
end
