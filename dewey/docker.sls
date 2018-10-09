{% set dewey_uid = salt.pillar.get('uids:dewey:uid', 'None') %}
{% set dewey_gid = salt.pillar.get('uids:dewey:gid', 'None') %}
{% set postgres_password = salt.pillar.get('secrets:dewey:postgres', 'Aiy5vah0cheep') %}
{% set postgres_major = salt.pillar.get('version:postgresql_major', '9.4') %}

include:
  - common.repos
  # - nginx
  - postgres

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

# nginx-dewey-config-file:
#   file.managed:
#     - name: /etc/nginx/sites-available/dewey.conf
#     - source: salt://dewey/conf/etc/nginx/sites-available/dewey.conf
#     - template: jinja
#     - require:
#       - pkg: nginx

# nginx-dewey-config-symlink:
#   file.symlink:
#     - name: /etc/nginx/sites-enabled/dewey.conf
#     - target: /etc/nginx/sites-available/dewey.conf
#     - require:
#       - file: nginx-dewey-config-file

# nginx-wildcard-key:
#   file.managed:
#     - name: /etc/nginx/ssl/soma-wildcard-easyrsa.key
#     - contents_pillar: secrets:soma-wildcard-easyrsa:key
#     - mode: 0640
#     - require:
#       - pkg: nginx
#     - makedirs: true

#   nginx:
#     service.running:
#       - enable: True
#       - watch:
#         - file: /etc/nginx/sites-enabled/*
