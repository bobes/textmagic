%w[charset validation api response executor error version].each do |lib|
  require File.join(File.dirname(__FILE__), "textmagic", lib)
end

module Textmagic
end
