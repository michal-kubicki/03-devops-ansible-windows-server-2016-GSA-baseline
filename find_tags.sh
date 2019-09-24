#!/bin/bash

# Finding available Ansible tags in playbooks and roles
# http://blog.leifmadsen.com/blog/2017/01/04/finding-available-ansible-tags-in-playbooks-and-roles/

for i in $(ls playbooks/*.yml)
do
   	ansible-playbook --list-tags $i 2>&1
done | grep "TASK TAGS" | cut -d":" -f2 | awk '{sub(/\[/, "")sub(/\]/, "")}1' | sed -e 's/,//g' | xargs -n 1 | sort -u
