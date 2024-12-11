class aide (
  Enum["present", "absent"] $cron_ensure,
  Optional[String] $cron_minute,
  Optional[String] $cron_hour,
  String[1] $path,
) {
  contain 'aide::package'
  contain 'aide::config'

  Class['aide::package']
  ->Class['aide::config']
}
