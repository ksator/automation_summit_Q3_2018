{% set device_directory = grains['id'] %}

make sure the local repo doesnt exist:
  file.absent:
    - name: /tmp/local_repo/{{ device_directory }}

git clone:
  git.latest:
    - name: git@100.123.35.1:automation_demo/show_commands_collected.git
    - target: /tmp/local_repo/{{ device_directory }}
    - identity: "/root/.ssh/id_rsa"
    - branch: {{ device_directory }}
    - rev: {{ device_directory }}

mylocalrepo:
  git.config_set:
    - name: user.email
    - value: me@example.com
    - repo: /tmp/local_repo/{{ device_directory }}

mylocalrepo1:
  git.config_set:
    - name: user.name
    - value: ksator
    - repo: /tmp/local_repo/{{ device_directory }}

{% for item in pillar['collect_show_commands'] %}

{{ item.command }}:
  junos.cli:
    - name: {{ item.command }}
    - dest: /tmp/local_repo/{{ device_directory }}//{{ item.command }}.txt
    - format: text

git add {{ item.command }}:
  module.run:
    - name: git.add
    - cwd: /tmp/local_repo/{{ device_directory }}
    - filename: /tmp/local_repo/{{ device_directory }}/{{ item.command }}.txt

{% endfor %}

git commit:
  module.run:
    - name: git.commit
    - cwd: /tmp/local_repo/{{ device_directory }}
    - message: 'The commit message'

git push:
  module.run:
    - name: git.push
    - cwd: /tmp/local_repo/{{ device_directory }}
    - remote: origin
    - ref : {{ device_directory }}
    - identity: "/root/.ssh/id_rsa"


delete local repo:
  file.absent:
    - name: /tmp/local_repo/{{ device_directory }}
