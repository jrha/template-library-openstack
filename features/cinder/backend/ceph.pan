unique template features/cinder/backend/ceph;

# Base Ceph configuration
include 'features/openstack/ceph/config';

prefix '/software/components/metaconfig/services/{/etc/ceph/ceph.conf}';
'daemons/openstack-cinder-volume' = 'restart';

# Build keyring file
variable OS_CEPH_KEYRING_PARAMS = {
    foreach (name; params; OS_CINDER_BACKEND_PARAMS) {
        if ( params['type'] == 'rbd' ) {
            if ( !is_defined(SELF['user']) ) {
                SELF['user'] = params['rbd_user'];
            } else if ( SELF['user'] != params['rbd_user'] ) {
                error("All the RBD backends must use the same RBD user");
            };
            if ( !is_defined(SELF['key']) ) {
                SELF['key'] = params['rbd_key'];
            } else if ( SELF['key'] != params['rbd_key'] ) {
                error("All the RBD backends must use the same RBD key");
            };
        };
    };

    SELF;
};
include if ( is_defined(OS_CEPH_KEYRING_PARAMS) ) 'features/openstack/ceph/keyring';

