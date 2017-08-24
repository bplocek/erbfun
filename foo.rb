#!/usr/bin/env ruby

require 'erb'
require 'yaml'
require 'optparse'
require 'ostruct'

class ERBContext
  def initialize(hash)
    raise ArgumentError, 'hash must be a Hash object' unless hash.is_a?(::Hash)
    @instances = hash
  end
 
  def render(template)
    template.result binding
  end
 
  class << self
    def render(hash, template, safe_level = nil, trim_mode = nil, eoutvar = '_erbout')
      tmpl = ::ERB.new(template, safe_level, trim_mode, eoutvar)
      context = new(hash)
      context.render tmpl
    end
  end
end
 
def file_or_stdin(args, stdin = ::STDIN)
  if args.empty? || args.first == '-'
    yield stdin
  else
    File.open args.first, 'r' do |f|
      yield f
    end
  end
end
 
def main
  options = OpenStruct.new
  options.yaml = nil
 
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: %s [options] file.erb' % $0
 
    opts.on '-y', '--yaml=YAML-FILE', 'YAML file to populate local variables for the template' do |yaml_file|
      File.open yaml_file, 'r' do |f|
        options.yaml = YAML.load(f)
      end
    end
  end
 
  if (args = parser.parse(ARGV)).length > 1
    STDERR.puts '%s: cannot render more than 1 file at a time!' % $0
    exit 1
  end
 
  file_or_stdin args do |input|
    puts ERBContext.render(options.yaml || {}, input.read, nil, '-')
  end
end
 
main if __FILE__ == $0
