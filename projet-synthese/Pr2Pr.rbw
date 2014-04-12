#!/usr/bin/env ruby
$KCODE = 'UTF-8'

$APP_ROOT = File.expand_path(File.dirname(__FILE__))

# Standard libraries
# Patterns
require 'singleton'
require 'observer'
# Hash database
require 'pstore'
# YAML file reader
require 'yaml'

# External libraries
require 'rubygems'

# User interface library
require 'wx'

# XMPP library
require 'xmpp4r'
require 'xmpp4r/bytestreams'
require 'xmpp4r/discovery'
require 'xmpp4r/roster'
require 'xmpp4r/pubsub'
require 'xmpp4r/pubsub/helper/nodebrowser'

# Log library
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/fileoutputter'

# Command line parse library
require 'optparse'

# Include helper library
require 'require_all'

require_all "#{$APP_ROOT}/lib/**/*.rb"

if $0 == __FILE__
  app = Pr2Pr.new
  app.main_loop
end
