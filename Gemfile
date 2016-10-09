alias __source_distinct__ source
def source(url)
  @loaded ||= {}
  unless @loaded[url]
    @loaded[url] = true
    __source_distinct__(url) end end

source 'https://rubygems.org'

gemspec

group :plugin do
  Dir.glob(File.expand_path(File.join(__dir__, 'core/plugin/*/Gemfile'))){ |path|
    eval File.open(path).read
  }
  Dir.glob(File.join(File.expand_path(ENV['MIKUTTER_CONFROOT'] || '~/.mikutter'), 'plugin/*/Gemfile')){ |path|
    eval File.open(path).read
  }
end
