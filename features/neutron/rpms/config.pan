unique template features/neutron/rpms/config;

'/software/packages' = {
    pkg_repl('openstack-neutron');
    pkg_repl('python3-neutronclient');

    SELF;
};
