require "yaml"
require "tempfile"

def load_fixtures
  fixtures = YAML::load_file(File.join(File.dirname(__FILE__), "fixtures.yml"))
  fixtures.each_with_object({}) do |(codec, content), hash|
    f = File.join(Dir.tmpdir, "/test.ruby-ogginfo.#{codec}")
    File.binwrite(f, content)
    hash[codec] = f
  end
end
