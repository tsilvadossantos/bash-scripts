#!/bin/bash

#Usage: Inform branch and release version through command line argument

clear

TOMCAT_LOC="/opt/tomcat-PLATFORM"
TOMCAT_API_LOC="/opt/tomcat-API"
WAR_LOC="${TOMCAT_LOC}/webapps"
WAR_API_LOC="${TOMCAT_API_LOC}/webapps"
PLATFORM_REPO="PLATFORM"
PLATFORM_REPO_LOC="/opt/${PLATFORM_REPO}"

if [ $# -eq 0 ]; then
    echo "Release not informed!!! (ERROR -1)"
    exit 1
fi

# Kill tomcat and API
sudo "$TOMCAT_LOC/bin/shutdown.sh" -force && sleep 15
sudo "$TOMCAT_API_LOC/bin/shutdown.sh" -force && sleep 15


echo " -- Begin cleaning -- "
cd $WAR_LOC
echo " -- inside war location "
sudo rm -rf *.war
cd $WAR_API_LOC
sudo rm -rf api*
echo " -- Begin cleaning -- "

# Restart tomcat
echo "Starting Tomcat"
sudo "$TOMCAT_LOC/bin/startup.sh"
sleep 20
sudo "$TOMCAT_API_LOC/bin/startup.sh"

DELAY=15

# checkout branch x components
for i in "$@";
do

  if [ $i != $1  ]
  then

    # Pull source for branch
    sudo rm -rf $PLATFORM_REPO_LOC/$i

    #clone repo
    cd $PLATFORM_REPO_LOC
    sudo su -c "git clone git@bitbucket.org:domain-mb/$i"

    cd $i/
    #git rebase
    echo "Rebasing for origin/$1"
    sudo su -c "git rebase origin/$1"

    #echo "Checking out branch $1"
    sudo su -c "git checkout -f $1"

    #echo "Pulling latest code"
    sudo su -c "git pull -f"

    #fix artifactory url
    sed -i -e 's/artifactory.domain/artifactory.dc.domain/g' gradle.properties
    sed -i -e 's/artifactory.domain/artifactory.dc.domain/g' build.gradle

    #build war
    if [ $i == "PLATFORM-product" ]
    then
      ./gradlew clean jar publishToMavenLocal
    else
      ./gradlew clean war -x test
      #rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
      find . -name "*.war" -exec cp {} $WAR_LOC \;
    fi

    sleep $DELAY

  fi

done
