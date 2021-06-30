#!/bin/bash


$echo 1 |  sshfs renzo@137.120.137.222:/mnt/ /mnt/ssh/var/www/

sudo mount -t cifs -o username=l.huber,vers=2.0,domain=unimaas,uid=1000,gid=1000 "//ca-um-nas201/fpn_rdm$" /mnt/ssh/rdm/

sudo mount -t smbfs -o -f=0777,-d=0777 '//unimaas;l.huber@fs/ca-um-nas201/fpn_rdm$' /mnt/ssh/rdm

mount_smbfs //l.huber@ca-um-nas201/fpn_rdm$ /mnt/ssh/rdm
