require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'ichiban', 'version'))

Gem::Specification.new do |s|
  s.name         = 'ichiban'
  s.version      = Ichiban::VERSION
  s.date         = '2015-11-20'
  s.summary      = 'Ichiban'
  s.description  = 'Static website compiler with advanced features, including watcher script.'
  s.authors      = ['Jarrett Colby']
  s.email        = 'jarrett@madebyhq.com'
  # Hidden files must be listed individually.
  s.files        = Dir.glob('lib/**/*') + Dir.glob('empty_project/**/*') + ['empty_project/compiled/.htaccess']
  s.executables  = ['ichiban']
  s.homepage     = 'https://github.com/jarrett/ichiban'
  
  s.add_runtime_dependency 'ejs', '>= 1.1.1', '~> 1'
  s.add_runtime_dependency 'erubis', '>= 2.7.0', '~> 2'
  s.add_runtime_dependency 'sass', '>= 3.3.14', '~> 3'
  s.add_runtime_dependency 'listen', '>= 2.10.1', '~> 2'
  s.add_runtime_dependency 'activesupport', '>= 4.1.5', '~> 4'
  s.add_runtime_dependency 'bundler', '>= 1.5.1', '~> 1'
  s.add_runtime_dependency 'uglifier', '>= 2.7.2', '~> 2'
  s.add_runtime_dependency 'therubyracer', '>= 0.12.2', '~> 0'
  s.add_runtime_dependency 'source_map', '>= 3.0.1'
  
  # Will be the :development group in Bundler.
  s.add_development_dependency 'rake', '>= 10.3.2', '~> 10'
  s.add_development_dependency 'minitest', '>= 5.4.1', '~> 5'
  s.add_development_dependency 'minitest-reporters', '>= 1.0.5', '~> 1'
  s.add_development_dependency 'mocha', '>= 1.1.0', '~> 1'
  s.add_development_dependency 'lorax', '>= 0.2.0', '~> 0'
  s.add_development_dependency 'rdiscount', '>= 2.1.7', '~> 2'
  s.add_development_dependency 'json-compare', '>= 0.1.8', '~> 0'
  
  s.post_install_message = File.read(File.join(File.dirname(__FILE__), 'post_install_message.txt'))
end