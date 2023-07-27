#!/bin/bash

sudo mkdir -p /var/www/html/efs-mount-point

#Replace fs-xxxxxxxxxxxxxxxxx.efs.us-east-1.amazonaws.com with your EFS mount target DNS name. The fstab entry is necessary in order to ensure the EFS mount is persistent over multiple instance reboots.
sudo echo "fs-xxxxxxxxxxxxxxxxx.efs.us-east-1.amazonaws.com:/ /var/www/html/efs-mount-point nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

#Replace fs-xxxxxxxxxxxxxxxxx.efs.us-east-1.amazonaws.com with your EFS mount target DNS name. Specify the path for the EFS mount target.
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-xxxxxxxxxxxxxxxxx.efs.us-east-1.amazonaws.com:/ /var/www/html/efs-mount-point

sudo systemctl restart httpd.service