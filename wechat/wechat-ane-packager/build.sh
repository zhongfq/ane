#!/bin/bash

MODULE="wechat"
ANE="openane-${MODULE}.ane"
JAR="libammsdk.jar"
PROJECT=`dirname $0`/../..
BUILD=$PROJECT/build/production/${MODULE}-ane
JAVA_BUILD=$PROJECT/build/production/${MODULE}-android

while : ; do
    if [ -f "$PROJECT/.wechat_packagename" ] ; then
        PACKAGE_NAME=`cat $PROJECT/.wechat_packagename`
    else
        echo "please enter package name for wechat: "
        read PACKAGE_NAME
    fi

    if [ "x$PACKAGE_NAME" != "x" ] ; then
        echo $PACKAGE_NAME > $PROJECT/.wechat_packagename
        break
    fi
done

rm -rf $BUILD && mkdir -p $BUILD
rm -rf $JAVA_BUILD && mkdir -p $JAVA_BUILD

JAVA_SRC=`dirname $0`/../${MODULE}-android/src
WXAPI_SRC=$JAVA_BUILD/${PACKAGE_NAME//./\/}/wxapi

mkdir -p ${WXAPI_SRC}
cat ${JAVA_SRC}/openane/wechat/wxapi/WXPayEntryActivity.java \
    | sed 's/openane.wechat.wxapi/'${PACKAGE_NAME}'.wxapi/' \
    > ${WXAPI_SRC}/WXPayEntryActivity.java
cat ${JAVA_SRC}/openane/wechat/wxapi/WXEntryActivity.java \
    | sed 's/openane.wechat.wxapi/'${PACKAGE_NAME}'.wxapi/' \
    > ${WXAPI_SRC}/WXEntryActivity.java

$PROJECT/lib/ane-build.sh -workpath $0 -module $MODULE -ane $ANE -jar $JAR