module Decorate
  VERSION = "0.3.0"
end
%w[base create_alias around_decorator examples/memoize].each do |f|
  require File.expand_path("../decorate/#{f}", __FILE__)
end
