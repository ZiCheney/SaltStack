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

/usr/local/include/mysql:
  file.symlink:
    - target: {{ pillar['install_dir'] }}/include

/etc/my.cnf:
  file.managed:
    - source: salt://mysql-master-slave/files/slave.cnf
    - user: root
    - group: root
    - mode: '0644'


mysqld.service:
  service.running:
    - enable: true

set-password-mysql:
  cmd.run: 
    - name: {{ pillar['install_dir'] }}/bin/mysql -e "set password = password('{{ pillar['password'] }}');"
    - unless: {{ pillar['install_dir'] }}/bin/mysql -uroot -p'{{ pillar['password'] }}' -e 'exit'

start-slave:
  file.managed:
    - name: /tmp/mysql-install.sh
    - source: salt://mysql-master-slave/files/mysql-install.sh.j2
    - mode: '0755'
    - template: jinja
  cmd.run:
    - name: /bin/bash  /tmp/mysql-install.sh
    - unless: test $( {{ pillar['install_dir'] }}/bin/mysql -uroot -pwjm123 -e "show slave status\G;" | grep '_Running' | grep -c 'Yes')  -eq 2
