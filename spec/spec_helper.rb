require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require 'rivendell/api'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

FileUtils.mkdir_p "log"

require "logger"
Rivendell::API.logger = Logger.new("log/test.log")

RSpec.configure do |config|
  

end
