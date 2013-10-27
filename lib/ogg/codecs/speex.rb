module Ogg::Codecs
  class Speex
    class << self
      include VorbisComments

      def match?(header_packet)
        header_packet.start_with?("Speex")
      end
      
      def decode_headers(reader)
        init_packet, tag_packet = reader.read_packets(2)
        info = extract_info(init_packet)
        info[:tag], info[:tag_vendor] = unpack_comments(tag_packet)
        return info
      end
      
      def replace_tags(reader, writer, new_tags, vendor)
        _ = reader.read_packets(1) # tag_packet
        writer.write_packets(0, pack_comments(new_tags, vendor))
      end
      
      def extract_info(info_packet)
        _, #speex_string,
        _, #speex_version,
        _, #speex_version_id,
        _, #header_size,
        samplerate,
        _, #mode,
        _, #mode_bitstream_version,
        channels,
        nominal_bitrate,
        #framesize, vbr
        _, _ = info_packet.unpack("A8A20VVVVVVVVV")
        #not sure how to make sense of the bitrate info,picard doesn't show it either...
        
        return { :channels => channels, :samplerate => samplerate, :nominal_bitrate => nominal_bitrate }
      end
    end
  end
end
