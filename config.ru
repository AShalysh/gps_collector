require 'rack/reloader'
require 'rubygems'

require 'bundler'
Bundler.require

require "./app"

use Rack::Reloader

run App.new