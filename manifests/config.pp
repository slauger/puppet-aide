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
}
