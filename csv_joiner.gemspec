Gem::Specification.new do |s|
  s.name         = 'csv_joiner'
  s.version      = '0.1'
  s.author       = 'Stelios Omirou'
  s.email        = 'selemis@gmail.com'
  s.homepage     = 'http://selemis.home.dyndnds.org'
  s.summary      = 'Utility for joining two csv files'
  s.description  = File.read(File.join(File.dirname(__FILE__), 'README'))

  s.files         = Dir['{bin,spec}/**/*'] + %w(LICENSE README)
  s.test_files    = Dir['spec/**/*']
  #s.executables   = [ 'studio_game' ]

  s.required_ruby_version = '>=1.9'
  s.add_development_dependency 'rspec'
end