unique template features/octavia/gunicorn/config;


# Include gunicorn base configuration
include 'features/openstack/gunicorn/config';


# Define gunicorn configuration for Octavia
include 'components/metaconfig/config';
prefix '/software/components/metaconfig/services/{/etc/sysconfig/gunicorn.octavia}';
'module' = 'tiny';
# panlint disable=LP006
bind '/software/components/metaconfig/services/{/etc/sysconfig/gunicorn.octavia}/contents' = openstack_gunicorn_sysconfig;

'contents/GUNICORN_APP' = "\"'octavia.api.app:setup_app()'\"";
'contents/GUNICORN_APP_CONFIG' = '/var/lib/octavia/gunicorn_app.py';
'contents/GUNICORN_APP_DIR' = '/etc/octavia';
