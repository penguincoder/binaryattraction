require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

require 'binaryattraction_facebooker'
run Sinatra.application

