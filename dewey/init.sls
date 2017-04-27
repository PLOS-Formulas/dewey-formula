{% set dewey_uid = salt.pillar.get('uids:dewey:uid', 'None') %}
{% set dewey_gid = salt.pillar.get('uids:dewey:gid', 'None') %}
{% set postgres_password = salt.pillar.get('secrets:dewey:postgres', 'Aiy5vah0cheep') %}
{% set postgres_major = salt.pillar.get('version:postgresql_major', '9.4') %}
{% set debconf_file = '/etc/dewey.debconf' %}

include:
  - common.repos
  - nginx
  - postgres
  - redis.master

dewey_postgres_user:
  postgres_user.present:
    - name: dewey
    - password: {{ postgres_password }}
    - encrypted: true
    - require:
      - pkg: postgresql

dewey_postgres_database:
  postgres_database.present:
    - name: dewey
    - owner: dewey
    - encoding: UTF8
    - lc_collate: en_US.UTF-8
    - lc_ctype: en_US.UTF-8
    - require:
      - postgres_user: dewey_postgres_user

dewey-debconf-seed:
  file.managed:
    - name: {{ debconf_file }}
    - source: salt://dewey/conf{{ debconf_file }}
    - template: jinja
    - mode: 0600

dewey-debconf-set:
  cmd.run:
    - name: debconf-set-selections {{ debconf_file }}
    - onchanges:
      - file: dewey-debconf-seed

dewey-debconf-reconfigure:
  cmd.run:
    - name: dpkg-reconfigure -fnoninteractive dewey
    - onchanges:
      - cmd: dewey-debconf-set
    - onlyif:
      - dpkg -l dewey

dewey:
  group:
    - present
    - gid: {{ dewey_gid }}
  user:
    - present
    - uid: {{ dewey_uid }}
    - home: /opt/dewey
    - shell: /bin/bash
    - gid_from_name: true
    - require:
      - group: dewey
  pkg.latest:
    - require:
      - postgres_database: dewey_postgres_database
      - user: dewey
      - cmd: dewey-debconf-set
  service.running:
    - enable: true
    - require:
      - pkg: dewey

dewey-worker-service:
  service.running:
    - name: dewey-worker
    - enable: true
    - require:
      - service: dewey

dewey-scheduler-service:
  service.running:
    - name: dewey-scheduler
    - enable: true
    - require:
      - service: dewey-worker-service

dewey-flower-service:
  service.running:
    - name: dewey-flower
    - enable: True
    - require:
      - service: dewey-worker-service

nginx-dewey-config-file:
  file.managed:
    - name: /etc/nginx/sites-available/dewey.conf
    - source: salt://dewey/conf/etc/nginx/sites-available/dewey.conf
    - template: jinja
    - require:
      - pkg: dewey
      - pkg: nginx

nginx-dewey-config-symlink:
  file.symlink:
    - name: /etc/nginx/sites-enabled/dewey.conf
    - target: /etc/nginx/sites-available/dewey.conf
    - require:
      - file: nginx-dewey-config-file

extend:
  apt-repo-plos:
    pkgrepo.managed:
      - require_in:
        - pkg: dewey
  /etc/redis/common.conf:
    file.managed:
      - context:
        addy_bind: ""
  /etc/postgresql/{{ postgres_major }}/main/postgresql.conf:
    file.managed:
      - context:
          listen: 127.0.0.1
  nginx:
    service.running:
      - enable: True
      - watch:
        - file: /etc/nginx/sites-enabled/*
      - require:
        - service: dewey
