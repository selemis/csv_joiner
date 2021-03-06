# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv_joiner/version'

Gem::Specification.new do |s|
  s.name         = 'csv_joiner'
  s.version      =  CsvJoiner::VERSION
  s.author       = 'Ste lios Omirou'
  s.email        = 'selemis@gmail.com'
  s.homepage     = 'http://selemis.home.dyndnds.org'
  s.summary      = 'Utility for joining two csv files'
  s.description  = File.read(File.join(File.dirname(__FILE__), 'README'))
	s.license      = 'MIT'

  s.files         = Dir['{bin,lib,spec}/**/*'] + %w(LICENSE README)
  s.test_files    = Dir['spec/**/*']

  s.required_ruby_version = '>=1.9'
  s.add_development_dependency 'rspec'
end
