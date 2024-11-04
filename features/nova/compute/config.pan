unique template features/nova/compute/config;

@{
desc = template with site-specific configuration for live-migration
values = template path (namespece). Set to null to disable it.
default = undef
required = no
}
variable OS_NOVA_LIVE_MIGRATION_SITE_CONFIG ?= undef;


variable OS_NODE_SERVICES = append('nova');

# Load some useful functions
include 'defaults/openstack/functions';

# Load Nova-related type definitions
include 'types/openstack/nova';

# Include general openstack variables
include 'defaults/openstack/config';

# Include RPMS for nova hypervisor configuration
include 'features/nova/compute/rpms';

# Include Placement configuration for compute servers
include 'features/nova/compute/placement';

# Include policy file if OS_NOVA_COMPUTE_POLICY is defined
@{
desc = file to load as the policy file. File extension is used to determine the policy file extension
values = path relative to include paths
default = undef
requied = no
}
variable OS_NOVA_COMPUTE_POLICY ?= undef;
include 'components/filecopy/config';
'/software/components/filecopy/services' = {
    if ( is_defined(OS_NOVA_COMPUTE_POLICY) ) {
        toks = matches(OS_NOVA_COMPUTE_POLICY, '.*\.(json|yaml)$');
        if ( length(toks) < 2 ) {
            error('OS_NOVA_COMPUTE_POLICY must be a file name with the extension .json or .yaml');
        };
        policy_file = format('/etc/nova/policy.%s', toks[1]);
        SELF[escape(policy_file)] = dict(
            'config', file_contents(OS_NOVA_COMPUTE_POLICY),
            'owner', 'root',
            'perms', '0644',
            'backup', true,
        );
    };

    SELF;
};

# Enable nested virtualization if needed
include if ( is_defined(OS_NOVA_COMPUTE_NESTED) && OS_NOVA_COMPUTE_NESTED ) 'features/nova/compute/nested';

# Configure VM magration
include 'features/nova/compute/vm-migration/config';
# Add site-specific configuration for live migration, if any
include OS_NOVA_LIVE_MIGRATION_SITE_CONFIG;

# Restart nova specific daemon
include 'components/systemd/config';
prefix '/software/components/systemd/unit';
'libvirtd/startstop' = true;
'openstack-nova-compute/startstop' = true;


# Configuration file for nova
include 'components/metaconfig/config';
prefix '/software/components/metaconfig/services/{/etc/nova/nova.conf}';
'module' = 'tiny';
'convert/joincomma' = true;
'convert/truefalse' = true;
'daemons/libvirtd' = 'restart';
'daemons/openstack-nova-compute' = 'restart';
# Restart memcached to ensure considtency with service configuration changes
'daemons/memcached' = 'restart';
bind '/software/components/metaconfig/services/{/etc/nova/nova.conf}/contents' = openstack_nova_compute_config;

# Include nova.conf configuration common to all services
include 'features/nova/common/config';

# [DEFAULT] section
'contents/DEFAULT/compute_driver' = 'libvirt.LibvirtDriver';
'contents/DEFAULT/cpu_allocation_ratio' = OS_NOVA_CPU_RATIO;
'contents/DEFAULT/initial_cpu_allocation_ratio' = OS_NOVA_INITIAL_CPU_RATIO;
'contents/DEFAULT/disk_allocation_ratio' = OS_NOVA_DISK_RATIO;
'contents/DEFAULT/initial_disk_allocation_ratio' = OS_NOVA_INITIAL_DISK_RATIO;
'contents/DEFAULT/ram_allocation_ratio' = OS_NOVA_RAM_RATIO;
'contents/DEFAULT/initial_ram_allocation_ratio' = OS_NOVA_INITIAL_RAM_RATIO;
'contents/DEFAULT/resume_guests_state_on_host_boot' = if (OS_NOVA_RESUME_VM_ON_BOOT) {
    true;
} else {
    null;
};
'contents/DEFAULT/max_concurrent_snapshots' = OS_NOVA_MAX_CONCURRENT_SNAPSHOTS;

# [cinder] section
'contents/cinder' = {
    if ( OS_CINDER_ENABLED ) {
        dict('os_region_name', OS_REGION_NAME);
    } else {
        null;
    };
};

# [libvirtd] section
'contents/libvirt/virt_type' = OS_NOVA_VIRT_TYPE;

# [vnc] section
'contents/vnc/enabled' = true;
'contents/vnc/server_listen' = '0.0.0.0';
'contents/vnc/server_proxyclient_address' = PRIMARY_IP;
'contents/vnc/novncproxy_base_url' = OS_NOVA_VNC_PROTOCOL + '://' + OS_NOVA_VNC_HOST + ':6080/vnc_auto.html';

# Configure Ceph if needed
include if ( OS_NOVA_USE_CEPH ) 'features/nova/compute/ceph';
