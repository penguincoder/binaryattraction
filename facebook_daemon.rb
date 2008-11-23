#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

opts = {
  :app_name => 'binaryattraction_facebooker',
  :dir_mode => :script,
  :dir => '/log',
  :backtrace => true,
  :multiple => true,
  :log_output => true
}

Daemons.run(File.dirname(__FILE__) + '/binaryattraction_facebooker.rb', opts)
