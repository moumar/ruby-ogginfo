#!/usr/bin/ruby -w

$:.unshift("lib/")

require "test/unit"
require "ogginfo"
require "fileutils"
require "tempfile"
require File.join(File.dirname(__FILE__), "test_helper")

class OtherCodecsInfoTest < Test::Unit::TestCase
  CODECS = [:speex, :opus]

  def setup
    @fixtures = load_fixtures 
  end

  def test_generated_info
    CODECS.each do |codec|
      OggInfo.open(@fixtures[codec]) do |ogg|
        assert_equal 2, ogg.channels
        assert_equal 48000, ogg.samplerate
        assert_in_delta(3, ogg.length, 0.2, "length has not been correctly guessed for codec \"#{codec}\"")
        case codec 
        when :speex
          assert_equal "spxinfotest", ogg.tag.author
        when :opus
          assert_in_delta 64000, ogg.bitrate, 2000
          assert_equal "artist", ogg.tag.artist
        end
      end
    end
  end

  def test_tag_writing
    CODECS.each do |codec|
      tag = {"title" => "mytitle", "test" => "myartist" }
      OggInfo.open(@fixtures[codec]) do |ogg|
        ogg.tag.clear
        tag.each { |k,v| ogg.tag[k] = v }
      end

      OggInfo.open(@fixtures[codec]) do |ogg|
        assert_equal tag, ogg.tag
      end
    end
  end
end
