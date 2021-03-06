require 'spec_helper'

describe 'apache_c2c::vhost' do
  vhost = 'www.example.com'
  let(:title) { vhost }
  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_class('apache_c2c::params') }

      describe 'ensuring present with defaults' do
        it { should contain_file("#{VARS[os]['conf']}/sites-available/25-#{vhost}.conf").with(
          :ensure  => 'present',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :seltype => VARS[os]['conf_seltype']
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}").with(
          :ensure  => 'directory',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :seltype => VARS[os]['cont_seltype']
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/conf").with(
          :ensure  => 'directory',
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['conf_seltype'],
          :source  => nil
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/htdocs").with(
          :ensure  => 'directory',
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['cont_seltype'],
          :source  => nil
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost} cgi-bin directory").with(
          :ensure  => 'directory',
          :path    => "#{VARS[os]['root']}/#{vhost}/cgi-bin/",
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['script_seltype']
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/logs").with(
          :ensure  => 'directory',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :seltype => VARS[os]['log_seltype']
        ) }

        ['access', 'error'].each do |f|
          it { should contain_file("#{VARS[os]['root']}/#{vhost}/logs/#{f}.log").with(
            :ensure  => 'present',
            :owner   => 'root',
            :group   => 'adm',
            :mode    => '0644',
            :seltype => VARS[os]['log_seltype']
          ) }
        end

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/private").with(
          :ensure  => 'directory',
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['cont_seltype']
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/README").with(
          :ensure  => 'present',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :content => /^Your website is hosted in #{VARS[os]['root']}\/#{vhost}\/$/
        ) }

        it { should contain_exec("enable vhost #{vhost}").with(
          :command => "#{VARS[os]['a2ensite']} 25-#{vhost}.conf"
        ) }
      end

      describe 'ensuring absent' do
        let(:params) { {
          :ensure => 'absent',
        } }

        it { should contain_file("#{VARS[os]['conf']}/sites-enabled/25-#{vhost}.conf").with_ensure('absent') }
        it { should contain_file("#{VARS[os]['conf']}/sites-available/25-#{vhost}.conf").with_ensure('absent') }

        it { should contain_exec("remove #{VARS[os]['root']}/#{vhost}").with(
          :command => "rm -rf #{VARS[os]['root']}/#{vhost}",
          :onlyif  => "test -d #{VARS[os]['root']}/#{vhost}"
        ) }

        it { should contain_exec("disable vhost #{vhost}").with(
          :command => "#{VARS[os]['a2dissite']} 25-#{vhost}.conf"
        ) }
      end

      describe 'ensuring disabled' do
        let(:params) { {
          :ensure => 'disabled',
        } }

        it { should contain_exec("disable vhost #{vhost}").with(
          :command => "#{VARS[os]['a2dissite']} 25-#{vhost}.conf"
        ) }

        it { should contain_file("#{VARS[os]['conf']}/sites-enabled/25-#{vhost}.conf").with(
          :ensure => 'absent'
        ) }
      end

      describe 'using wrong ensure value' do
        let(:params) { {
          :ensure => 'running',
        } }

        it do
          expect {
            should contain_file("#{VARS[os]['conf']}/sites-enabled/#{vhost}")
          }.to raise_error(Puppet::Error, /Unknown ensure value: 'running'/)
        end
      end
    end
  end
end
