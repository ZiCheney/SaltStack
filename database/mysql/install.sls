ncurses-compat-libs:
  pkg.installed

mysql:
  user.present:
    - system: true
    - createhome: false
    - shell: /sbin/nologin

tar-mysql:
  archive.extracted:
    - source: salt://modules/database/mysql/files/mysql-5.7.34-linux-glibc2.12-x86_64.tar.gz
    - name: /usr/local
  file.symlink:
    - name: {{ pillar['install_dir'] }}
    - target: /usr/local/mysql-5.7.34-linux-glibc2.12-x86_64 

{{ pillar['install_dir'] }}:
  file.directory:
    - user: mysql
    - name: {{ pillar['install_dir'] }}
    - group: mysql
    - mode: '0755'
    - recurse:
      - user
      - group

{{ pillar['data_path'] }}:
  file.directory:
    - user: mysql
    - group: mysql
    - mode: '0755'
    - makedirs: true
    - recurse:
      - user
      - group 

/etc/profile.d/mysqld.sh:
  file.managed:
    - source: salt://modules/database/mysql/files/mysqld.sh 


{{ pillar['install_dir'] }}/support-files/mysql.server:
  file.managed:
    - source: salt://modules/database/mysql/files/mysql.server
    - user: mysql
    - group: mysql
    - mode: '0755'


/usr/lib/systemd/system/mysqld.service:
  file.managed:
    - source: salt://modules/database/mysql/files/mysqld.service.j2
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja

mysql-initialize:
  cmd.run:
    - name: '{{ pillar['install_dir'] }}/bin/mysqld --initialize-insecure --user=mysql --datadir={{ pillar['data_path'] }}'
    - require:
      - archive: tar-mysql
      - user: mysql
      - file: {{ pillar['data_path'] }}
    - unless: test $(ls -l  /opt/data/ | wc -l) -gt 1
