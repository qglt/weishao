#pragma once
#include <string>

/* @brief initCrashReport������������google_breakpad��dumpץȡ���ơ�
    @param path:     ����ָ������dump�ļ���ȫ·����UTF-8���롣
    @param type:     ����ָ������dump�ļ������͡�
    @return:         no return type
    @note:
    */
bool initCrashReport(const std::string &filename);
