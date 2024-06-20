unique template features/glance/store/ceph;

# Base Ceph configuration
include 'features/openstack/ceph/config';

# Build keyring file
variable OS_CEPH_KEYRING_PARAMS = dict(
    'key', OS_GLANCE_BACKEND_PARAMS[OS_GLANCE_BACKEND_DEFAULT]['rbd_key'],
    'user', OS_GLANCE_BACKEND_PARAMS[OS_GLANCE_BACKEND_DEFAULT]['rbd_user'],
);
include 'features/openstack/ceph/keyring';

# If one RBD store specifed a data pool, add a section for the Ceph Glance user id
# to support splitting metadata and data in 2 different pools
prefix '/software/components/metaconfig/services/{/etc/ceph/ceph.conf}';
'contents' = {
    rbd_data_pool_found = false;
    foreach (name; params; OS_GLANCE_BACKEND_PARAMS) {
        if ( (params['type'] == 'rbd') && is_defined(params['rbd_data_pool']) ) {
            if ( rbd_data_pool_found ) {
                error('Multiple RBD backends specifying a data pool');
            } else {
                rbd_data_pool_found = true;
                SELF[format("client.%s", params['rbd_user'])]["rbd_default_data_pool"] = params['rbd_data_pool'];
            };
        };
    };

    SELF;
};
