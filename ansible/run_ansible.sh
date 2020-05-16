#!/bin/bash
set +ex

# todo genereate inventory.yml file with ec2 host
cd ../infra
terraform output ansible_inventory > ../ansible/inventory.yml
terraform output database_template > ../ansible/templates/database_rendered.tpl



# todo add any additional variables
cd ../ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml -e 'record_host_keys=True' -u ec2-user --private-key key/id_rsa playbook.yml

