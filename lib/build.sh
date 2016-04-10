#!/bin/bash

echo "select a module to build:"

PROJECT=`dirname $0`/..

select NAME in quit all alipay tencent wechat weibo iapstore openane
do
    case ${NAME} in
        all)
            bash $PROJECT/openane/openane-android/build.sh
            bash $PROJECT/alipay/alipay-ane-packager/build.sh
            bash $PROJECT/tencent/tencent-ane-packager/build.sh
            bash $PROJECT/wechat/wechat-ane-packager/build.sh
            bash $PROJECT/weibo/weibo-ane-packager/build.sh
            bash $PROJECT/iapstore/iapstore-ane-packager/build.sh
            ;;
        alipay|tencent|wechat|weibo|iapstore)
            bash $PROJECT/${NAME}/${NAME}-ane-packager/build.sh
            ;;
        openane)
            bash $PROJECT/openane/openane-android/build.sh
            ;;
        quit)
            break
            ;;
        *)
            echo "select a module to build:"
            ;;
    esac
done