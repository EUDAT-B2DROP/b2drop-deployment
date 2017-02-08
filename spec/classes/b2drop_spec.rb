require 'spec_helper'

describe 'b2drop' do

  shared_examples_for 'b2drop with dummy cert path' do

    let :params do
      {
        :apache_ssl_chain => '/etc/httpd/chain',
        :apache_ssl_key   => '/etc/httpd/key',
        :apache_ssl_cert  => '/etc/httpd/cert',
        :mysql_nextcloud_password   => 'passw0rd',
        :mysql_root_password   => 'passw0rd',
        :mysql_monitoring_password   => 'passw0rd',
        :mysql_backup_password   => 'passw0rd',
        :documentroot     => '/var/www/nextcloud'
      }
    end
    it 'should compile with all deps and cover all sub classes' do
      is_expected.to contain_class('b2drop').with(
        'apache_ssl_chain' => params[:apache_ssl_chain],
        'apache_ssl_key'   => params[:apache_ssl_key],
        'apache_ssl_cert'  => params[:apache_ssl_cert],
        'mysql_password'   => params[:mysql_password]
      )

      is_expected.to contain_class('b2drop::apache')
      is_expected.to contain_class('b2drop::misc')
      is_expected.to contain_class('b2drop::mysql')
      is_expected.to contain_class('b2drop::nextcloud')
      is_expected.to contain_class('b2drop::php')
      is_expected.to contain_class('b2drop::b2drop')
      is_expected.to contain_class('b2drop::selinux')

      is_expected.to compile.with_all_deps

    end

    # b2drop::repos

    it 'should create theme and plugin directory' do
      is_expected.to contain_vcsrepo("#{params[:documentroot]}/themes/b2drop").with(
        'ensure' => 'present',
        'user'   => platform_params[:httpd_user],
        'group'  => platform_params[:httpd_group]
      )

      is_expected.to contain_vcsrepo("#{params[:documentroot]}/apps/b2sharebridge").with(
        'ensure' => 'present',
        'user'   => platform_params[:httpd_user],
        'group'  => platform_params[:httpd_group]
      )
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          concat_basedir: '/var/lib/puppet/concat',
          root_home: '/root',
          ipaddress_em1: '127.0.0.1',
          interfaces: 'lo,eth0,em1'
        )
      end
      let (:platform_params) do
        case facts[:osfamily]
        when 'RedHat'
          {
            :httpd_service_name     => 'httpd',
            :httpd_user             => 'apache',
            :httpd_group            => 'apache',
          }
        when 'Debian'
          {
            :httpd_service_name     => 'apache2',
            :httpd_user             => 'www-data',
            :httpd_group            => 'www-data',
          }
        end
      end
      it_behaves_like 'b2drop with dummy cert path'
    end
  end
end
