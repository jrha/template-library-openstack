unique template features/ceilometer/rpms;

'/software/packages' = {
    pkg_repl('openstack-ceilometer-notification');
    pkg_repl('openstack-ceilometer-central');
    openstack_add_httpd_packages( OS_CEILOMETER_CONTROLLER_PROTOCOL == 'https' );

    SELF;
};
