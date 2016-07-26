RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

def restore_default_config
  Logplex.configuration = nil
  Logplex.configure {}
end
