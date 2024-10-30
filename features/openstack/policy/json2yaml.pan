# Template to create a script to convert JSON-formatted policy files to YAML 
# for all services configured on the server.
# It must be included at the very end of the server configuration, typically in the
# template doine the repository configuration.

unique template features/openstack/policy/json2yaml;

include 'features/openstack/policy/json2yaml_schema';

# Build conversion script based on current node type
'/software/components/metaconfig/commands/json2yaml' = '/var/quattor/script/openstack/policy_json2yaml';
prefix '/software/components/metaconfig/services/{/var/quattor/script/openstack/policy_json2yaml}';
'module' = 'openstack/json2yaml';
# Use post action to run the script every time metaconfig is run
'actions/post' = 'json2yaml';
'convert/joinspace' = true;
'mode' = 0755;
bind '/software/components/metaconfig/services/{/var/quattor/script/openstack/policy_json2yaml}/contents' = openstack_policy_json2yaml;
'contents/services' = OS_NODE_SERVICES;


# Load TT file to create the conversion script for the current node type
# Run metaconfig in case the TT file was modified and configuration must be regenerated
include 'components/filecopy/config';
'/software/components/filecopy/dependencies/post' = openstack_add_component_dependency('metaconfig');
prefix '/software/components/filecopy/services/{/usr/share/templates/quattor/metaconfig/openstack/json2yaml.tt}';
'config' = file_contents('features/openstack/policy/json2yaml.tt');
'perms' = '0644';
