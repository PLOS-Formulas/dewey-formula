{% set dewey_uid = salt.pillar.get('uids:dewey:uid', 'None') %}
{% set dewey_gid = salt.pillar.get('uids:dewey:gid', 'None') %}
{% set postgres_password = salt.pillar.get('secrets:dewey:postgres', 'Aiy5vah0cheep') %}
{% set postgres_major = salt.pillar.get('version:postgresql_major', '9.4') %}

include:
  - common.repos
  # - nginx
  - postgres

dewey_compose_file:
  file.managed:
    - name: /opt/dewey/docker-compose.yml
    - source: salt://dewey/docker-compose.yml
    - owner: dewey
    - group: dewey
    - require:
      - group: dewey
      - user: dewey

# Using overrides lets us keep the compose file minimal so Dewey can be
# launched outside of salt for development.
# dewey_compose_overrides:
#   file.managed:
#     - name: /opt/dewey/docker-compose.override.yml
#     - source: salt://dewey/conf/opt/dewey/docker-compose.override.yml
#     - owner: dewey
#     - group: dewey
#     - template: jinja
#     - defaults:
#       secret_key: salt.pillar.get('secrets:dewey:secret_key', 'faiw5xeeweetaizuDee7a')
#       pg_host: salt.pillar.get('dewey:postgres_host_docker')
#       pg_pass: salt.pillar.get('secrets:dewey:postgres', 'Aiy5vah0cheep')
#       jira_pass: salt.pillar.get('secrets:dewey:jira', 'asdf1234')
#       pdns_url: salt.pillar.get('dewey:powerdns_api_url', 'http://10.9.8.7:8910')
#       pdns_key: salt.pillar.get('secrets:pdns:api-key', 'iej6ood8amiequ7beiLe7eiMiepo9bi')
#       vault_pass: salt.pillar.get('secrets:dewey:vault', 'uebeeMu9aikei')
#       django_settings_module: salt.pillar.get('dewey:django_settings_module_docker', 'dewey.core.settings.production')
#       host_ip: salt.plosutil.get_canonical_ip()
#     - require:
#       - group: dewey
#       - user: dewey

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

extend:
  /etc/postgresql/{{ postgres_major }}/main/pg_hba.conf:
    file.managed:
      - context:
          extended_access:
            - type: host
              database: dewey
              user: dewey
              method: md5

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
