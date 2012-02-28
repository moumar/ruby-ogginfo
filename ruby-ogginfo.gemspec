# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-ogginfo}
  s.version = "0.6.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guillaume Pierronnet", "Grant Gardner"]
  s.date = %q{2012-02-28}
  s.description = %q{ruby-ogginfo gives you access to low level information on ogg files
(bitrate, length, samplerate, encoder, etc... ), as well as tag.
It is written in pure ruby.}
  s.email = ["guillaume.pierronnet@gmail.com", "grant@lastweekend.com.au"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/ogg/codecs/comments.rb", "lib/ogg/codecs/speex.rb", "lib/ogg/codecs/vorbis.rb", "lib/ogg/page.rb", "lib/ogg/reader.rb", "lib/ogg/writer.rb", "lib/ogg.rb", "lib/ogginfo.rb", "setup.rb", "test/test_ruby-ogginfo.rb", "test/test_ruby-spxinfo.rb", ".gemtest"]
  s.homepage = %q{http://ruby-ogginfo.rubyforge.org/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-ogginfo}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{ruby-ogginfo gives you access to low level information on ogg files (bitrate, length, samplerate, encoder, etc..}
  s.test_files = ["test/test_ruby-spxinfo.rb", "test/test_ruby-ogginfo.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<hoe>, ["~> 2.12"])
    else
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<hoe>, ["~> 2.12"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<hoe>, ["~> 2.12"])
  end
end
