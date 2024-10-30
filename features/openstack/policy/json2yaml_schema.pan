unique template features/openstack/policy/json2yaml_schema;

type openstack_policy_json2yaml = {
    'services' : choice(
        'barbican',
        'ceilometer',
        'cinder',
        'compute',
        'glance',
        'heat',
        'keystone',
        'magnum',
        'nova',
        'neutron',
        'octavia',
        'placement'
    )[]
};
