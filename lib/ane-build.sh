#!/bin/bash

echo "--------------------------------------------------------------------------------"
pushd `dirname $2`

MODULE=$4
ANE=$6
JAR=$8
PROJECT_DIR=`realpath ../..`
PRODUCT_DIR=$PROJECT_DIR/bin
BUILD_DIR=$PROJECT_DIR/build/production/${MODULE}-ane
AIR_SDK_HOME=~/Developer/air-sdk-20

echo "start build: $MODULE"

cp -rf ./* $BUILD_DIR
rm -rf $BUILD_DIR/*.sh

# 检测编译平台
PLAT_ANDROID=`cat extension.xml | grep 'Android-ARM' | sed 's/[^"]*"//' | sed 's/">//'`
PLAT_IPHONE=`cat extension.xml | grep 'iPhone-ARM' | sed 's/[^"]*"//' | sed 's/">//'`
echo "compile:" $PLAT_ANDROID $PLAT_IPHONE


# air sdk版本
VERSION=`$AIR_SDK_HOME/bin/adt -version | sed 's/\..*//g'`
echo "air sdk version:" $VERSION


# 替换版本号
REPLACE_CMD="s#air/extension/20#air/extension/$VERSION#"
cat extension.xml | sed $REPLACE_CMD > $BUILD_DIR/extension.xml
if [ ! "x${PLAT_ANDROID}" = "x" ] ; then
    cat platform-android.xml | sed $REPLACE_CMD > $BUILD_DIR/platform-android.xml
fi
if [ ! "x${PLAT_IPHONE}" = "x" ] ; then
    cat platform-ios.xml | sed $REPLACE_CMD > $BUILD_DIR/platform-ios.xml
fi


# 编译swc
AS_SRC=../${MODULE}-as/src
AS_SWC=${MODULE}.swc

echo "compile as"
find $AS_SRC -name "*.as" | sed "s:$AS_SRC/:  [SWC] <= :"
$AIR_SDK_HOME/bin/acompc -swf-version 30 -include-sources $AS_SRC -output $BUILD_DIR/$AS_SWC > /dev/null

# 解压library.swf
tar -C $BUILD_DIR/default/ -xzf $BUILD_DIR/$AS_SWC library.swf
if [ ! "x$PLAT_ANDROID" = "x" ] ; then
    cp -f $BUILD_DIR/default/library.swf $BUILD_DIR/Android-ARM/library.swf
fi
if [ ! "x$PLAT_IPHONE" = "x" ] ; then
    cp -f $BUILD_DIR/default/library.swf $BUILD_DIR/iPhone-ARM/library.swf
fi


# 编译java文件
if [ ! "x$PLAT_ANDROID" = "x" ] ; then
    JAVA_BUILD_DIR=$PROJECT_DIR/build/production/${MODULE}-android
    JAVA_LIB_DIR=../${MODULE}-android/libs
    JAVA_LIBS=$PROJECT_DIR/lib/android/android.jar
    JAVA_LIBS=$JAVA_LIBS:$PROJECT_DIR/lib/air-runtime/FlashRuntimeExtensions.jar
    JAVA_LIBS=$JAVA_LIBS:$PROJECT_DIR/lib/air-runtime/runtimeClasses.jar

    for file in `find $JAVA_LIB_DIR -name "*.jar"` ; do
        JAVA_LIBS=$JAVA_LIBS:$file
    done

    if [ ! -d $JAVA_BUILD_DIR ] ; then
        mkdir -p $JAVA_BUILD_DIR
    fi

    cp -rf ../${MODULE}-android/src/* $JAVA_BUILD_DIR

    JAVA_SRC=$JAVA_BUILD_DIR
    JAVA_FILES=`find . $JAVA_SRC -name "*.java"`

    # 编译打包jar
    echo "compile java"
    find $JAVA_SRC -name "*.java" | sed "s:$JAVA_SRC/:  [JAR] <= :"
    javac -classpath $JAVA_LIBS -sourcepath $JAVA_SRC -d $JAVA_BUILD_DIR $JAVA_FILES
    find $JAVA_BUILD_DIR -name "*.java" | xargs rm -rf
    jar -cf $BUILD_DIR/Android-ARM/lib${MODULE}.jar -C $JAVA_BUILD_DIR .

    if [ "x$JAR" != "x" ] ; then
        cp ${JAVA_LIB_DIR}/$JAR $BUILD_DIR/Android-ARM/$JAR
        # 如果有assets资源则解压到输出目录
        ASSETS=`tar -tf $BUILD_DIR/Android-ARM/$JAR | grep '^assets'`
        if [ "x$ASSETS" != "x" ] ; then
            rm -rf $PRODUCT_DIR/openane-${MODULE} && mkdir $PRODUCT_DIR/openane-${MODULE}
            tar -C $PRODUCT_DIR/openane-${MODULE} -xf $JAVA_LIB_DIR/$JAR $ASSETS
        fi
    fi
fi

# 编译objc
if [ ! "x$PLAT_IPHONE" = "x" ] ; then
    XCODEBUILDCMD=`which xcodebuild`
    if [ ! "x$XCODEBUILDCMD" = "x" ] ; then
        echo "compile obj-c"
        OBJC_BUILD_DIR=$PROJECT_DIR/build/production/${MODULE}-ios
        xcodebuild -project ../${MODULE}-ios/${MODULE}-ios.xcodeproj/ \
            CONFIGURATION_BUILD_DIR=$OBJC_BUILD_DIR \
            CONFIGURATION_TEMP_DIR=$OBJC_BUILD_DIR \
            BUILD_DIR=$OBJC_BUILD_DIR \
            BUILD_ROOT=$OBJC_BUILD_DIR \
            OBJROOT=$OBJC_BUILD_DIR \
            SYMROOT=$OBJC_BUILD_DIR > /dev/null
        cp -rf ./iPhone-ARM/* $BUILD_DIR/iPhone-ARM
    fi
fi

# 编译ane
pushd $BUILD_DIR > /dev/null # cd $BUILD_DIR
COMPILE_FLAGS="-package -target ane $ANE extension.xml -swc ${MODULE}.swc"
COMPILE_DEFAULT="-platform default -C ./default ."

if [ ! "x$PLAT_ANDROID" = "x" ] ; then
    COMPILE_ANDROID="-platform Android-ARM -platformoptions platform-android.xml -C ./Android-ARM ."
fi

if [ ! "x$PLAT_IPHONE" = "x" ] ; then
    COMPILE_IPHONE="-platform iPhone-ARM -platformoptions platform-ios.xml -C ./iPhone-ARM ."
fi

$AIR_SDK_HOME/bin/adt $COMPILE_FLAGS $COMPILE_ANDROID $COMPILE_IPHONE $COMPILE_DEFAULT
popd > /dev/null # back to work dir


# 拷贝至输出目录
if [ -f $BUILD_DIR/$ANE ] ; then
    echo "build success: "$PRODUCT_DIR/$ANE
    cp -f $BUILD_DIR/$ANE $PRODUCT_DIR/$ANE
else
    echo "build error!!!"
fi

popd
echo "--------------------------------------------------------------------------------"
