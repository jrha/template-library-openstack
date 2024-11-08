unique template features/openstack/gunicorn/config;

# Add gunicorn RPM
'/software/packages' = pkg_repl('python3-gunicorn');

# Load gunicorn sysconfig file schema
include 'features/openstack/gunicorn/sysconfig_schema';

# Define gunicorn template service
include 'features/openstack/gunicorn/gunicorn_service';
