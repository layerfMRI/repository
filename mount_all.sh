#!/bin/bash

echo "fange an"

# in order for this to run there must be few toolsw instatlled: 
# sudo apt-get install nfs-common
# sudo apt-get install cifs-utils
# sudo ls -l /sbin/mount.cifs

#sudo mkdir /mnt/helix
sudo mount -t cifs -o rw,sec=ntlmsspi,user=huberl,domain=NIH.gov,uid=brain //helixdrive.nih.gov/huberl /mnt/helix



#sudo mkdir /mnt/helix_NIMH_SFIM 
sudo mount -t cifs -o rw,sec=ntlmsspi,user=huberl,domain=NIH.gov,uid=brain //helixdrive.nih.gov/NIMH_SFIM /mnt/helix_NIMH_SFIM

#sudo mkdir /mnt/erbium
#sudo mount -t cifs -o rw,sec=ntlmsspi,user=huberl,domain=NIH.gov,uid=brain //erbium.nimh.nih.gov/huberl /mnt/erbium


echo "und tschuess:  expects: phase_eval.sh "

 
