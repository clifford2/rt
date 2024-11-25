docker-rt
=========

This is a [Docker image](https://hub.docker.com/repository/docker/cliffordw/rt)
for running Best Practical's
[Request Tracker](https://bestpractical.com/request-tracker),
a ticket tracking system.

Adapted from <https://github.com/okfn/docker-rt>, with the following changes:

- Switch from PostgreSQL to MariaDB
- Upgrade to RT 5.0.7
- Expand on configurability

It's currently a work in progress, but it includes:

- RT 5
- nginx
- postfix + spamassassin

And exposes the RT web interface on container port 8080
and an RT-connected MTA on container port 2525.

From scratch
------------

Start a MySQL/MariaDB container:

    docker-compose up -d db

Run a one-off container to configure the database:

    docker-compose run rt /usr/local/bin/rtinit

Now the database is initialised and you can run RT proper:

    docker-compose up -d rt

Configuration
-------------

This image provides some limited support for customising the deployment using
environment variables, namely:

- Database:
	- `DATABASE_HOST` (default: `localhost`)
	- `DATABASE_PORT` (default: `3306`)
	- `DATABASE_NAME` (default: `rtdb`)
	- `DATABASE_USER` (default: `rtuser`)
	- `DATABASE_PASSWORD` (default: `rtpass`)
	- `DATABASE_PASSWORD_FILE` as alternate to `$DATABASE_PASSWORD`
- Web interface:
	- `WEB_DOMAIN` (default: `example.com`)
	- `WEB_PROTO` (default: `http`)
	- `WEB_PORT` (default: 80 / 443 depending on `$WEB_PROTO`)
	- `WEB_BASEURL` (default: `${WEB_PROTO}://${WEB_DOMAIN}[:${WEB_PORT}]`)
- RT:
	- `RT_NAME` (default: `${RT_NAME:-${WEB_DOMAIN}`)
	- `RT_ORG` (default: `${ORG:-${WEB_DOMAIN}`)
	- `LOG_LEVEL` (default: `info`)
	- `TIMEZONE` (default: `UTC`)
- Postfix:
	- postfix `$mydomain`: `EMAIL_DOMAIN` (default: `$WEB_DOMAIN`)
	- postfix `$myhostname`: `EMAIL_HOSTNAME` (default: `$EMAIL_DOMAIN`)
	- postfix root alias: `EMAIL_ADDRESS` (default: `rt@$EMAIL_DOMAIN`)
	- RT default queue for new messages: `RT_DEFAULT_QUEUE` (default: `general`)

Additional configuration can be done by mounting custom configuration
files into `/opt/rt5/etc/RT_SiteConfig.d/`.

Alternatives
------------

For an alternate approach, using `registry.access.redhat.com/ubi8/ubi-init`
as base image, see
[How to move Request Tracker into a Linux container](https://www.redhat.com/sysadmin/request-tracker-container).
