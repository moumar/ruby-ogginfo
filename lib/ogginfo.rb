# see http://www.xiph.org/ogg/vorbis/docs.html for documentation on vorbis format
# http://www.xiph.org/vorbis/doc/v-comment.html
# http://www.xiph.org/vorbis/doc/framing.html
# 
# License: ruby

require 'forwardable'
require "tempfile"
require File.join(File.dirname(__FILE__), 'ogg.rb')

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
  VERSION = "0.7.2"
  extend Forwardable
  include Ogg
  
  attr_reader :channels, :samplerate, :nominal_bitrate
  
  # +tag+ is a hash containing the vorbis tag like "Artist", "Title", and the like
  attr_reader :tag
  		
  # create new instance of OggInfo
  # use of charset is deprecated! please use utf-8 encoded strings and leave +charset+ to nil")
  def initialize(filename, charset = nil)
    if charset
      warn("use of charset is deprecated! please use utf-8 encoded tags")
    end
    @filename = filename
    @length = nil
    @bitrate = nil
    File.open(@filename, 'rb') do |file|
      begin
     	info = read_headers(file)
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

    @original_tag = @tag.dup
  end

  # The length in seconds of the track
  # since this requires reading the whole file we only get it
  # if called
  def length
    unless @length
      File.open(@filename) do |file|
        @length = compute_length(file)
      end
    end
    return @length 
  end
  
  # Calculated bit rate, also lazily loaded
  # since we depend on the length
  def bitrate
    @bitrate ||= (@filesize * 8).to_f / length()
  end

  # set a picture (.jpg or .png) on the ogg file
  def picture=(filepath)
    ext = File.extname(filepath)
    mime_type = {
      ".jpg" => "image/jpeg",
      ".png" => "image/png"
    }[ext]
    description = "folder#{ext}"
    raw_string = 
      [3,               # picture type
       mime_type.size,
       mime_type,
       description.size,
       description,
       0,               # width
       0,               # height
       0,               # color depth
       0,               # number of colors used
       File.size(filepath),
       File.binread(filepath)
      ].pack("NNa*Na*NNNNNa*")
       
    @tag["METADATA_BLOCK_PICTURE"] = [raw_string].pack("m*").strip
  end
  
  # get the picture as an array of [extension, file_content]
  # or nil if not existent
  def picture
    extensions = {
      "image/jpeg" => ".jpg",
      "image/png" => ".png" 
    }

    if content = tag["metadata_block_picture"]
      _, #type, # picture type
      _, # mime_type size
      mime_type, 
      _, # description size
      _, # description, 
      _, # width
      _, # height
      _, # color depth
      _, # number of color used
      _, #file_content_size, 
      file_content = content.unpack("m*").first.unpack("NNa10Na10NNNNNa*")
      return [extensions[mime_type], file_content]
    end
    nil
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
      Tempfile.open(["ruby-ogginfo", ".ogg"]) do |tempfile|
        tempfile.close
        tempfile = File.new(tempfile.path, "wb")
        File.open(@filename, "rb") do | input |
          replace_tags(input, tempfile, tag)
        end
        tempfile.close
        FileUtils.cp(tempfile.path, @filename)
      end
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

  def read_headers(input)
    reader = Reader.new(input)
    codec = Ogg.detect_codec(input)
    codec.decode_headers(reader)
  end
  
  # For both Vorbis and Speex, the granule_pos is the number of samples
  # strictly this should be a codec function.
  def compute_length(input)
    reader = Reader.new(input)
    last_page = nil

    begin
      reader.each_pages(:skip_body => true, :skip_checksum => true) do |page| 
        if page.granule_pos
          last_page = page
        end
      end
    rescue Ogg::StreamError
    end

    if last_page
      return last_page.granule_pos.to_f / @samplerate
    else
      return 0
    end
  end
  

  # Pipe input to output transforming tags along the way
  # input/output must be open streams reading for reading/writing  
  def replace_tags(input, output, new_tags, vendor = "ruby-ogginfo")
    # use the same serial number...
    first_page = Page.read(input)
    codec = Ogg.detect_codec(first_page)
    bitstream_serial_no = first_page.bitstream_serial_no
    reader = Reader.new(input)
    writer = Writer.new(bitstream_serial_no, output)

    # Write the first page as is (including presumably the b_o_s header)
    writer.write_page(first_page)
    
    upcased_tags = new_tags.inject({}) do |memo, (k, v)| 
      memo[k.upcase] = v
      memo
    end
    # The codecs we know about put comments etc in following pages
    # as suggested by the spec
    written_pages_count = codec.replace_tags(reader, writer, upcased_tags, vendor)
    if written_pages_count > 1
      # Write the rest of the pages. We have to do page at a time
      # because our tag replacement may have changed the number of
      # pages and thus every subsequent page needs to have its
      # sequence_no updated.
      reader.each_pages(:skip_checksum => true) do |page|
        writer.write_page(page)
      end
    else
      FileUtils.copy_stream(reader.input, writer.output)
    end
  end
end
