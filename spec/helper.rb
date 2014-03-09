require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec'
require 'pry'

RSpec.configure do |config|
   config.color_enabled = true
   config.tty = true
   config.formatter = :documentation # :documentation, :progress, :html, :textmate
end

$LOAD_PATH.unshift File.expand_path('lib')
require 'mini_check'

$LOAD_PATH.unshift File.expand_path('spec/support')
