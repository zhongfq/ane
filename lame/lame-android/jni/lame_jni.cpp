//
// $id: lame_jni.cpp O $
//

#include <Android/log.h>
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include "lamewrapper.h"

#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, "net.sourceforge.lame",__VA_ARGS__)

extern "C" {

JNIEXPORT jlong JNICALL 
Java_net_sourceforge_lame_LameWrapper_create(JNIEnv *env, jclass cls)
{
    lamewrapper *wrapper = new lamewrapper();
    return (jlong)wrapper;
}

JNIEXPORT void JNICALL 
Java_net_sourceforge_lame_LameWrapper_update(JNIEnv *env, jclass cls, jlong id, jbyteArray buffer, jint len) 
{
    lamewrapper *wrapper = (lamewrapper *)id;
    buffer_t *buf = (buffer_t *)malloc(sizeof(*buf));
    buf->data = (char *)malloc(len);
    buf->capacity = len;
    buf->pos = 0;
    memcpy(buf->data, (char *)env->GetByteArrayElements(buffer, NULL), len);
    wrapper->push(buf);
}

JNIEXPORT jbyteArray JNICALL
Java_net_sourceforge_lame_LameWrapper_buffer(JNIEnv *env, jclass cls, jlong id)
{
    lamewrapper *wrapper = (lamewrapper *)id;
    wrapper->flush();
    buffer_t *buf = wrapper->buffer();
    jbyteArray bytes = env->NewByteArray(buf->pos);
    env->SetByteArrayRegion(bytes, 0, buf->pos, (const jbyte *)buf->data);
    return bytes;
}

JNIEXPORT void JNICALL 
Java_net_sourceforge_lame_LameWrapper_dispose(JNIEnv *env, jclass cls, jlong id) 
{
    lamewrapper *wrapper = (lamewrapper *)id;
    delete wrapper;
}

}