require 'spec_helper'
require 'versionomy'

describe 'b2drop' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(
            concat_basedir: '/var/lib/puppet/concat',
            root_home: '/root'
          )
        end

        case facts[:osfamily]
        when 'RedHat'
          apache_user = 'apache'
          apache_group = 'apache'
          datadirectory = '/var/www/html/owncloud/data'
          documentroot = '/var/www/html/owncloud'
        end

        context 'b2drop class without any parameters' do

          it 'should compile with all deps and cover all sub classes' do
            is_expected.to compile.with_all_deps

            is_expected.to contain_class('b2drop::misc')
            is_expected.to contain_class('b2drop::repos')
            is_expected.to contain_class('b2drop::php')
            is_expected.to contain_class('b2drop')

            is_expected.to contain_package('owncloud-server').with_ensure('present')
          end

          # owncloud::config

          it 'should create theme and plugin directory' do
            is_expected.to contain_file("#{documentroot}/themes/b2drop").with(
              ensure: 'directory',
              owner: apache_user,
              group: apache_group
            )

            is_expected.to contain_file("#{documentroot}/apps/b2sharebridge").with(
              ensure: 'directory',
              owner: apache_user,
              group: apache_group
            )
          end
        end
      end
    end
  end
end
