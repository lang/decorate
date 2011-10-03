begin
  require "hoe"

  $LOAD_PATH.unshift("lib")
  require "decorate"

  Hoe.new "decorate", Decorate::VERSION do |p|
    p.author = "Stefan Lang"
    p.email = "langstefan@gmx.at"
    p.url = "http://github.com/lang/decorate"
    p.remote_rdoc_dir = ""
    p.need_tar = true
    p.need_zip = true
  end
rescue LoadError
  puts "Hoe not installed"
end

begin
  require 'rspec/core/rake_task'

  desc  "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts = %w{--exclude gems\/,spec\/}
  end
rescue LoadError
  puts "Rspec not installed"
end
