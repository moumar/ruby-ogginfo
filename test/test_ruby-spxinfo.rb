#!/usr/bin/ruby -w

$:.unshift("lib/")

require "test/unit"
require "ogginfo"
require "fileutils"
require "tempfile"

VALID_SPX = <<EOF
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
uTv3X00=
EOF

class SpxInfoTest < Test::Unit::TestCase

  TEMP_FILE = File.join(Dir.tmpdir, "test.spxinfo.spx")
  GEN_FILE = File.join(Dir.tmpdir,"test.spxgen.spx")

  def setup
    valid_spx_file = VALID_SPX.unpack("m*").first
    File.open(TEMP_FILE, "w") { |f| f.write(valid_spx_file) }
  end

  def teardown
    FileUtils.rm_f(TEMP_FILE)
  end

  def test_infos
    OggInfo.open(TEMP_FILE) do |spx|
      assert_equal 1, spx.channels
      assert_equal 32000, spx.samplerate
      assert_in_delta(0.5, spx.length, 1)
      assert_equal "cityrail",spx.tag["author"]
    end
  end

  def test_generated_info
    generate_spx
    OggInfo.open("test.spx") do |spx|
      assert_equal 2, spx.channels
      assert_equal 44100, spx.samplerate
      assert_equal "spxinfotest", spx.tag.author
    end
  end

  def test_tag_writing
    generate_spx
    FileUtils.cp("test.spx",GEN_FILE)
    tag = {"title" => "mytitle", "test" => "myartist" }
    OggInfo.open(GEN_FILE) do |spx|
      spx.tag.clear
      tag.each { |k,v| spx.tag[k] = v }
    end

    OggInfo.open(GEN_FILE) do |spx|
      assert_equal tag, spx.tag
    end
  end

  def generate_spx
    unless test(?f, "test.spx")
      system("dd if=/dev/urandom bs=1024 count=3000 | speexenc --rate 44100 --stereo --author spxinfotest --title SpxInfoTest --comment test=\"hello\303\251\" - test.spx") or
        flunk("cannot generate \"test.spx\", tests cannot be fully performed")
    end
  end
end
