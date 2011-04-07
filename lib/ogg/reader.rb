module Ogg
  #Reads pages and packets from an ogg stream
  class Reader
    attr_reader :input

    def initialize(input)
      @input = input
    end
    
    def each_pages(options = {})
      until @input.eof?
        yield Page.read(@input, options)
      end
    end
    
    def read_packets(max_packets)
      result = []
      partial_packet = ""
      each_pages do |page|
        partial_packet = page.segments.inject(partial_packet) do |packet,segment|
          packet << segment
          if segment.length < 255
            #end of packet
            result << packet
            return result if result.length == max_packets
            ""
          else
            packet
          end
        end
      end
      # We expect packets to reach page boundaries, consider raising exception if partial_packet here.
      result
    end
  end
  
end
