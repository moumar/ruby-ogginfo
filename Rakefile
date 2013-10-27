# -*- ruby -*-

require 'hoe'

Hoe.plugin :yard
Hoe.plugin :git
Hoe.plugin :rcov
Hoe.plugin :gemspec

Hoe.spec('ruby-ogginfo') do 
  developer('Guillaume Pierronnet','guillaume.pierronnet@gmail.com')
  developer('Grant Gardner','grant@lastweekend.com.au')
  #summary = 'ruby-ogginfo is a pure-ruby library that gives low level informations on ogg files'
  remote_rdoc_dir = ''
  rdoc_locations << "rubyforge.org:/var/www/gforge-projects/ruby-ogginfo/"
end

desc "generate audio fixtures"
task :generate_fixtures do
  ffmpeg = "ffmpeg -f u16le -i /dev/urandom -t 3 -ar 48000 -ac 2 -f wav -y - 2>/dev/null" 
  files = {
    :ogg => "oggenc -q0 --raw --artist=artist -o - -",
    :opus => "opusenc --bitrate 64 --artist=artist - -",
    :speex => "speexenc --rate 48000 --stereo --author spxinfotest --title SpxInfoTest --comment test=\"hello\303\251\" - -"
  }.each_with_object({}) do |(codec, cmd), hash|
    hash[codec] = `#{ffmpeg} | #{cmd}`
  end
  File.binwrite("test/fixtures.yml", files.to_yaml)
end

# vim: syntax=Ruby
