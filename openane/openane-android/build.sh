#!/bin/bash

echo "--------------------------------------------------------------------------------"
pushd `dirname $0`

PROJECT=../..

echo "start build: $PROJECT/lib/openane.jar"

LIBS=$PROJECT/lib/android/android.jar
LIBS=$LIBS:$PROJECT/lib/air-runtime/FlashRuntimeExtensions.jar
LIBS=$LIBS:$PROJECT/lib/air-runtime/runtimeClasses.jar
SRC=./src
BUILD_DIR=$PROJECT/build/production/openane-android

rm -rf $BUILD_DIR && mkdir -p $BUILD_DIR

find $SRC -name "*.java" | sed "s:$SRC/:  [JAR] <= :"
FILES=`find $SRC -name "*.java"`
javac -classpath $LIBS -sourcepath $SRC -d $BUILD_DIR $FILES
jar -cf $PROJECT/lib/openane.jar -C $BUILD_DIR .

popd
echo "--------------------------------------------------------------------------------"