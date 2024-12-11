class aide::config {
  if ($aide::cron_hour == undef) {
    $cron_hour = fqdn_rand(6, "${module_name}::cron_hour")
  } else {
    $cron_hour = $aide::cron_hour
  }

  if ($aide::cron_minute == undef) {
    $cron_minute = fqdn_rand(59, "${module_name}::cron_minute")
  } else {
    $cron_minute = $aide::cron_minute
  }

  file { '/etc/aide.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/etc/aide.conf.epp"),
  }

  file { '/etc/aide.conf.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  }

  file { '/etc/aide.conf.d/common.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/etc/aide.conf.d/common.conf.epp"),
  }

  cron { 'aide-check':
    ensure      => $aide::cron_ensure,
    command     => "${aide::path}/aide --check",
    hour        => $cron_hour,
    minute      => $cron_minute,
    month       => '*',
    monthday    => '*',
    weekday     => '*',
    environment => ['PATH=/bin:/sbin:/usr/sbin:/usr/bin'],
    require     => File['/etc/aide.conf'],
  }

  exec { 'aide-init':
    command => "${aide::path}/aide --init",
    path    => '/bin:/sbin:/usr/sbin:/usr/bin',
    creates => '/var/lib/aide/aide.db.new.gz',
    require => File['/etc/aide.conf'],
  }
  ~>exec { 'aide-copy-database':
    command     => 'cp -p /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz',
    path        => '/bin:/sbin:/usr/sbin:/usr/bin',
    refreshonly => true,
    require     => File['/etc/aide.conf'],
  }
}
