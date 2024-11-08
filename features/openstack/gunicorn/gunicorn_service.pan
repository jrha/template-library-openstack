# Add gunicorn service template to systemd configuration

unique template features/openstack/gunicorn/gunicorn_service;

variable GUNICORN_BIN ?= '/usr/bin/gunicorn';
variable GUNICORN_PID_FILE = '/var/run/gunicorn.%i.pid';

include 'components/systemd/config';

'/software/components/systemd/skip/service' = false;

# This is a template unit file
'/software/components/systemd/unit/{gunicorn@}/file/only' = true;
'/software/components/systemd/unit/{gunicorn@}/file/replace' = true;
'/software/components/systemd/unit/{gunicorn@}/startstop' = false;

prefix '/software/components/systemd/unit/{gunicorn@}/file/config/unit';
'Description' = 'gunicorn service %I';

prefix '/software/components/systemd/unit/{gunicorn@}/file/config/install';
'WantedBy' = list('multi-user.target');

prefix '/software/components/systemd/unit/{gunicorn@}/file/config/service';
'EnvironmentFile' = list('/etc/sysconfig/gunicorn.%i');
# Use sh to run the command to avoid problems with quoting and allow correct parsing of GUNICORN_OPTIONS
'ExecStart' = format(
    "/bin/sh -cv '%s --chdir ${GUNICORN_APP_DIR} --pid %s " +
    "--config ${GUNICORN_APP_CONFIG} ${GUNICORN_OPTIONS} ${GUNICORN_APP}'",
    GUNICORN_BIN,
    GUNICORN_PID_FILE
);
'PIDFile' = GUNICORN_PID_FILE;
'Restart' = 'always';
'SyslogIdentifier' = 'gunicorn';
