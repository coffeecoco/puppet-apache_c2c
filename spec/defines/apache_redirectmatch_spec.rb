require 'spec_helper'

describe 'apache_c2c::redirectmatch' do
  let(:title) { 'example' }
  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'using example usage' do
        let(:params) { {
          :ensure => 'present',
          :regex  => '^/(foo|bar)/',
          :url    => 'http://foobar.example.com/',
          :vhost  => 'www.example.com',
        } }
        it { should contain_class('apache_c2c::params') }

        it { should contain_file('example redirect on www.example.com').with(
          :ensure  => 'present',
          :content => "# file managed by puppet\nRedirectMatch ^/(foo|bar)/ http://foobar.example.com/\n",
          :seltype => VARS[os]['conf_seltype'],
          :path    => "#{VARS[os]['root']}/www.example.com/conf/redirect-example.conf"
        ) }
      end

      describe 'ensuring example usage is absent' do
        let(:params) { {
          :ensure => 'absent',
          :regex  => '^/(foo|bar)/',
          :url    => 'http://foobar.example.com/',
          :vhost  => 'www.example.com',
        } }

        it { should contain_class('apache_c2c::params') }

        it { should contain_file('example redirect on www.example.com').with_ensure('absent') }
      end

      describe 'missing regex parameter' do
        let(:params) { {
          :ensure => 'absent',
          :url    => 'http://foobar.example.com/',
          :vhost  => 'www.example.com',
        } }

        it do
          expect {
            should contain_class('apache_c2c::params')
          }.to raise_error(Puppet::Error, /Must pass regex to Apache_c2c::Redirectmatch\[example\]/)
        end
      end
    end
  end
end
