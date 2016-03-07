source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development do
  gem 'puppet-lint-param-docs',               :require => false
  gem 'puppet-lint-absolute_classname-check', :require => false
  gem 'puppet-lint-absolute_template_path',   :require => false
  gem 'puppet-lint-trailing_newline-check',   :require => false
  gem 'puppet-lint-unquoted_string-check',    :require => false
  gem 'puppet-lint-leading_zero-check',       :require => false
  gem 'puppet-lint-variable_contains_upcase', :require => false
  gem 'puppet-lint-numericvariable',          :require => false
end

group :unit_tests do
  gem 'metadata-json-lint',           :require => false
  gem 'puppetlabs_spec_helper',       :require => false
  gem 'rspec-puppet',                 :require => false
  gem 'rspec-puppet-facts',           :require => false
  gem 'simplecov',                    :require => false
  gem 'versionomy',                   :require => false
end

group :system_tests do
  gem 'beaker-rspec',                 :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'serverspec',                   :require => false
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
