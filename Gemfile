source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development do
  gem 'guard-rake',                   :require => false
  gem 'puppet-blacksmith',            :require => false
end

group :unit_tests do
  gem 'metadata-json-lint',           :require => false
  gem 'puppetlabs_spec_helper',       :require => false
  gem 'rspec-core', '3.1.7',          :require => false
  gem 'rspec-puppet-facts',           :require => false
  gem 'simplecov',                    :require => false
  gem 'versionomy',                   :require => false
end

group :system_tests do
  gem 'beaker-rspec',                 :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'serverspec',                   :require => false
  gem 'vagrant-wrapper',              :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
