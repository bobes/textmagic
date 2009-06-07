require 'rubygems'
gem 'httparty'
require 'httparty'
%w[charset validation api response executor error].each do |lib|
  require File.join(File.dirname(__FILE__), lib)
end

module TextMagic #:nodoc:
end
