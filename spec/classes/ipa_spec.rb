require 'spec_helper'

describe 'easy_ipa', type: :class do
  context 'on Windows' do
    let(:facts) do
      { os: { family: 'Windows' } }
    end
    let(:params) do
      {
        ipa_role: 'master',
        domain:   'rspec.example.lan',
      }
    end

    it { is_expected.to raise_error(Puppet::Error, %r{ERROR: unsupported operating system}) }
  end

  context 'on Centos' do
    let(:facts) do
      {
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          release: {
            major: '7',
          },
        },
        fqdn:     'ipa.rpsec.example.lan',
      }
    end

    context 'as bad_val role' do
      let(:params) do
        {
          ipa_role:                    'bad_val',
          domain:                      'rspec.example.lan',
        }
      end

      it { is_expected.to raise_error(Puppet::Error, %r{parameter ipa_role must be}) }
    end

    context 'as master' do
      context 'with defaults' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            admin_password:              'rspecrspec123',
            directory_services_password: 'rspecrspec123',
          }
        end

        it { is_expected.to contain_class('easy_ipa::install') }
        it { is_expected.to contain_class('easy_ipa::install::server') }
        it { is_expected.to contain_class('easy_ipa::install::sssd') }
        it { is_expected.to contain_class('easy_ipa::install::server::master') }
        it { is_expected.to contain_class('easy_ipa::config::webui') }
        it { is_expected.to contain_class('easy_ipa::validate_params') }

        it { is_expected.not_to contain_class('easy_ipa::install::autofs') }
        it { is_expected.not_to contain_class('easy_ipa::install::server::replica') }
        it { is_expected.not_to contain_class('easy_ipa::install::client') }

        it { is_expected.to contain_package('ipa-server-dns') }
        it { is_expected.to contain_package('bind-dyndb-ldap') }
        it { is_expected.to contain_package('kstart') }
        it { is_expected.to contain_package('epel-release') }
        it { is_expected.to contain_package('ipa-server') }
        it { is_expected.to contain_package('openldap-clients') }
        it { is_expected.to contain_package('sssd-common') }

        it { is_expected.not_to contain_package('ipa-client') }
      end

      context 'with idstart out of range' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            admin_password:              'rspecrspec123',
            directory_services_password: 'rspecrspec123',
            idstart:                     100,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{an integer greater than 10000}) }
      end

      context 'with manage_host_entry but not ip_address' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            admin_password:              'rspecrspec123',
            directory_services_password: 'rspecrspec123',
            manage_host_entry:           true,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{parameter ip_address is mandatory}) }
      end

      context 'without admin_password' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            # admin_password:              'rspecrspec123',
            directory_services_password: 'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{populated and at least of length 8}) }
      end

      context 'without directory_services_password' do
        let(:params) do
          {
            ipa_role:                     'master',
            domain:                       'rspec.example.lan',
            admin_password:               'rspecrspec123',
            # directory_services_password: 'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{populated and at least of length 8}) }
      end

      context 'with bad ip_address' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            admin_password:              'rspecrspec123',
            directory_services_password: 'rspecrspec123',
            ip_address:                  'not_an_ip',
          }
        end

	it { is_expected.to raise_error(Puppet::Error, %r{expects a.*Stdlib::IP::Address}) }
      end

      context 'with bad domain' do
        let(:params) do
          {
            ipa_role:                     'master',
            domain:                       'not_a_domain',
            admin_password:               'rspecrspec123',
            directory_services_password: 'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Fqdn}) }
      end

      context 'with bad realm' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            realm:                       'not_a_realm',
            admin_password:              'rspecrspec123',
            directory_services_password: 'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{a match for Stdlib::Fqdn}) }
      end
    end

    context 'as replica' do
      context 'with defaults' do
        let(:params) do
          {
            ipa_role:                    'replica',
            domain:                      'rspec.example.lan',
            ipa_master_fqdn:             'ipa-server-1.rspec.example.lan',
            domain_join_password:        'rspecrspec123',
          }
        end

        it { is_expected.to contain_class('easy_ipa::install') }
        it { is_expected.to contain_class('easy_ipa::install::server') }
        it { is_expected.to contain_class('easy_ipa::install::sssd') }
        it { is_expected.to contain_class('easy_ipa::install::server::replica') }
        it { is_expected.to contain_class('easy_ipa::config::webui') }
        it { is_expected.to contain_class('easy_ipa::validate_params') }

        it { is_expected.not_to contain_class('easy_ipa::install::autofs') }
        it { is_expected.not_to contain_class('easy_ipa::install::server::master') }
        it { is_expected.not_to contain_class('easy_ipa::install::client') }

        it { is_expected.to contain_package('ipa-server-dns') }
        it { is_expected.to contain_package('bind-dyndb-ldap') }
        it { is_expected.to contain_package('kstart') }
        it { is_expected.to contain_package('epel-release') }
        it { is_expected.to contain_package('ipa-server') }
        it { is_expected.to contain_package('openldap-clients') }
        it { is_expected.to contain_package('sssd-common') }

        it { is_expected.not_to contain_package('ipa-client') }
      end

      context 'missing ipa_master_fqdn' do
        let(:params) do
          {
            ipa_role:                    'replica',
            domain:                      'rspec.example.lan',
            # ipa_master_fqdn:             'ipa-server-1.rspec.example.lan',
            domain_join_password:        'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn cannot be empty}) }
      end

      context 'with bad ipa_master_fqdn' do
        let(:params) do
          {
            ipa_role:                    'replica',
            domain:                      'rspec.example.lan',
            ipa_master_fqdn:             'not_an_fqdn',
            domain_join_password:        'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Fqdn}) }
      end

      context 'missing domain_join_password' do
        let(:params) do
          {
            ipa_role:                    'replica',
            domain:                      'rspec.example.lan',
            ipa_master_fqdn:             'ipa-server-1.rspec.example.lan',
            # domain_join_password        'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{domain_join_password cannot be empty}) }
      end
    end

    context 'as client' do
      context 'with defaults' do
        let(:params) do
          {
            ipa_role:                    'client',
            domain:                      'rspec.example.lan',
            ipa_master_fqdn:             'ipa-server-1.rspec.example.lan',
            domain_join_password:        'rspecrspec123',
          }
        end

        it { is_expected.to contain_class('easy_ipa::install') }
        it { is_expected.to contain_class('easy_ipa::install::sssd') }
        it { is_expected.to contain_class('easy_ipa::install::client') }
        it { is_expected.to contain_class('easy_ipa::validate_params') }

        it { is_expected.not_to contain_class('easy_ipa::install::autofs') }
        it { is_expected.not_to contain_class('easy_ipa::install::server') }
        it { is_expected.not_to contain_class('easy_ipa::install::server::master') }
        it { is_expected.not_to contain_class('easy_ipa::install::server::replica') }
        it { is_expected.not_to contain_class('easy_ipa::config::webui') }

        it { is_expected.to contain_package('ipa-client') }
        it { is_expected.to contain_package('sssd-common') }
        it { is_expected.to contain_package('kstart') }
        it { is_expected.to contain_package('epel-release') }

        it { is_expected.not_to contain_package('ipa-server-dns') }
        it { is_expected.not_to contain_package('bind-dyndb-ldap') }
        it { is_expected.not_to contain_package('ipa-server') }
        it { is_expected.not_to contain_package('openldap-clients') }
      end

      context 'missing ipa_master_fqdn' do
        let(:params) do
          {
            ipa_role:                    'client',
            domain:                      'rspec.example.lan',
            # ipa_master_fqdn:             'ipa-server-1.rspec.example.lan',
            domain_join_password:        'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn cannot be empty}) }
      end

      context 'missing domain_join_password' do
        let(:params) do
          {
            ipa_role:                    'client',
            domain:                      'rspec.example.lan',
            ipa_master_fqdn:             'ipa-server-1.rspec.example.lan',
            # domain_join_password:        'rspecrspec123',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{parameter named domain_join_password cannot be empty}) }
      end
    end
  end
end
