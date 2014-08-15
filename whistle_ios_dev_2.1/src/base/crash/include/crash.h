#pragma once
#include <string>

/* @brief initCrashReport函数用来启动google_breakpad的dump抓取机制。
    @param path:     用于指定生成dump文件的全路径，UTF-8编码。
    @param type:     用于指定生成dump文件的类型。
    @return:         no return type
    @note:
    */
bool initCrashReport(const std::string &filename);
