module Ogg
  class Page
    attr_accessor :granule_pos, :bitstream_serial_no, :sequence_no, :segments, :header
    attr_reader :checksum
    
    # read an ogg frame from the +file+
    # file must be positioned at end of frame after this loop
    # options - :skip_body = seek to end of frame rather than reading in the data
    def self.read(io, options = {})
      return nil if io.eof?
      
      chunk = io.read(27)
      
      capture_pattern,
      _,        # version
      header,
      granule_pos,
      bitstream_serial_no,
      sequence_no,
      @checksum,
      segments = chunk.unpack("a4CCQVVVC") #a4CCQNNNC
      
      if capture_pattern != "OggS"
        raise(StreamError, "bad magic number")
      end
      
      page = Page.new(bitstream_serial_no, granule_pos)
      page.header = header
      page.sequence_no = sequence_no
      
      unless io.eof?
        segment_sizes = io.read(segments).unpack("C*")
        if options[:skip_body]
          body_size = segment_sizes.inject(0) { |sum, i| sum + i }
          io.seek(body_size, IO::SEEK_CUR)
        else
          segment_sizes.each do |size| 
            break if io.eof?
            page.segments << io.read(size)
          end
          if options[:checksum] 
            if @checksum != Ogg.compute_checksum(page.pack)
              raise(StreamError, "bad checksum: expected #{ @checksum }, got #{ page.checksum }")
            end
          end
        end
      end
        
      page
    end
    
    def initialize(bitstream_serial_no = 0, granule_pos = 0)
      @bitstream_serial_no = bitstream_serial_no
      @granule_pos = granule_pos
      @segments = []
      @header = 0
    end
    
    def pack
      packed =  [
        "OggS",
        0, #version
        @header,
        @granule_pos,
        @bitstream_serial_no,
        @sequence_no,
        0, #checksum
        @segments.length
      ].pack("a4CCQVVVC")
      
      packed << @segments.collect { |segment| segment.length }.pack("C*")
      packed << @segments.join
      crc = Ogg.compute_checksum(packed)
      packed[22..25] = [crc].pack("V")
      packed
    end
   
  end
end
