# frozen_string_literal: true

require_relative "lib/peplum/nmap/version"

Gem::Specification.new do |spec|
  spec.name = "peplum-nmap"
  spec.version = Peplum::Nmap::VERSION
  spec.authors = ["Tasos Laskos"]
  spec.email = ["tasos.laskos@ecsypno.com"]

  spec.summary = "Distributed NMap."
  spec.description = "Distributed NMap backed by Peplum."
  spec.homepage = "http://ecsypno.com/"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files  = Dir.glob( 'bin/*')
  spec.files += Dir.glob( 'lib/**/*')
  spec.files += Dir.glob( 'examples/**/*')
  spec.files += %w(peplum-nmap.gemspec)


  spec.add_dependency "peplum"
  spec.add_dependency 'ruby-nmap'
end
