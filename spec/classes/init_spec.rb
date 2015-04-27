require 'spec_helper'
describe 'b2drop' do

  context 'with defaults for all parameters' do
    it { should contain_class('b2drop') }
  end
end
