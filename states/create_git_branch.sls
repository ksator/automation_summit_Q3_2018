{% set device_directory = grains['id'] %}

make sure the local repo dont exist:
  file.absent:
    - name: /tmp/local_repo/{{ device_directory }}

{% for item in pillar["repositories"] %}

git clone {{ item }}:
  module.run:
    - name: git.clone
    - cwd: /tmp/local_repo/{{ device_directory }}/{{ item }}
    - url: git@100.123.35.2:automation_demo/{{ item }}.git
    - identity: "/root/.ssh/id_rsa"

git config set email {{ item }}:
  module.run:
    - name: git.config_set
    - cwd: /tmp/local_repo/{{ device_directory }}/{{ item }}
    - key: user.email
    - value: me@example.com

git config set name {{ item }}:
  module.run:
    - name: git.config_set
    - cwd: /tmp/local_repo/{{ device_directory }}/{{ item }}
    - key: user.name
    - value: ksator

switch to the branch {{ device_directory }} {{ item }}:
  module.run:
    - name: git.checkout
    - cwd: /tmp/local_repo/{{ device_directory }}/{{ item }}
    - opts: '-b {{ device_directory }}'

git push {{ item }}:
  module.run:
    - name: git.push
    - cwd: /tmp/local_repo/{{ device_directory }}/{{ item }}
    - remote: origin
    - ref: {{ device_directory }}
    - identity: "/root/.ssh/id_rsa"

{% endfor %}

delete local repo:
  file.absent:
    - name: /tmp/local_repo/{{ device_directory }}
