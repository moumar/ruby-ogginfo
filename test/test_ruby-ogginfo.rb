#!/usr/bin/ruby -w
# encoding: utf-8

$:.unshift("lib/")

require "test/unit"
require "ogginfo"
require "fileutils"
require "tempfile"

VALID_OGG = <<EOF
T2dnUwACAAAAAAAAAADjoIphAAAAAIDpYLkBHgF2b3JiaXMAAAAAAkSsAAAA
AAAAAPoAAAAAAAC4AU9nZ1MAAAAAAAAAAAAA46CKYQEAAACKbpIfEC3/////
/////////////8EDdm9yYmlzHQAAAFhpcGguT3JnIGxpYlZvcmJpcyBJIDIw
MDcwNjIyAAAAAAEFdm9yYmlzIUJDVgEAAAEAGGNUKUaZUtJKiRlzlDFGmWKS
SomlhBZCSJ1zFFOpOdeca6y5tSCEEBpTUCkFmVKOUmkZY5ApBZlSEEtJJXQS
OiedYxBbScHWmGuLQbYchA2aUkwpxJRSikIIGVOMKcWUUkpCByV0DjrmHFOO
SihBuJxzq7WWlmOLqXSSSuckZExCSCmFkkoHpVNOQkg1ltZSKR1zUlJqQegg
hBBCtiCEDYLQkFUAAAEAwEAQGrIKAFAAABCKoRiKAoSGrAIAMgAABKAojuIo
jiM5kmNJFhAasgoAAAIAEAAAwHAUSZEUybEkS9IsS9NEUVV91TZVVfZ1Xdd1
Xdd1IDRkFQAAAQBASKeZpRogwgxkGAgNWQUAIAAAAEYowhADQkNWAQAAAQAA
Yig5iCa05nxzjoNmOWgqxeZ0cCLV5kluKubmnHPOOSebc8Y455xzinJmMWgm
tOaccxKDZiloJrTmnHOexOZBa6q05pxzxjmng3FGGOecc5q05kFqNtbmnHMW
tKY5ai7F5pxzIuXmSW0u1eacc84555xzzjnnnHOqF6dzcE4455xzovbmWm5C
F+eccz4Zp3tzQjjnnHPOOeecc84555xzgtCQVQAAEAAAQRg2hnGnIEifo4EY
RYhpyKQH3aPDJGgMcgqpR6OjkVLqIJRUxkkpnSA0ZBUAAAgAACGEFFJIIYUU
UkghhRRSiCGGGGLIKaecggoqqaSiijLKLLPMMssss8wy67CzzjrsMMQQQwyt
tBJLTbXVWGOtueecaw7SWmmttdZKKaWUUkopCA1ZBQCAAAAQCBlkkEFGIYUU
UoghppxyyimooAJCQ1YBAIAAAAIAAAA8yXNER3RER3RER3RER3REx3M8R5RE
SZRESbRMy9RMTxVV1ZVdW9Zl3fZtYRd23fd13/d149eFYVmWZVmWZVmWZVmW
ZVmWZVmC0JBVAAAIAACAEEIIIYUUUkghpRhjzDHnoJNQQiA0ZBUAAAgAIAAA
AMBRHMVxJEdyJMmSLEmTNEuzPM3TPE30RFEUTdNURVd0Rd20RdmUTdd0Tdl0
VVm1XVm2bdnWbV+Wbd/3fd/3fd/3fd/3fd/3dR0IDVkFAEgAAOhIjqRIiqRI
juM4kiQBoSGrAAAZAAABACiKoziO40iSJEmWpEme5VmiZmqmZ3qqqAKhIasA
AEAAAAEAAAAAACia4imm4imi4jmiI0qiZVqipmquKJuy67qu67qu67qu67qu
67qu67qu67qu67qu67qu67qu67qu67ouEBqyCgCQAADQkRzJkRxJkRRJkRzJ
AUJDVgEAMgAAAgBwDMeQFMmxLEvTPM3TPE30RE/0TE8VXdEFQkNWAQCAAAAC
AAAAAAAwJMNSLEdzNEmUVEu1VE21VEsVVU9VVVVVVVVVVVVVVVVVVVVVVVVV
VVVVVVVVVVVVVVVVVVU1TdM0TSA0ZCUAEAUAADpLLdbaK4CUglaDaBBkEHPv
kFNOYhCiYsxBzEF1EEJpvcfMMQat5lgxhJjEWDOHFIPSAqEhKwSA0AwAgyQB
kqYBkqYBAAAAAAAAgORpgCaKgCaKAAAAAAAAACBpGqCJIqCJIgAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAkqYBnikCmigCAAAAAAAAgCaKgGiqgKiaAAAAAAAA
AKCJIiCqIiCaKgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkqYBmigCnigCAAAA
AAAAgCaKgKiagCiqAAAAAAAAAKCJJiCaKiCqJgAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAgAAAgAAHAIAAC6HQkBUBQJwAgMFxLAsAABxJ0iwAAHAk
S9MAAMDSNFEEAABL00QRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAMCAAwBAgAll
oNCQlQBAFACAQTE8DWBZAMsCaBpA0wCeB/A8gCgCAAEAAAUOAAABNmhKLA5Q
aMhKACAKAMCgKJZlWZ4HTdM0UYSmaZooQtM0TxShaZomihBFzzNNeKLnmSZM
UxRNE4iiaQoAAChwAAAIsEFTYnGAQkNWAgAhAQAGR7EsT/M8zxNF01RVaJrn
iaIoiqZpqio0zfNEURRN0zRVFZrmeaIoiqapqqoKTfM8URRF01RVVYXniaIo
mqZpqqrrwvNEURRN0zRV1XUhiqJomqapqqrrukAUTdM0VVVVXReIommapqq6
riwDUTRN01RV15VlYJqqqqqq67qyDFBNVVVV15VlgKq6quu6riwDVFV1XdeV
ZRnguq7ryrJs2wBc13Vl2bYFAAAcOAAABBhBJxlVFmGjCRcegEJDVgQAUQAA
gDFMKaaUYUxCKCE0ikkIKYRMSkqplVRBSCWlUioIqaRUSkalpZRSyiCUUlIq
FYRUSiqlAACwAwcAsAMLodCQlQBAHgAAQYhSjDHGnJRSKcacc05KqRRjzjkn
pWSMMeeck1IyxphzzkkpHXPOOeeklIw555xzUkrnnHPOOSmllM4555yUUkoI
nXNOSimlc845JwAAqMABACDARpHNCUaCCg1ZCQCkAgAYHMeyNE3TPE8UNUnS
NM/zPFE0TU2yNM3zPE8UTZPneZ4oiqJpqirP8zxRFEXTVFWuK4qmaZqqqqpk
WRRF0TRVVXVhmqapqqrqujBNUVRV1XVdyLJpqqrryjJs2zRV1XVlGaiqqsqu
LAPXVVXXlWUBAOAJDgBABTasjnBSNBZYaMhKACADAIAgBCGlFEJKKYSUUggp
pRASAAAw4AAAEGBCGSg0ZEUAECcAACAkpYJOSiWhlFJKKaWUUkoppZRSSiml
lFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSiml
lFJKKaWUUkoppZNSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSiml
lFJKKaWUUkoppZSSUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkkp
pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop
pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop
pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop
pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop
pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop
pZRSSimllAoA0I1wANB9MKEMFBqyEgBIBQAAjFGKMQipxVYhxJhzElprrUKI
MecktJRiz5hzEEppLbaeMccglJJai72UzklJrbUYeyodo5JSSzH23kspJaXY
Yuy9p5BCji3G2HvPMaUWW6ux915jSrHVGGPvvfcYY6ux1t577zG2VmuOBQBg
NjgAQCTYsDrCSdFYYKEhKwGAkAAAwhilGGPMOeecc05KyRhzzkEIIYQQSikZ
Y8w5CCGEEEIpJWPOOQchhFBCKKVkzDnoIIRQQiillM45Bx2EEEIJpZSSMecg
hBBCCaWUUjrnIIQQQiilhFRKKZ2DEEIoIYRSSkkphBBCCKGEUFIpKYUQQggh
hFBCSiWlEEIIIYQQSkilpJRSCCGEEEIIpZSUUgollBBCKKGkkkoppYQQSgih
pFRSKqmUEkIIJYSSSkoplVRKKCGEUgAAwIEDAECAEXSSUWURNppw4QEoNGQl
ABAFAAAZBx2UlhuAkHLUWocchBRbC5FDDFqMnXKMQUopZJAxxqSVkkLHGKTU
YkuhgxR7z7mV1AIAACAIAAgwAQQGCAq+EAJiDABAECIzREJhFSwwKIMGh3kA
8AARIREAJCYo0i4uoMsAF3Rx14EQghCEIBYHUEACDk644Yk3POEGJ+gUlToQ
AAAAAIAFAHgAAEAogIiIZq7C4gIjQ2ODo8PjA0QAAAAAALAA4AMAAAkBIiKa
uQqLC4wMjQ2ODo8PkAAAQAABAAAAABBAAAICAgAAAAAAAQAAAAICT2dnUwAE
AAAAAAAAAADjoIphAgAAAIr86XUBAQA=
====
EOF

