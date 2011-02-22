require "codecs/comments"
require "codecs/vorbis"
require "codecs/speex"

module Ogg
  CODECS = [Vorbis.new(),Speex.new()]
  
  def self.detect_codec(input)
    if input.kind_of?(Page)
      first_page = input
    else
      first_page = Page.read(input)
      input.rewind()
    end
    
    codec = CODECS.detect { | codec | codec.match?( first_page.segments.first) }
    
    unless codec
      raise(StreamError,"unknown codec")
    end
    
    return codec
  end
  
  
end
