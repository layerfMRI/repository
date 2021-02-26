#!/bin/sh
# fixPermsSFIM.sh
#
# Change permissions on all files in a folder so that the group is SFIM and the
# group is given the same permissios as the user (you).
#
# USAGE:
# bash fixPermsSFIM.sh <folderName>
#
# Created 2016 by AT.
# Updated 11/7/17 by DJ - comments.

fpdir=$1

chown -R :SFIM $1 &>/dev/null
chmod -R g=u $1 &>/dev/null
