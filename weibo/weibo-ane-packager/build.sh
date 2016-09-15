#!/bin/bash

MODULE="weibo"
ANE="openane-${MODULE}.ane"
JAR="weibosdkcore.jar"
PROJECT=`dirname $0`/../..
BUILD=$PROJECT/build/production/${MODULE}-ane

rm -rf $BUILD && mkdir -p $BUILD

$PROJECT/lib/ane-build.sh -workpath $0 -module $MODULE -ane $ANE -jar $JAR