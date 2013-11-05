require 'serverengine'
require 'optparse'
require 'logger'

require_relative 'script'
Dir.glob("#{File.dirname(__FILE__)}/plugins/*") do |file|
  require_relative file
end
require_relative 'daemon'
