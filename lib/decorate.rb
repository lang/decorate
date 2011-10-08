module Decorate
  VERSION = "0.4.0"
end
%w[base create_alias around_decorator].each do |f|
  require File.expand_path("../decorate/#{f}", __FILE__)
end
