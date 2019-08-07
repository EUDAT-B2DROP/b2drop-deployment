source ENV["GEM_SOURCE"] || "https://rubygems.org"

group :test do
  if puppet_gem_version = ENV["PUPPET_GEM_VERSION"]
    gem "puppet", ENV["PUPPET_GEM_VERSION"]
  else
    gem "puppet"
  end
  gem 'puppetlabs_spec_helper',               :require => 'false'
  gem 'rspec-puppet',                         :require => 'false'
  gem 'rspec-puppet-facts',                   :require => 'false'
  gem 'metadata-json-lint',                   :require => 'false'
  gem 'yaml-lint',                            :require => 'false'
  gem 'puppet-syntax',                        '~> 2.3.0'
  gem 'puppet-lint',                          '~> 2.3.3'
  gem 'puppet-lint-param-docs',               :require => 'false'
  gem 'puppet-lint-absolute_classname-check', :require => 'false'
  gem 'puppet-lint-unquoted_string-check',    :require => 'false'
  gem 'puppet-lint-leading_zero-check',       :require => 'false'
  gem 'json',                                 :require => 'false'
  gem 'webmock',                              :require => 'false'
  gem 'facter',                               :require => 'false'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker", "~> 2.0"
  gem "beaker-puppet_install_helper", :require => false
  gem "beaker-rspec"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "pry"
  gem "yard"
  gem "parallel_tests" # requires at least Ruby 1.9.3
  gem "rubocop", :require => false # requires at least Ruby 1.9.2
end
