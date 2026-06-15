# puppet-aide

Puppet module for installing and managing [AIDE](https://aide.github.io/) (Advanced Intrusion Detection Environment).

> **Breaking change:** This module uses AIDE 0.17+ configuration syntax (space-separated directives, `database_in` instead of `database`). It is not compatible with AIDE <= 0.16.

## Usage

### Basic

```puppet
include aide
```

### With custom cron schedule

```puppet
class { 'aide':
  cron_ensure => 'present',
  cron_hour   => '3',
  cron_minute => '30',
}
```

### Disable cron job

```puppet
class { 'aide':
  cron_ensure => 'absent',
}
```

### Additional configuration files

Use the `configs` parameter together with `aide::conf` to drop additional rule files into `/etc/aide.conf.d/`:

```puppet
class { 'aide':
  configs => ['myapp'],
}

aide::conf { 'myapp':
  content => "/opt/myapp CONTENTEX\n/var/lib/myapp DATAONLY\n",
}
```

Or with a Puppet file source:

```puppet
aide::conf { 'myapp':
  source => 'puppet:///modules/profile/aide/myapp.conf',
}
```

The `configs` parameter controls which `@@include` directives are added to `/etc/aide.conf`. Each entry generates an `@@include /etc/aide.conf.d/<name>.conf` line. The `/etc/aide.conf.d/` directory is purged, so unmanaged files will be removed.

## Parameters

### Class `aide`

| Parameter     | Type                         | Default      | Description                                                  |
|---------------|------------------------------|--------------|--------------------------------------------------------------|
| `cron_ensure` | `Enum["present", "absent"]`  | `present`    | Whether the daily AIDE check cron job should exist.          |
| `cron_hour`   | `Optional[String]`           | `undef`      | Hour for the cron job. If unset, uses `fqdn_rand` (0-5).    |
| `cron_minute` | `Optional[String]`           | `undef`      | Minute for the cron job. If unset, uses `fqdn_rand` (0-58). |
| `path`        | `String[1]`                  | `/usr/sbin`  | Path to the AIDE binary directory.                           |
| `configs`     | `Array[String[1]]`           | `[]`         | List of additional config names to include from `aide.conf.d`. |

### Define `aide::conf`

| Parameter | Type               | Default | Description                              |
|-----------|--------------------|---------|------------------------------------------|
| `content` | `Optional[String]` | `undef` | Content of the configuration file.       |
| `source`  | `Optional[String]` | `undef` | Puppet file source for the config file.  |

## What it does

1. Installs the `aide` package.
2. Deploys `/etc/aide.conf` with a comprehensive set of monitored paths for CIS/STIG compliance.
3. Creates `/etc/aide.conf.d/` for additional configuration files.
4. Runs `aide --init` on the first Puppet run to create the initial database.
5. Copies the new database to the active database location.
6. Sets up a cron job for periodic `aide --check` runs.

## Re-initializing the database

The `aide --init` exec uses `creates => '/var/lib/aide/aide.db.new.gz'` for idempotency. To force a re-initialization, remove the database file on the target node:

```bash
rm -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
```

Then run Puppet again.

## License

MIT
