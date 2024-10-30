template features/neutron/mechanism/linuxbridge;

'/software/packages' = {
    pkg_repl('openstack-neutron-linuxbridge');
    # contrack-tools is an undeclared openstack-neutron-linuxbridge dependency,
    # declared as required by openstack-neutron
    pkg_repl('conntrack-tools');

    SELF;
};

include 'features/neutron/agents/linuxbridge_agent';

include if ( (OS_NODE_TYPE == 'combined') || (OS_NODE_TYPE == 'network') ) 'features/neutron/mechanism/network/linuxbridge';
