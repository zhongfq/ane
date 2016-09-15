#!/bin/bash

echo "select a module to build:"

PROJECT=`dirname $0`/..

select NAME in quit all alipay tencent wechat weibo iapstore nativecontext lame
do
    case ${NAME} in
        all)
            bash $PROJECT/alipay/alipay-ane-packager/build.sh
            bash $PROJECT/tencent/tencent-ane-packager/build.sh
            bash $PROJECT/wechat/wechat-ane-packager/build.sh
            bash $PROJECT/weibo/weibo-ane-packager/build.sh
            bash $PROJECT/iapstore/iapstore-ane-packager/build.sh
            bash $PROJECT/nativecontext/nativecontext-ane-packager/build.sh
            bash $PROJECT/lame/lame-ane-packager/build.sh
            ;;
        alipay|tencent|wechat|weibo|iapstore|nativecontext|lame)
            bash $PROJECT/${NAME}/${NAME}-ane-packager/build.sh
            ;;
        quit)
            break
            ;;
        *)
            echo "select a module to build:"
            ;;
    esac
done
