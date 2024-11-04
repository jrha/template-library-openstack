unique template features/designate/config;

variable OS_NODE_SERVICES = append('designate');

include 'features/designate/rpms';
