= ruby-ogginfo

http://ruby-ogginfo.rubyforge.org/
https://github.com/moumar/ruby-ogginfo

== DESCRIPTION:

ruby-ogginfo gives you access to low level information on ogg files
(bitrate, length, samplerate, encoder, etc... ), as well as tag.
It is written in pure ruby.

== FEATURES/PROBLEMS

* writing tags is now pure ruby 

== SYNOPSIS:

  require "ogginfo"
  OggInfo.open("toto.ogg") do |ogg|
    puts ogg.bitrate
    puts ogg.artist
    puts ogg
  end

== INSTALL:

sudo gem install ruby-ogginfo

== TODO:

* writing tags in pure-ruby

== LICENSE:

Ruby
