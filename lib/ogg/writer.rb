require 'stringio'

module Ogg
  # Writes pages or packets to an output io

  class Writer
    attr_reader :output

    def initialize(bitstream_serial_no, output)
      @output = output
      @page_sequence = 0
      @bitstream_serial_no = bitstream_serial_no
    end
    
    # Writes a page to the output, the serial number and page sequence are
    # are overwritten to be appropriate for this stream.
    def write_page(page)
      page.sequence_no = @page_sequence
      @output << page.pack
      @page_sequence += 1
    end
    
    def write_packets(granule_pos, *packets)
      written_pages_count = 1
      page = Page.new(@bitstream_serial_no, granule_pos)
      packets.each do |packet|
        io = StringIO.new(packet)
        
        while !io.eof? do
          page.segments << io.read(255)
          if (page.segments.length == 255)
            page.granule_pos = -1
            write_page(page)
            page = Page.new(@bitstream_serial_no, granule_pos)
            written_pages_count += 1
          end
        end
        #If our packet was an exact multiple of 255 we need to put in an empty closing segment
        if (page.segments.length == 0 || page.segments.last.length == 255)
          page.segments << ""
        end
      end
      #we always need to flush the final page.
      write_page(page)
      written_pages_count
    end
  end
end
