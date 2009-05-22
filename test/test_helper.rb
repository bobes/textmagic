require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'matchy'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'textmagic'

class Test::Unit::TestCase
end

def random_string(legth = 5)
  rand(36 ** legth).to_s(36)
end

def random_phone
  rand(10 ** 12).to_s
end

def random_hash
  hash = {}
  3.times { hash[random_string] = random_string }
  hash
end

def build_uri(command, username, password, options = {})
  options.merge!(:cmd => command, :username => username, :password => password)
  uri = "https://www.textmagic.com:443/app/api?"
  uri << options.collect { |key, value| "#{key}=#{value}"}.join('&')
end

def load_response(filename)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', filename) + '.json')
end