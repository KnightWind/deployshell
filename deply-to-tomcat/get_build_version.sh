#!/bin/sh

if [ $# -ne 1 ]
then
        echo "Usage $0 version"
        exit
fi

BASE_DIR="/mnt/deploy"

CURRENT_BUILD_VERSION=`tail -n1 $BASE_DIR/buildnum.txt`

VERSION_STR="VD$1.BUILD"

if [[ "${CURRENT_BUILD_VERSION%.*}" == "${VERSION_STR}" ]]
then
 NEXT_BUILD_VERSION=`tail -n1 $BASE_DIR/buildnum.txt  | awk -F "." '{print ($NF)+1}'`
else
 NEXT_BUILD_VERSION="1"	
fi

THIS_VERSION=$VERSION_STR.$NEXT_BUILD_VERSION
 
echo "`date +'%F %T'`:" >> $BASE_DIR/buildnum.txt

echo $THIS_VERSION >> $BASE_DIR/buildnum.txt