class OggInfoTest < Test::Unit::TestCase

  TEMP_FILE = File.join(Dir.tmpdir, "test_ogginfo.ogg")

  def setup
    valid_ogg_file = VALID_OGG.unpack("m*").first
    File.open(TEMP_FILE, "w") { |f| f.write(valid_ogg_file) }
  end

  def teardown
    FileUtils.rm_f(TEMP_FILE)
  end

  def test_infos
    OggInfo.open(TEMP_FILE) do |ogg|
      assert_equal 64000, ogg.nominal_bitrate
      assert_equal 2, ogg.channels
      assert_equal 44100, ogg.samplerate
      assert_in_delta(0.5, ogg.length, 1)
      #average_bitrate
    end
  end

  def test_length
    tf = generate_ogg
    OggInfo.open(tf.path) do |ogg|
      assert_in_delta(17.0, ogg.length, 1, "length has not been correctly guessed")
      assert_in_delta(67000.0, ogg.bitrate, 2000, "bitrate has not been correctly guessed")
    end
  end

  def test_writing_to_spedial_filenames
    tf = generate_ogg
    filename = "fichier éé.ogg"
    FileUtils.cp(tf.path, filename)
    begin
      OggInfo.open(tf.path) do |ogg|
        ogg.tag.title = "a"*200
      end
      #system("ls", "-l", filename)
    ensure
      FileUtils.rm_f(filename) 
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

  def test_should_not_fail_when_input_is_truncated
    valid_ogg = generate_ogg
    ogg_length = nil
    OggInfo.open(valid_ogg.path) do |ogg|
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

  protected

  def generate_ogg
    generated_ogg_file_path = File.join(File.dirname(__FILE__), "test.ogg")
    unless test(?f, generated_ogg_file_path)
      system("dd if=/dev/urandom bs=1024 count=3000 | oggenc -q0 --raw -o #{generated_ogg_file_path} -") or
        flunk("cannot generate \"#{generated_ogg_file_path}\", tests cannot be fully performed")
    end
    tf = Tempfile.new("ruby-ogginfo")
    tf.close
    FileUtils.cp(generated_ogg_file_path, tf.path)
    tf
  end

  def generate_truncated_ogg
    valid_ogg = generate_ogg
    tf = Tempfile.new("ruby-ogginfo")
    data = File.read(valid_ogg.path, File.size(valid_ogg.path) - 10000)
    tf.write(data)
    tf.close
    tf
  end

  def tag_test(test_name, tag) 
    tf = generate_ogg

    OggInfo.open(tf.path) do |ogg|
      tag.each { |k,v| ogg.tag[k] = v }
    end

    OggInfo.open(tf.path) do |ogg|
      assert_equal tag, ogg.tag
    end
    system("cp #{tf.path} /tmp/test_#{RUBY_VERSION}_#{test_name}.ogg")
    test_length
    assert_nothing_raised do
      io = open(tf.path)
      reader = Ogg::Reader.new(io)
      reader.each_pages do |page|
        page
      end
    end
  end
end
