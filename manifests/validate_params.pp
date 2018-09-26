# Validates input configs from init.pp.
class easy_ipa::validate_params {

  case $easy_ipa::ipa_role {
    'client': {}
    'master': {}
    'replica': {}
    default: {fail('The parameter ipa_role must be set to client, master, or replica.')}
  }

  if $easy_ipa::ip_address != '' {
    validate_legacy(Stdlib::IP::Address, 'validate_ip_address', $easy_ipa::ip_address)
  }

  if $easy_ipa::manage_host_entry {
    if $easy_ipa::ip_address  == '' {
      fail('When using the parameter manage_host_entry, the parameter ip_address is mandatory.')
    }
  }

  if $easy_ipa::idstart < 10000 {
    fail('Parameter "idstart" must be an integer greater than 10000.')
  }

  validate_legacy(Stdlib::Fqdn, 'validate_domain_name', $easy_ipa::domain)
  validate_legacy(Stdlib::Fqdn, 'validate_domain_name', $easy_ipa::final_realm)

  if $easy_ipa::ipa_role == 'master' {
    if length($easy_ipa::admin_password) < 8 {
      fail('When ipa_role is set to master, the parameter admin_password must be populated and at least of length 8.')
    }

    if length($easy_ipa::directory_services_password) < 8 {
      fail("\
When ipa_role is set to master, the parameter directory_services_password \
must be populated and at least of length 8."
      )
    }
  }

  if $easy_ipa::ipa_role != 'master' { # if replica or client

    # TODO: validate_legacy
    if $easy_ipa::ipa_master_fqdn == ''{
      fail("When creating a ${easy_ipa::ipa_role} the parameter named ipa_master_fqdn cannot be empty.")
    }

    validate_legacy(Stdlib::Fqdn, 'validate_domain_name', $easy_ipa::ipa_master_fqdn)

    if $easy_ipa::final_domain_join_password == '' {
      fail("When creating a ${easy_ipa::ipa_role} the parameter named domain_join_password cannot be empty.")
    }
  }
}
