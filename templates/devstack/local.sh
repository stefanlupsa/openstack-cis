#!/bin/bash
set -e

echo "Before updating nova flavors:"
openstack flavor list

nova flavor-delete 1 || echo "Flavor 1 not found"
nova flavor-delete 42 || echo "Flavor 42 not found"
nova flavor-delete 84 || echo "Flavor 84 not found"
nova flavor-delete 451 || echo "Flavor 451 not found"
nova flavor-delete 452 || echo "Flavor 452 not found"


nova flavor-create m1.tiny 1 521 2 1
nova flavor-create m1.nano 42 256 2 1
nova flavor-create m1.micro 84 256 3 1
nova flavor-create m1.heat 451 512 2 1
nova flavor-create m1.heat2 452 1024 2 1

echo "After updating nova flavors:"
nova flavor-list

# Add DNS config to the private network
subnet_id=`openstack network show private | grep subnets | awk '{print $4}'`
openstack subnet set $subnet_id --dns-nameserver 8.8.8.8 --dns-nameserver 8.8.4.4

echo "Neutron networks:"
openstack network list
for net in `openstack network list| grep -v '\-\-' |grep -v "Subnets" | awk {'print $2'}`; do openstack network show $net; done
echo "Neutron subnetworks:"
openstack subnet list
for subnet in `openstack subnet list | grep -v '\-\-' |grep -v "ID" |awk {'print $2'}`; do openstack subnet show $subnet; done

# NAT VM internet traffic 
sudo /sbin/iptables -t nat -A POSTROUTING -s {{ floating_range }} -o eth0 -j MASQUERADE

{% if localsh_append is defined %}
{{ localsh_append }}
{% endif %}
