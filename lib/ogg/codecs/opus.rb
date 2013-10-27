module Ogg::Codecs
  class Opus
    class << self
      include VorbisComments
      # return true/false based on whether the header packet belongs to us
      def match?(header_packet)
        header_packet.start_with?("OpusHead")
      end
      
      #consume header and tag pages, return array of two hashes, info and tags 
      def decode_headers(reader)
        init_pkt, tag_pkt = reader.read_packets(2) # init_pkt, tag_pkt
        info = extract_info(init_pkt)
        info[:tag], info[:tag_vendor] = unpack_comments(tag_pkt, "OpusTags")
        info
      end
      
      # consume pages with old tags/setup packets and rewrite newtags,setup packets
      # return the number of pages written
      def replace_tags(reader, writer, new_tags, vendor)
        _ = reader.read_packets(1) # tag_packet
        writer.write_packets(0, pack_comments(new_tags, vendor, "OpusTags"))
      end
      
      def extract_info(packet)
        _, # opus magic signature
        _, # opus_version,
        channels,
        _, # pre skip
        _, # samplerate,
        _, # output gain
        _ = packet.unpack("a8CCvVvC") # channel map
        
        return { :channels => channels, :samplerate => 48000 }
      end
    end
  end
end

