unique template features/neutron/controller/config;

@{
desc = if false, allow to disable restart of Neutron server after a config change. Strongly discouraged.
values = boolean
default = true
required = no
}
variable OS_NEUTRON_RESTART_ON_CONFIG_CHANGE ?= true;


variable OS_NODE_SERVICES = append('neutron');

# Load Neutron base configuration
include 'features/neutron/base';

# Include common server configuration
include 'features/neutron/server';

# Include policy file if OS_NEUTRON_POLICY is defined
@{
desc = file to load as the policy file. File extension is used to determine the policy file extension
values = path relative to include paths
default = undef
requied = no
}
variable OS_NEUTRON_POLICY ?= undef;
include 'components/filecopy/config';
'/software/components/filecopy/services' = {
    if ( is_defined(OS_NEUTRON_POLICY) ) {
        toks = matches(OS_NEUTRON_POLICY, '.*\.(json|yaml)$');
        if ( length(toks) < 2 ) {
            error('OS_NEUTRON_POLICY must be a file name with the extension .json or .yaml');
        };
        policy_file = format('/etc/neutron/policy.%s', toks[1]);
        SELF[escape(policy_file)] = dict(
            'config', file_contents(OS_NEUTRON_POLICY),
            'owner', 'root',
            'perms', '0644',
            'backup', true,
        );
    };

    SELF;
};


# neutron.conf
include 'components/metaconfig/config';
prefix '/software/components/metaconfig/services/{/etc/neutron/neutron.conf}';
'daemons/neutron-server' = if ( OS_NEUTRON_RESTART_ON_CONFIG_CHANGE ) {
    'restart';
} else {
    null
};
# Restart memcached to ensure considtency with service configuration changes
'daemons/memcached' = 'restart';
bind '/software/components/metaconfig/services/{/etc/neutron/neutron.conf}/contents' = openstack_neutron_server_config;

# [DEFAULT]
'contents/DEFAULT/notify_nova_on_port_status_changes' = true;
'contents/DEFAULT/notify_nova_on_port_data_changes' = true;
'contents/DEFAULT/use_ssl' = OS_NEUTRON_CONTROLLER_PROTOCOL == 'https';

# [database]
'contents/database/connection' = format('mysql+pymysql://%s:%s@%s/neutron', OS_NEUTRON_DB_USERNAME, OS_NEUTRON_DB_PASSWORD, OS_NEUTRON_DB_HOST);
'contents/database/max_pool_size' = OS_NEUTRON_DB_POOL_SIZE;
'contents/database/max_overflow' = OS_NEUTRON_DB_MAX_OVERFLOW;

# [nova]
'contents/nova' =  openstack_load_config(OS_AUTH_CLIENT_CONFIG);
'contents/nova/username' = OS_NOVA_USERNAME;
'contents/nova/password' = OS_NOVA_PASSWORD;

# [oslo_concurrency]
'contents/oslo_concurrency/lock_path' = '/var/lib/neutron/tmp';

# [ssl] section
'contents/ssl' = openstack_load_ssl_config( OS_NEUTRON_CONTROLLER_PROTOCOL == 'https' );
