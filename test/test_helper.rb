require 'rubygems'
require 'pry'
require 'minitest/autorun'
require 'shoulda'
require 'mocha/mini_test'
require 'fakeweb'



$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'textmagic'

def random_string(legth = 5 + rand(10))
  Array.new(legth) { rand(36).to_s(36) }.join
end

def random_phone
  rand(10 ** 12).to_s
end

def random_hash
  hash = {}
  3.times { hash[random_string] = random_string }
  hash
end
