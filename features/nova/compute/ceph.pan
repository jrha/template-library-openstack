unique template features/nova/compute/ceph;

@{
desc = if true, enable direct image download from Ceph (instead of Glance)
values = boolean
default = true if the required Glance configuration is present, false otherwise
required = no
}
variable OS_NOVA_ENABLE_RBD_DOWNLOAD ?= (
    is_defined(OS_GLANCE_BACKEND_PARAMS) && 
    is_defined(OS_GLANCE_BACKEND_DEFAULT) &&
    (OS_GLANCE_BACKEND_PARAMS[OS_GLANCE_BACKEND_DEFAULT]['type'] == 'rbd') 
);


# Base Ceph configuration
include 'features/openstack/ceph/config';


#############################################################
# Libvirt secret for attaching Ceph block devices to the VM #
#############################################################

variable OS_LIBVIRT_CEPH_SECRET ?= error("OS_LIBVIRT_CEPH_SECRET must be defined with the Ceph key for client.cinder Ceph user");
# Note : OS_LIBVIRT_CEPH_SECRET_UUID must match what is defined in the RBD backend of the Cinder configuration
# as Cinder passes the UUID to use to Nova compute service. Currently, there is no support in the templates
# for configuring multiple secrets corresponding to different Cinder backends.
variable OS_LIBVIRT_CEPH_SECRET_UUID ?= error("OS_LIBVIRT_CEPH_SECRET_UUID must be defined with the libvirt UUID for the client.cinder key");

final variable OS_LIBVIRT_SECRET_XML_FMT = <<EOF;
<secret ephemeral='no' private='no'>
<uuid>%s</uuid>
<usage type='ceph'>
<name>client.cinder secret</name>
</usage>
</secret>
EOF

final variable OS_LIBVIRT_ADD_SECRET_FMT  = <<EOF;
#!/bin/sh
virsh secret-define --file %s
virsh secret-set-value --secret %s --base64 %s
EOF

final variable OS_LIBVIRT_ADD_SECRET_BIN = '/var/run/quattor/add_secret';
final variable OS_LIBVIRT_SECRET_XML_FILE = '/var/run/quattor/secret.xml';


include 'components/filecopy/config';
'/software/components/filecopy/services' ={
    SELF[escape(OS_LIBVIRT_SECRET_XML_FILE)] = dict(
        'config', format(OS_LIBVIRT_SECRET_XML_FMT, OS_LIBVIRT_CEPH_SECRET_UUID),
        'owner', 'root:root',
        'perms', '0600',
        'restart', OS_LIBVIRT_ADD_SECRET_BIN,
    );

    SELF[escape(OS_LIBVIRT_ADD_SECRET_BIN)] = dict(
        'config', format(OS_LIBVIRT_ADD_SECRET_FMT, OS_LIBVIRT_SECRET_XML_FILE, OS_LIBVIRT_CEPH_SECRET_UUID, OS_LIBVIRT_CEPH_SECRET),
        'owner', 'root:root',
        'perms', '0700',
        'restart', OS_LIBVIRT_ADD_SECRET_BIN,
    );

    SELF;
};

##############################################################
# Configuration for direct access from Ceph of Glance images #
##############################################################

prefix '/software/components/metaconfig/services/{/etc/nova/nova.conf}';
'contents/glance/enable_rbd_download' = OS_NOVA_ENABLE_RBD_DOWNLOAD; 
'contents/glance/rbd_ceph_conf' = OS_NOVA_CEPH_IMAGES_CEPH_CONF;
'contents/glance/rbd_pool' = OS_GLANCE_BACKEND_PARAMS[OS_GLANCE_BACKEND_DEFAULT]['rbd_pool'];
'contents/glance/rbd_user' = OS_GLANCE_BACKEND_PARAMS[OS_GLANCE_BACKEND_DEFAULT]['rbd_user'];
# Define images_rbd_glance_store_name only if the default backend if a RBD one
'contents/libvirt/images_rbd_glance_store_name' = if ( OS_NOVA_ENABLE_RBD_DOWNLOAD ) {
    OS_GLANCE_BACKEND_DEFAULT;
} else {
    null;
};

# Build keyring file
variable OS_CEPH_KEYRING_PARAMS = dict(
    'key', OS_GLANCE_BACKEND_PARAMS[OS_GLANCE_BACKEND_DEFAULT]['rbd_key'],
    'user', OS_GLANCE_BACKEND_PARAMS[OS_GLANCE_BACKEND_DEFAULT]['rbd_user'],
);
include 'features/openstack/ceph/keyring';
