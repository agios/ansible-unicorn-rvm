Ansible Unicorn/RVM setup
=========================

This Ansible role installs a service for Unicorn, with RVM and multiple application support

Requirements
------------

Expects rvm to be installed system-wide


Role Variables
--------------

-   `rvm_root` defaults to `/usr/local/rvm`
-   `rvm_exe`  defaults to `/usr/local/rvm/bin/rvm`
-   `rails_apps` defaults to `[]`

    Each rails_apps entry is a dict with the following options

    -   `name` (eg `my_app`, required)
    -   `ruby_version` (eg `ruby-2.1.1`, required)
    -   `env` defaults to `production`
    -   `root` defaults to `/var/www/{{ name }}/current` (Capistrano
        compatible)

Example Playbook
----------------

The role could be included in a playbook as follows:

```yaml
---
-hosts: application
  roles:
    - role: unicorn-rvm
      rails_apps:
        - { name: 'my_app1', ruby_version: 'ruby-1.9.3' }
        - { name: 'my_app2', ruby_version: 'ruby-2.1.1', root: '/var/test_apps/app2', env: staging }
```

If the init script is called without any config parameters,
it will attempt to run the init command for all unicorn configurations listed in /etc/unicorn/_*_.conf

`/etc/init.d/unicorn start` # starts all unicorns

If you specify a particular config, it will only operate on that one

`/etc/init.d/unicorn start my_app`

Notes
-----

This role does not deploy the actual application, it assumes that this
will be done in another role or using a deployment tool such as
[Capistrano](https://github.com/capistrano/capistrano).

License
-------

MIT

