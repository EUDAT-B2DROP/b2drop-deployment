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
          datadirectory = '/var/www/nextcloud/data'
          documentroot = '/var/www/nextcloud'
        end

        context 'b2drop class without any parameters' do

          it 'should compile with all deps and cover all sub classes' do
            is_expected.to compile.with_all_deps

            is_expected.to contain_class('b2drop::apache')
            is_expected.to contain_class('b2drop::misc')
            is_expected.to contain_class('b2drop::mysql')
            is_expected.to contain_class('b2drop::nextcloud')
            is_expected.to contain_class('b2drop::php')
            is_expected.to contain_class('b2drop::b2drop')
            is_expected.to contain_class('b2drop::selinux')

          end

          # b2drop::repos

          it 'should create theme and plugin directory' do
            is_expected.to contain_vcsrepo("#{documentroot}/themes/b2drop").with(
              ensure: 'present',
              user: apache_user,
              group: apache_group
            )

            is_expected.to contain_vcsrepo("#{documentroot}/apps/b2sharebridge").with(
              ensure: 'present',
              user: apache_user,
              group: apache_group
            )
          end
        end
      end
    end
  end
end
