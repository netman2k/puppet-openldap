# See README.md for details.
define openldap::server::database(
  $ensure           = present,
  $directory        = undef,
  $suffix           = $title,
  $relay            = undef,
  $backend          = undef,
  $rootdn           = undef,
  $rootpw           = undef,
  $initdb           = undef,
  $initacl          = true,
  $readonly         = false,
  $sizelimit        = undef,
  $dbmaxsize        = undef,
  $timelimit        = undef,
  $updateref        = undef,
  $limits           = undef,
  # BDB/HDB options
  $dboptions        = undef,
  $synctype         = undef,
  # Synchronization options
  $mirrormode       = undef,
  $syncusesubentry  = undef,
  $syncrepl         = undef,
  $security         = undef,
  $perl_module      = undef,
  $perl_module_path = undef,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  $manage_directory = $backend ? {
    'monitor' => undef,
    'config'  => undef,
    'relay'   => undef,
    'perl'    => undef,
    default   => $directory ? {
      undef   => '/var/lib/ldap',
      default => $directory,
    },
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install'] ->
    Openldap::Server::Database[$title] ~>
    Class['openldap::server::service']
  } else {
    Class['openldap::server::service'] ->
    Openldap::Server::Database[$title] ->
    Class['openldap::server']
  }
  if $title != 'dc=my-domain,dc=com' {
    Openldap::Server::Database['dc=my-domain,dc=com'] -> Openldap::Server::Database[$title]
  }

  if $ensure == present and !empty($manage_directory) {
    validate_absolute_path($manage_directory)
    file { $manage_directory:
      ensure => directory,
      owner  => $::openldap::server::owner,
      group  => $::openldap::server::group,
      before => Openldap_database[$title],
    }
  }

  openldap_database { $title:
    ensure           => $ensure,
    suffix           => $suffix,
    relay            => $relay,
    provider         => $::openldap::server::provider,
    target           => $::openldap::server::conffile,
    backend          => $backend,
    directory        => $manage_directory,
    rootdn           => $rootdn,
    rootpw           => $rootpw,
    initdb           => $initdb,
    initacl          => $initacl,
    readonly         => $readonly,
    sizelimit        => $sizelimit,
    timelimit        => $timelimit,
    dbmaxsize        => $dbmaxsize,
    updateref        => $updateref,
    dboptions        => $dboptions,
    synctype         => $synctype,
    mirrormode       => $mirrormode,
    syncusesubentry  => $syncusesubentry,
    syncrepl         => $syncrepl,
    limits           => $limits,
    security         => $security,
    perl_module      => $perl_module,
    perl_module_path => $perl_module_path,
  }

}
