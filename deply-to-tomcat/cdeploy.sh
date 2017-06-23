#!/bin/bash
if [ $# -ne 2 ]
then
        echo "Usage $0 branch_name version"
        exit
fi
# backup first
GITPATH=git@git.oschina.net:chaobo/xxx.git

TOMCAT=/mnt/server/tomcat-wcd

SOURCEDIR=wcdtms

BAKDIR=/mnt/deploy_wcd/bak/

CONFIGPATH=/mnt/deploy_wcd/config/

CURRENTPATH=`pwd`

rm -rf $BAKDIR/*

cp -R $TOMCAT/webapps/*.war  $BAKDIR/

BRANCH_NAME="$1"

DATE_TIME="`date +'%F %T'`"

cd /mnt/source/

if [ -d $SOURCEDIR ]
then
	rm -rf $SOURCEDIR
fi

git clone $GITPATH
git fetch origin

cd $SOURCEDIR

#user the branch 
git branch $BRANCH_NAME origin/$BRANCH_NAME
git checkout $BRANCH_NAME
git pull origin $BRANCH_NAME

#git pull origin $BRANCH_NAME:$BRANCH_NAME

if [ $? -ne 0 ]
then
	echo "****************GIT PULL ERROR: $?. invalid branch name: ${BRANCH_NAME} ****************"
	exit
fi

git checkout $BRANCH_NAME

cd /mnt/source/$SOURCEDIR/src/main/webapp/

#update all the properties
#rm -rf /mnt/source/wcdtms/src/main/resources/*.properties

cp -Rf $CONFIGPATH/. /mnt/source/$SOURCEDIR/src/main/resources/


sh $CURRENTPATH/get_build_version.sh $2

echo -e "<b>Product Version: </b><br/>" > ./version.html
echo "<font color=red> V${2%.*} </font><br/>" >> ./version.html
echo -e "<b>Build Version: </b><br/>" >> ./version.html
echo "<font>`tail -n1 $CURRENTPATH/buildnum.txt`</font><br/>" >> ./version.html
echo -e "<b>Git Branch:</b><br/>" >> ./version.html
echo "${BRANCH_NAME}<br/>" >> ./version.html
echo -e "<b>Code Version:</b><br/>" >> ./version.html
echo "`git rev-parse HEAD`<br/>" >> ./version.html
echo -e "<b>Build Time:</b><br/>" >> ./version.html
echo $DATE_TIME >> ./version.html

cd /mnt/source/$SOURCEDIR/

mvn clean

mvn package -DskipTest

PID=`ps -ef | grep java | grep ${TOMCAT} | head -n1 |awk '{print $2}'`

if [ ! $PID ]; then
	echo "server stop already "
else
	kill -9 $PID
fi

rm -rf $TOMCAT/webapps/*

cp -f /mnt/source/$SOURCEDIR/target/*.war $TOMCAT/ROOT.war

sh $TOMCAT/catalina.sh start

exit
