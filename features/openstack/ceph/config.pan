# Template for doing the base Ceph client configuration for OpenStack
unique template features/openstack/ceph/config;

variable CEPH_CLUSTER_CONFIG ?= error('CEPH_CLUSTER_CONFIG required but undefined');
variable CEPH_NODE_VERSIONS ?= 'site/ceph/version';
variable CEPH_CONFIG_FILE ?= 'features/ceph/ceph_conf/config';

include CEPH_NODE_VERSIONS;

include CEPH_CLUSTER_CONFIG;

include CEPH_CONFIG_FILE;

# Add ceph package
'/software/packages' = {
    pkg_repl('ceph');

    SELF;
};
