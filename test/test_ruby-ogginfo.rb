#!/usr/bin/ruby -w
# encoding: utf-8

$:.unshift("lib/")

require "test/unit"
require "ogginfo"
require "fileutils"
require "tempfile"
require File.join(File.dirname(__FILE__), "test_helper")

class OggInfoTest < Test::Unit::TestCase
  def setup
    @tempfile = load_fixtures[:ogg]
  end

  def teardown
    FileUtils.rm_f(@tempfile)
  end

  def test_infos
    OggInfo.open(@tempfile) do |ogg|
      assert_equal 64000, ogg.nominal_bitrate
      assert_equal 2, ogg.channels
      assert_equal 44100, ogg.samplerate
      assert_in_delta(3, ogg.length, 0.5)
    end
  end

  def test_length
    OggInfo.open(@tempfile) do |ogg|
      assert_in_delta(3, ogg.length, 0.3, "length has not been correctly guessed")
      assert_in_delta(64000.0, ogg.bitrate, 10000, "bitrate has not been correctly guessed")
    end
  end

  def test_should_not_fail_when_input_is_truncated
    ogg_length = nil
    OggInfo.open(@tempfile) do |ogg|
      ogg_length = ogg.length
    end

    tf = generate_truncated_ogg
    OggInfo.open(tf.path) do |truncated_ogg|
      assert ogg_length != truncated_ogg.length
    end

    reader = Ogg::Reader.new(open(tf.path, "r"))
    last_page = nil
    reader.each_pages do |page|
      last_page = page
    end
    assert_not_equal Ogg.compute_checksum(last_page.pack), last_page.checksum
  end

  def test_checksum
    tf = generate_truncated_ogg
    reader = Ogg::Reader.new(open(tf.path))
    assert_raises(Ogg::StreamError) do
      reader.each_pages(:checksum => true) do |page|
        page
      end
    end
  end

  def test_picture
    tf = Tempfile.new(["ruby-ogginfo", ".jpg"])
    jpg_content = (0...1000).collect { rand(256).chr }.join("")
    tf.write(jpg_content)
    tf.close
    OggInfo.open(@tempfile) do |ogg|
      ogg.picture = tf.path
    end
    OggInfo.open(@tempfile) do |ogg|
      assert ogg.tag.has_key?("metadata_block_picture")

      type, # picture type
      _, # mime_type size
      mime_type, 
      _, # description size
      description, 
      _, # width
      _, # height
      _, # color depth
      _, # number of color used
      file_content_size, 
      file_content = ogg.tag["metadata_block_picture"].unpack("m*").first.unpack("NNa10Na10NNNNNa*")
      assert_equal 3, type
      assert_equal "image/jpeg", mime_type
      assert_equal "folder.jpg", description
      assert_equal jpg_content.size, file_content_size
      assert_equal jpg_content, file_content

      assert_equal [".jpg", jpg_content], ogg.picture
    end
  end

  protected

  def generate_truncated_ogg
    tf = Tempfile.new("ruby-ogginfo")
    s = File.size(@tempfile) 
    data = File.read(@tempfile, (s - s*0.75).to_i)
    tf.write(data)
    tf.close
    tf
  end
end
