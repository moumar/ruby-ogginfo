require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'ruby-ogginfo'
  s.version = "0.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "ruby-ogginfo is a pure-ruby library that gives low level informations on ogg files"
  s.files = %w{ogginfo.rb}
  #s.require_path = 'lib'
  s.author = "Guillaume Pierronnet"
  s.email = "moumar@rubyforge.org"
  s.rubyforge_project = "ruby-ogginfo"
  s.homepage = "http://ruby-ogginfo.rubyforge.org"
  s.has_rdoc = false
end

if $0==__FILE__
  Gem.manage_gems
  Gem::Builder.new(spec).build
end
