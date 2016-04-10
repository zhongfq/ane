#!/bin/bash

echo "--------------------------------------------------------------------------------"
pushd `dirname $2`

MODULE=$4
ANE=$6
JAR=$8
PROJECT=../..
PRODUCT=$PROJECT/bin
BUILD=$PROJECT/build/production/${MODULE}-ane

echo "start build: $MODULE"

cp -rf ./* $BUILD
rm -rf $BUILD/*.sh

# 检测编译平台
PLAT_ANDROID=`cat extension.xml | grep 'Android-ARM' | sed 's/[^"]*"//' | sed 's/">//'`
PLAT_IPHONE=`cat extension.xml | grep 'iPhone-ARM' | sed 's/[^"]*"//' | sed 's/">//'`
echo "compile:" $PLAT_ANDROID $PLAT_IPHONE


# air sdk版本
VERSION=`$AIR_SDK_HOME/bin/adt -version | sed 's/\..*//g'`
echo "air sdk version:" $VERSION


# 替换版本号
REPLACE_CMD="s#air/extension/20#air/extension/$VERSION#"
cat extension.xml | sed $REPLACE_CMD > $BUILD/extension.xml
if [ ! "x${PLAT_ANDROID}" = "x" ] ; then
    cat platform-android.xml | sed $REPLACE_CMD > $BUILD/platform-android.xml
fi
if [ ! "x${PLAT_IPHONE}" = "x" ] ; then
    cat platform-ios.xml | sed $REPLACE_CMD > $BUILD/platform-ios.xml
fi


# 编译swc
AS_SRC=../${MODULE}-as/src
AS_SWC=${MODULE}.swc

find $AS_SRC -name "*.as" | sed "s:$AS_SRC/:  [SWC] <= :"
$AIR_SDK_HOME/bin/acompc -include-sources $AS_SRC -output $BUILD/$AS_SWC > /dev/null

# 解压library.swf
tar -C $BUILD/default/ -xzf $BUILD/$AS_SWC library.swf
if [ ! "x$PLAT_ANDROID" = "x" ] ; then
    cp -f $BUILD/default/library.swf $BUILD/Android-ARM/library.swf
fi
if [ ! "x$PLAT_IPHONE" = "x" ] ; then
    cp -f $BUILD/default/library.swf $BUILD/iPhone-ARM/library.swf
fi


# 编译java文件
if [ ! "x$PLAT_ANDROID" = "x" ] ; then
    JAVA_BUILD=$PROJECT/build/production/${MODULE}-android
    JAVA_LIB_DIR=../${MODULE}-android/libs
    JAVA_LIBS=$PROJECT/lib/android/android.jar
    JAVA_LIBS=$JAVA_LIBS:$PROJECT/lib/air-runtime/FlashRuntimeExtensions.jar
    JAVA_LIBS=$JAVA_LIBS:$PROJECT/lib/air-runtime/runtimeClasses.jar
    JAVA_LIBS=$JAVA_LIBS:$PROJECT/lib/openane.jar

    for file in `find $JAVA_LIB_DIR -name "*.jar"` ; do
        JAVA_LIBS=$JAVA_LIBS:$file
    done

    if [ ! -d $JAVA_BUILD ] ; then
        mkdir -p $JAVA_BUILD
    fi

    cp -rf ../${MODULE}-android/src/* $JAVA_BUILD

    JAVA_SRC=$JAVA_BUILD
    JAVA_FILES=`find . $JAVA_SRC -name "*.java"`

    # 编译打包jar
    find $JAVA_SRC -name "*.java" | sed "s:$JAVA_SRC/:  [JAR] <= :"
    javac -classpath $JAVA_LIBS -sourcepath $JAVA_SRC -d $JAVA_BUILD $JAVA_FILES
    find $JAVA_BUILD -name "*.java" | xargs rm -rf
    jar -cf $BUILD/Android-ARM/lib${MODULE}.jar -C $JAVA_BUILD .

    cp ${JAVA_LIB_DIR}/$JAR $BUILD/Android-ARM/$JAR
    cp $PROJECT/lib/openane.jar $BUILD/Android-ARM/openane.jar

    # 如果有assets资源则解压到输出目录
    ASSETS=`tar -tf $BUILD/Android-ARM/$JAR | grep '^assets'`
    if [ "x$ASSETS" != "x" ] ; then
        rm -rf $PRODUCT/openane-${MODULE} && mkdir $PRODUCT/openane-${MODULE}
        tar -C $PRODUCT/openane-${MODULE} -xf $JAVA_LIB_DIR/$JAR $ASSETS
    fi
fi


# 编译ane
pushd $BUILD > /dev/null # cd $BUILD
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
if [ -f $BUILD/$ANE ] ; then
    echo "build success: "$PRODUCT/$ANE
    cp -f $BUILD/$ANE $PRODUCT/$ANE
else
    echo "build error!!!"
fi

popd
echo "--------------------------------------------------------------------------------"