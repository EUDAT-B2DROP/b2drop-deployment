require 'spec_helper'

describe 'b2drop' do
  context 'with defaults for all parameters' do
    it 'installs owncloud package' do
        is_expected.to contain_package('owncloud').with(
          :name   => 'owncloud',
          :ensure => 'present',
        )
    end
  end
end
