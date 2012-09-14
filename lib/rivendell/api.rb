require "rivendell/api/version"

require "null_logger"
require "active_support/core_ext/module/attribute_accessors"

module Rivendell
  module API

    @@logger = NullLogger.instance
    mattr_accessor :logger

  end
end

require 'httmultiparty'

require "rivendell/api/cart"
require "rivendell/api/cut"
require "rivendell/api/xport"
