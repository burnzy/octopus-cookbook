octopus Cookbook
================
This cookbook installs and configures an octopus tentacle on your chef node.


Requirements
------------
- `windows` - depends on the windows community cookbook

Attributes
----------

#### octopus::install_tentacle
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['octopus']['tentacle']['package_name']</tt></td>
    <td>String</td>
    <td>The name of the tentacle install package</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['octopus']['tentacle']['url']</tt></td>
    <td>String</td>
    <td>The url location of the tentacle install package</td>
    <td><tt>true</tt></td>
  </tr>
</table>


Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
License: Apache 2.0
Authors: Michael Burns

