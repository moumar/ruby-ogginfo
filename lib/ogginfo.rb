# $Id: ogginfo.rb 39 2008-03-15 17:21:31Z moumar $
#
# see http://www.xiph.org/ogg/vorbis/docs.html for documentation on vorbis format
# http://www.xiph.org/ogg/vorbis/doc/v-comment.html
# 
# License: ruby

require "iconv"

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
  VERSION = "0.3.2"
  attr_reader :channels, :samplerate, :bitrate, :nominal_bitrate, :length
  
  # +tag+ is a hash containing the vorbis tag like "Artist", "Title", and the like
  attr_reader :tag

  # create new instance of OggInfo, using +charset+ to convert tags to
  def initialize(filename, charset = "iso-8859-1")
    @filename = filename
    @charset = charset
    @file = File.new(@filename, "rb")

    find_next_page
    extract_infos
    find_next_page
    extract_tag
    convert_tag_charset("utf-8", @charset)
    @saved_tag = @tag.dup
    extract_end
    @bitrate = @file.stat.size.to_f*8/@length
    @file.close
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

  # write any tags to file
  def close
    if @tag != @saved_tag
      cmd = %w{vorbiscomment -w} 
      convert_tag_charset(@charset, "utf-8")

      @tag.each do |k,v|
        cmd.concat(["-t", k.upcase+"="+v])
      end
      cmd << @filename
      system(*cmd)
    end
  end

  # check the presence of a tag
  def hastag?
    !@tag.empty?
  end
  
  def to_s
    "channels #{@channels} samplerate #{@samplerate} bitrate #{@nominal_bitrate} bitrate #{@bitrate} length #{@length} #{@tag.inspect}"
  end

private
  def find_next_page
    header = 'OggS' # 0xf4 . 0x67 . 0x 67 . 0x53
    bytes = @file.read(4)
    bytes_read = 4

    while header != bytes
      #raise OggInfoError if bytes_read > 4096 or @file.eof? #bytes.nil?
      raise OggInfoError if @file.eof? #bytes.nil?
      bytes.slice!(0)
      char = @file.read(1)
      bytes_read += 1
      bytes << char
    end
  end

  def extract_infos
    @file.seek(35, IO::SEEK_CUR) # seek after "vorbis"
    @channels, @samplerate, up_br, @nominal_bitrate, down_br = @file.read(17).unpack("CV4")
    if @nominal_bitrate == 0
      if up == 2**32 - 1 or down == 2**32 - 1 
	@nominal_bitrate = 0
      else
	@nominal_bitrate = (up_br + down_br)/2
      end
    end
  end

  def extract_tag
    @tag = {}
    @file.seek(22, IO::SEEK_CUR)
    segs = @file.read(1).unpack("C")[0]
    @file.seek(segs + 7, IO::SEEK_CUR)
    size = @file.read(4).unpack("V")[0]
    @file.seek(size, IO::SEEK_CUR)
    tag_size = @file.read(4).unpack("V")[0]

    tag_size.times do |i|
      size = @file.read(4).unpack("V")[0]
      comment = @file.read(size)
      key, val = comment.split(/=/, 2)
      @tag[key.downcase] = val
    end
  end

  def extract_end
    begin #Errno::EINVAL
      @file.seek(-5000, IO::SEEK_END) #FIXME size of seeking
      find_next_page
      pos = @file.read(6).unpack("x2 V")[0] #FIXME pos is int64
      @length = pos.to_f / @samplerate
    rescue Errno::EINVAL
      @length = 0
    end
  end

  def convert_tag_charset(from_charset, to_charset)
    Iconv.open(to_charset, from_charset) do |ic|
      @tag.each do |k, v|
        @tag[k] = ic.iconv(v)
      end
    end
  end
end
