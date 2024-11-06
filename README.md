# OpenStack template library

## Installation

There is one set of templates for each OpenStack version: be sure to use the templates
appropriate to the version you use. For each OpenStack version, there is a separate
branch in the repository.

* Install repository under `cfg/openstack/$VERSION`
* Add `cfg/openstack/$VERSION` into cluster.build.properties

Replace $VERSION by the OpenStack version name.

## Usage
* Create a template site/openstack/config

Look @ defaults/openstack/config.pan to have a list of all needed variables and for
the default passwords used (consider changing them in your configuration).

## Some comment

Service configuration files are associated with a schema to ensure that the file content is valid.

## Supported services

The list of supported services is evolving with versions. Main supported services are:

* Central MariaDB database
* RabbitMQ
* Keystone
* Nova
* Glance
* Cinder
* Neutron
* Compute
* Magnum
* Heat
* Barbican
* Horizon
