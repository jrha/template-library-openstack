unique template features/openstack/gunicorn/sysconfig_schema;

type openstack_gunicorn_sysconfig = {
    'GUNICORN_APP' : string
    'GUNICORN_APP_CONFIG' : absolute_file_path with match(SELF, '.*\.py')
    'GUNICORN_APP_DIR' : absolute_file_path
    'GUNICORN_OPTIONS' ? string
};
