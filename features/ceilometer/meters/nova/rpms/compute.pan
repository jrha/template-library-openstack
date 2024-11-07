unique template features/ceilometer/meters/nova/rpms/compute;

'/software/packages' = {
    pkg_repl('openstack-ceilometer-compute');

    SELF;
};
