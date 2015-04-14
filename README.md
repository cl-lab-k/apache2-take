apache2-take Cookbook
=====================

[![Build Status](https://secure.travis-ci.org/cl-lab-k/apache2-take.png?branch=master)](https://travis-ci.org/cl-lab-k/apache2-take)

This cookbook is for a Chef Handson Seminar **Take** course.

Requirements
------------

#### Platforms
- `ubuntu` - 10.04 LTS, 12.04 LTS, 14.04 LTS

Attributes
----------

#### apache2-take::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['apache2-take']['port']</tt></td>
    <td>String</td>
    <td>apache2 port number</td>
    <td><tt>8080</tt></td>
  </tr>
</table>

Usage
-----
#### apache2-take::default

e.g.
Just include `apache2-take` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[apache2-take]"
  ]
}
```

License and Authors
-------------------
* Author:: HIGUCHI Daisuke <d-higuchi@creationline.com>

* Copyright:: 2013m CREATIONLINE,INC.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
