require "bundler"
Bundler.require

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

class Minitest::Test

  def self.it(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    define_method(test_name, &block)
  end
end
