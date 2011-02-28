# see http://www.xiph.org/ogg/vorbis/docs.html for documentation on vorbis format
# http://www.xiph.org/vorbis/doc/v-comment.html
# http://www.xiph.org/vorbis/doc/framing.html
# 
# License: ruby
$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))

require "iconv"
require 'forwardable'
require 'ogg/framing'

class Hash 
   ### lets you specify hash["key"] as hash.key
   ### this came from CodingInRuby on RubyGarden
   ### http://www.rubygarden.org/ruby?CodingInRuby 
   def method_missing(meth,*args) 
     if /=$/=~(meth=meth.id2name) then
       self[meth[0...-1]] = (args.length<2 ? args[0] : args)
     else
       self[meth]
     end
   end
end
					    
# Raised on any kind of error related to ruby-ogginfo
class OggInfoError < StandardError ; end

class OggInfo
  VERSION = "0.6"
  extend Forwardable
  
  attr_reader :channels, :samplerate, :nominal_bitrate
  
  # +tag+ is a hash containing the vorbis tag like "Artist", "Title", and the like
  attr_reader :tag
  		
  # create new instance of OggInfo, using +charset+ to convert tags
  def initialize(filename, charset = "utf-8")
    @filename = filename
    @charset = charset
    @length = nil
    @bitrate = nil
    filesize = File.size(@filename)
    File.open(@filename) do |file|
      begin
     	info = Ogg.read_headers(file)
        @samplerate = info[:samplerate]
        @nominal_bitrate = info[:nominal_bitrate]
        @channels = info[:channels]
        @tag = info[:tag]
        # filesize is used to calculate bitrate
        # but we don't want to include the headers
        @filesize = file.stat.size - file.pos
      rescue Ogg::StreamError => se
        raise(OggInfoError, se.message, se.backtrace)
      end
    end

    convert_tag_charset("utf-8", @charset)
    @original_tag = @tag.dup
  end

  # The length in seconds of the track
  # since this requires reading the whole file we only get it
  # if called
  def length
    unless @length
      File.open(@filename) do |file|
       @length = Ogg.length(file,@samplerate)
      end
    end
    return @length 
  end
  
  # Calculated bit rate, also lazily loaded
  # since we depend on the length
  def bitrate
    @bitrate ||= (@filesize * 8).to_f / length()
  end
  
  # "block version" of ::new()
  def self.open(*args)
    m = self.new(*args)
    ret = nil
    if block_given?
      begin
        ret = yield(m)
      ensure
        m.close
      end
    else
      ret = m
    end
    ret
  end

  # commits any tags to file
  def close
    if tag != @original_tag
      convert_tag_charset(@charset, "utf-8")
      tmpfile = @filename + ".vctemp"
      #return unless File.writable?(tmpfile)
      
      File.open(tmpfile,"w") do | output |
        File.open(@filename) do | input |
          Ogg.replace_tags(input, output, tag)
      	end
      end
      FileUtils.move(tmpfile, @filename)
    end
  end

  # check the presence of a tag
  def hastag?
    !tag.empty?
  end
  
  def to_s
    "channels #{channels} samplerate #{samplerate} bitrate #{nominal_bitrate} #{tag.inspect}"
  end

private

  def convert_tag_charset(from_charset, to_charset)
    return if from_charset == to_charset
    Iconv.open(to_charset, from_charset) do |ic|
      tag.each do |k, v|
        tag[k] = ic.iconv(v)
      end
    end
  end
end
