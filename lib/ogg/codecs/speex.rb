module Ogg::Codecs
  class Speex
    class << self
      include VorbisComments

      def match?(packet)
        /^Speex/ =~ packet
      end
      
      def decode_headers(reader)
        init_packet, tag_packet = reader.read_packets(2)
        info = extract_info(init_packet)
        info[:tag], info[:tag_vendor] = unpack_comments(tag_packet)
        return info
      end
      
      def replace_tags(reader, writer, new_tags, vendor)
        tag_packet = reader.read_packets(1)
        writer.write_packets(0, pack_comments(new_tags, vendor))
      end
      
      def extract_info(info_packet)
        speex_string,
        speex_version,
        speex_version_id,
        header_size,
        samplerate,
        mode,
        mode_bitstream_version,
        channels,
        nominal_bitrate,
        framesize,
        vbr = info_packet.unpack("A8A20VVVVVVVVV")
        #not sure how to make sense of the bitrate info,picard doesn't show it either...
        
        return { :channels => channels, :samplerate => samplerate, :nominal_bitrate => nominal_bitrate }
      end
    end
  end
end
