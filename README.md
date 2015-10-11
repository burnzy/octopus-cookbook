octopus cookbook
================
[![Cookbook Version](https://img.shields.io/cookbook/v/octopus.svg)](https://supermarket.chef.io/cookbooks/octopus)

Installs, configures, and registers an octopus tentacle on your chef node.

Requirements
------------
- `windows` - depends on the windows community cookbook

### Tentacle Attributes
The following attributes are used to configure tentacle related attributes, accessible via `node['octopus']['tentacle'][attribute]`.

Attribute                    | Description                                                                         | Default
-----------------------------|-------------------------------------------------------------------------------------|---------------------
version                      |The version of the octopus tentacle                                                  |`2.6.0.778`
package_name                 |The package name of the octopus tentacle msi package                                 |`Octopus Deploy Tentacle`
install_dir                  |The installation directory of where to install the tentacle                          |`C:\Program Files\Octopus Deploy\Tentacle`
port                         |The port that the tentacle will listen on                                            |`10933`
home                         |The home directory for the tentacle                                                   |`C:\Octopus`
role                         |The role that will be assigned to the tentacle                                       |`webserver`
name                         |The name of the tentacle                                                             |`Tentacle`
url                          |The download url of the octopus tentacle installation package                        |`https://download.octopusdeploy.com/octopus/Octopus.Tentacle.#{node['octopus']['tentacle']['version']}-x64.msi`
checksum                     |The checksum of the tentacle installation package (SHA-256 hash)                     |`cb81f5296f7843c5c04cb20a02793bb14dad50f6453a0f264ebe859e268d8289`

### API Attributes
The following attributes are used to configure octopus api related attributes, accessible via `node['octopus']['api'][attribute]`.

Attribute                    | Description                                                                         | Default
-----------------------------|-------------------------------------------------------------------------------------|---------------------
uri                          |The uri of your octopus server's api                                                 |`http://my-octopus-server.com/api`
key                          |The api key used to register the tentacle with the octopus server                    |`API-XXXXXXXXXXXXXXXXXXXXXXXXXXX`

### Server Attributes
The following attributes are used to configure server related attributes, accessible via `node['octopus']['server'][attribute]`.

Attribute                    | Description                                                                         | Default
-----------------------------|-------------------------------------------------------------------------------------|---------------------
thumbprint                   |The octopus server's thumbprint                                                      |`XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`


Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x` or `feature_xyz`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
License: Apache 2.0
Authors: Michael Burns
