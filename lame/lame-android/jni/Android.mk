LOCAL_PATH := $(call my-dir)
LOCAL_CPP_EXTENSION := .cpp

include $(CLEAR_VARS)

LOCAL_MODULE        := lame
LOCAL_MODULE_FILENAME := liblame
LOCAL_SRC_FILES     := \
./lamewrapper.cpp \
./lame_jni.cpp \
./lame/bitstream.c \
./lame/encoder.c \
./lame/fft.c \
./lame/gain_analysis.c \
./lame/id3tag.c \
./lame/lame.c \
./lame/mpglib_interface.c \
./lame/newmdct.c \
./lame/presets.c \
./lame/psymodel.c \
./lame/quantize.c \
./lame/quantize_pvt.c \
./lame/reservoir.c \
./lame/set_get.c \
./lame/tables.c \
./lame/takehiro.c \
./lame/util.c \
./lame/vbrquantize.c \
./lame/VbrTag.c \
./lame/version.c

LOCAL_LDLIBS := -llog
LOCAL_CFLAGS = -DSTDC_HEADERS

include $(BUILD_SHARED_LIBRARY)