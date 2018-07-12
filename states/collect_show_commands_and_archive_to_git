{% set device_directory = grains['id'] %}

make sure the local repo doesnt exist:
  file.absent:
    - name: /tmp/local_repo

git clone:
  module.run:
    - name: git.clone
    - cwd: /tmp/local_repo
    - url: git@100.123.35.2:automation_demo/show_commands_collected.git
    - identity: "/root/.ssh/id_rsa"

git config set email:
  module.run:
    - name: git.config_set
    - cwd: /tmp/local_repo
    - key: user.email
    - value: me@example.com

git config set name:
  module.run:
    - name: git.config_set
    - cwd: /tmp/local_repo
    - key: user.name
    - value: ksator

git config get name:
  module.run:
    - name: git.config_get
    - cwd: /tmp/local_repo
    - key: user.name

git pull:
  module.run:
    - name: git.pull
    - cwd: /tmp/local_repo

make sure the device directory is presents:
  file.directory:
    - name: /tmp/local_repo/{{ device_directory }}

{% for item in pillar['collect_show_commands'] %}

{{ item.command }}:
  junos.cli:
    - name: {{ item.command }}
    - dest: /tmp/local_repo/{{ device_directory }}/{{ item.command }}.txt
    - format: text

git add {{ item.command }}:
  module.run:
    - name: git.add
    - cwd: /tmp/local_repo
    - filename: /tmp/local_repo/{{ device_directory }}/{{ item.command }}.txt

{% endfor %}

git commit:
  module.run:
    - name: git.commit
    - cwd: /tmp/local_repo
    - message: 'The commit message'

git push:
  module.run:
    - name: git.push
    - cwd: /tmp/local_repo
    - remote: origin
    - ref: master
    - identity: "/root/.ssh/id_rsa"

delete local repo:
  file.absent:
    - name: /tmp/local_repo
