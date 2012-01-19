# Check whether the variable has been set
def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

Dir[File.join(File.dirname(__FILE__), 'recipes', '*.rb')].each do |recipe| 
  configuration = Capistrano::Configuration.respond_to?(:instance) ?
    Capistrano::Configuration.instance(:must_exist) :
    Capistrano.configuration(:must_exist)
  configuration.load recipe
end      