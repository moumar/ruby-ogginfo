#!/usr/bin/ruby -w

$:.unshift("lib/")

require "test/unit"
require "ogginfo"
require "fileutils"
require "tempfile"
require File.join(File.dirname(__FILE__), "test_helper")

class OtherCodecsInfoTest < Test::Unit::TestCase
  def setup
    @fixtures = load_fixtures 
  end

  def test_generated_info
    @fixtures.each do |codec, tempfile|
      OggInfo.open(tempfile) do |ogg|
        assert_equal 2, ogg.channels
        case codec 
        when :speex
          assert_equal "spxinfotest", ogg.tag.author
        when :opus
          assert_in_delta(3, ogg.length, 0.2, "length has not been correctly guessed for codec \"#{codec}\"")
          assert_in_delta 64000, ogg.bitrate, 2000
          assert_equal "artist", ogg.tag.artist
          assert_equal 48000, ogg.samplerate
        when :ogg
          assert_in_delta(3, ogg.length, 0.5, "length has not been correctly guessed for codec \"#{codec}\"")
          assert_in_delta 64000, ogg.bitrate, 10000
          assert_equal "artist", ogg.tag.artist
          assert_equal 44100, ogg.samplerate
        end
      end
    end
  end

  def test_tag_writing
    @fixtures.each do |codec, tempfile|
      tag = {"title" => "mytitle", "test" => "myartist" }
      OggInfo.open(tempfile) do |ogg|
        ogg.tag.clear
        tag.each { |k,v| ogg.tag[k] = v }
      end

      OggInfo.open(@fixtures[codec]) do |ogg|
        assert_equal tag, ogg.tag
      end
    end
  end

  def test_good_writing_of_utf8_strings
    tag = { "title" => "this is a éé utf8 string",
            "artist" => "and è another one à"}
    tag_test("tag_writing", tag)
  end

  def test_tag_writing
    data = "a"*256
    tag_test("tag_writing", "title" => data, "artist" => data )
  end

  def test_big_tags
    data = "a"*60000
    tag_test("big_tags", "title" => data, "artist" => data )
  end

  def tag_test(test_name, tag)
    @fixtures.each do |codec, tempfile|
      OggInfo.open(tempfile) do |ogg|
        ogg.tag.clear
        tag.each { |k,v| ogg.tag[k] = v }
      end

      OggInfo.open(tempfile) do |ogg|
        assert_equal tag, ogg.tag
      end
      FileUtils.cp(tempfile, "/tmp/test_#{RUBY_VERSION}_#{test_name}.ogg")
      assert_nothing_raised do
        io = open(tempfile)
        reader = Ogg::Reader.new(io)
        reader.each_pages do |page|
          page
        end
      end
    end
  end

  def test_unicode_support
    @fixtures.each do |codec, tempfile|
      filename = "fichier éé.#{codec}"
      FileUtils.cp(tempfile, filename)
      begin
        OggInfo.open(tempfile) do |ogg|
          ogg.tag.artist = "artistéoo"
          ogg.tag.title = "a"*200
        end
      ensure
        FileUtils.rm_f(filename) 
      end
    end
  end

end
