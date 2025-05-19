LDAPGroupsLookup.config = {
  enabled: true,
  config: { host: 'ads.iu.edu',
            port: 636,
            encryption: {
              method: :simple_tls,
              tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS,
            },
            auth: {
              method: :simple,
              username: "#{Rails.application.credentials[:ldap_username]}",
              password: "#{Rails.application.credentials[:ldap_password]}",
            }
  },
  tree: 'dc=ads,dc=iu,dc=edu',
  account_ou: 'ou=Accounts',
  group_ou: 'ou=BL',
  member_allowlist: ['OU=Groups']
}