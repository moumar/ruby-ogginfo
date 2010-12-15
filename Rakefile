# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :yard

require 'lib/ogginfo.rb'

Hoe.new('ruby-ogginfo', OggInfo::VERSION) do |p|
  p.rubyforge_name = 'ruby-ogginfo'
  p.author = 'Guillaume Pierronnet'
  p.email = 'moumar@rubyforge.org'
  p.summary = 'ruby-ogginfo is a pure-ruby library that gives low level informations on ogg files'
  p.description = p.paragraphs_of('README.rdoc', 3).first
  p.url = p.paragraphs_of('README.rdoc', 1).first
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.remote_rdoc_dir = ''
  p.rdoc_locations << "rubyforge.org:/var/www/gforge-projects/ruby-ogginfo/"
end

# vim: syntax=Ruby
