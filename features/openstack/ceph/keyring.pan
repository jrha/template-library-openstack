unique template features/openstack/ceph/keyring;

variable OS_CEPH_KEYRING_PARAMS ?= error('OS_CEPH_KEYRING_PARAMS must be defined to build the keyring file');

# Build keyring file
'/software/components/metaconfig/services' = {
    keyring_file = escape(format('/etc/ceph/ceph.client.%s.keyring', OS_CEPH_KEYRING_PARAMS['user']));
    SELF[keyring_file]['module'] = 'openstack/ceph-keyring';
    SELF[keyring_file]['contents'] = dict(
        'key', OS_CEPH_KEYRING_PARAMS['key'],
        'user', OS_CEPH_KEYRING_PARAMS['user'],
    );
    SELF;
};
#bind '/software/components/metaconfig/services/{/etc/ceph/ceph.client.keyring}/contents' = openstack_ceph_keyring_config;


# Load TT file to configure the Ceph client keyring
# Run metaconfig in case the TT file was modified and configuration must be regenerated
include 'components/filecopy/config';
'/software/components/filecopy/dependencies/post' = openstack_add_component_dependency('metaconfig');
prefix '/software/components/filecopy/services/{/usr/share/templates/quattor/metaconfig/openstack/ceph-keyring.tt}';
'config' = file_contents('features/openstack/ceph/keyring.tt');
'perms' = '0644';
