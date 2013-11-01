require 'bundler'
Bundler.require

require 'serverengine'
require 'optparse'
require 'logger'

require_relative 'daemon'

config = {
  script: 'default.leanci',
  pid_path: 'leanci.pid',
  log: 'leanci.log'
}
OptionParser.new do |opt|
  opt.on('-f VALUE', 'specify leanci file') do |f|
    config[:script] = f
  end
  opt.on('--pid VALUE', 'pid file') do |f|
    config[:pid_path] = f
  end
  opt.parse!(ARGV)
end

run_daemon(config)
=begin
File.open(config[:script]) do |f|
  Script.new(Logger.new('myserver.log'), f.read)
end
=end
