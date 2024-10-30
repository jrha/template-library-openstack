structure template features/keystone/client/config-minimal;

'auth_url' = format('%s://%s:35357', OS_KEYSTONE_CONTROLLER_PROTOCOL, OS_KEYSTONE_CONTROLLER_HOST);
'auth_type' = OS_KEYSTONE_TOKEN_AUTH_TYPE;
'project_domain_id' = 'default';
'user_domain_id' = 'default';
'project_name' = 'service';
