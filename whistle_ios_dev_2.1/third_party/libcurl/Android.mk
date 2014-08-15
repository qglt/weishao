LOCAL_PATH := $(call my-dir)

#CFLAGS := -Wpointer-arith -Wwrite-strings -Wunused -Winline \
 -Wnested-externs -Wmissing-declarations -Wmissing-prototypes -Wno-long-long \
 -Wfloat-equal -Wno-multichar -Wsign-compare -Wno-format-nonliteral \
 -Wendif-labels -Wstrict-prototypes -Wdeclaration-after-statement \
 -Wno-system-headers -DHAVE_CONFIG_H


include $(CLEAR_VARS)
CFLAGS := -DHAVE_CONFIG_H
include $(LOCAL_PATH)/lib/Makefile.inc
#include $(LOCAL_PATH)/Makefile.inc

LOCAL_MODULE := curl

#LOCAL_SRC_FILES := $(addprefix cul/lib/,$(CSOURCES))
#FILE_LIST := $(wildcard $(LOCAL_PATH)/curl/lib/*.c)
FILE_LIST := $(wildcard $(LOCAL_PATH)/lib/*.c)
LOCAL_SRC_FILES := $(FILE_LIST:$(LOCAL_PATH)/%=%)
LOCAL_CFLAGS += $(CFLAGS)
#LOCAL_C_INCLUDES += $(LOCAL_PATH)/curl/include
#LOCAL_C_INCLUDES += $(LOCAL_PATH)/curl/lib
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/lib

#LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/curl/include
#LOCAL_EXPORT_C_INCLUDES += $(LOCAL_PATH)/curl/lib
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_EXPORT_C_INCLUDES += $(LOCAL_PATH)/lib

#LOCAL_COPY_HEADERS_TO := libcurl
#LOCAL_COPY_HEADERS := $(addprefix curl/include/curl/,$(HHEADERS))

include $(BUILD_STATIC_LIBRARY)
#include $(BUILD_SHARED_LIBRARY)

