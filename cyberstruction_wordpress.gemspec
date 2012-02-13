Gem::Specification.new do |s|
  s.name = %q{cyberstruction_wordpress}
  s.version = "0.0.5"
  s.date = %q{2012-01-19}
  s.authors = ["James Whinfrey"]
  s.email = %q{james@conceptric.co.uk}
  s.summary = %q{cyberstruction_wordpress is a set of capistrano tasks for wordpress deployment to a cyberstruction server}  
  s.description = %q{The Capistrano tasks in this gem provide the deployment and management support I commonly require for my own server. You are welcome to fork this Gem and use it for your own purposes.}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.add_dependency "capistrano"
  s.add_dependency "capistrano-ext"
  s.add_dependency "cyberstruction_deploy"
end
