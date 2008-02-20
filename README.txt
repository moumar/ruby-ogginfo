= Ruby-ogginfo_

http://ruby-ogginfo.rubyforge.org/

== DESCRIPTION:

ruby-ogginfo gives you access to low level information on ogg files
(bitrate, length, samplerate, encoder, etc... ), as well as tag.
It is written in pure ruby.

== SYNOPSIS:

require "ogginfo"
ogg = OggInfo.new("toto.ogg")
puts ogg.bitrate
puts ogg.artist

== INSTALL:

sudo gem install ruby-ogginfo

== LICENSE:

Ruby
