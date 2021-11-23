include:
  - modules.database.mysql.install

lamp-dep-package:
  pkg.installed:
    - pkgs:
      - ncurses-devel 
      - openssl-devel 
      - openssl 
      - cmake 
      - mariadb-devel



/etc/my.cnf:
  file.managed:
    - source: salt://mysql-master-slave/files/master.cnf
    - user: root
    - group: root
    - mode: '0644'

mysqld.service:
  service.running:
    - enable: true
    - reload: true
    - require:
      - file: /usr/lib/systemd/system/mysqld.service
      - archive: tar-mysql
    - watch:
      - file: /etc/my.cnf


set-password-mysql:
  cmd.run: 
    - name: {{ pillar['install_dir'] }}/bin/mysql -e "set password = password('{{ pillar['password'] }}');"
    - require:
      - service: mysqld.service 
    - unless: {{ pillar['install_dir'] }}/bin/mysql -uroot -p'{{ pillar['password'] }}' -e 'exit'



shouquan:
  cmd.run:
    - name: {{ pillar['install_dir'] }}/bin/mysql -uroot -p'{{ pillar['password'] }}' -e  "GRANT REPLICATION SLAVE,super ON *.* TO 'wjm'@'%' IDENTIFIED BY '{{ pillar['password'] }}'; FLUSH PRIVILEGES;"
    - unless: {{ pillar['install_dir'] }}/bin/mysql -uroot -p'{{ pillar['password'] }}' -e "select user from mysql.user;" | grep wjm 
 
