define aide::conf (
  Optional[String] $content = undef,
  Optional[String] $source = undef,
) {
  file { "/etc/aide.conf.d/${title}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $content,
    source  => $source,
    require => File['/etc/aide.conf.d'],
    before  => Exec['aide-init'],
  }
}
