#include <Windows.h>
#include <DbgHelp.h>
#include "../include/crash.h"
#include <stdlib.h>

#pragma warning(disable:4996)

// @berif crashMe 用于产生除零异常
static void crashMe()
{
	printf("start crash!\n");
	int *p = 0;
	*p = 5;
}

// @berif callBack 生产dump文件后的回调函数
static void callBack(const std::string &str, void* p)
{
	char buf[32];
	MessageBox(NULL, "点击确定关闭进程。", itoa((int)p, buf, 10), MB_OK);
}

// @berif removeDir 删除path指定的目录或文件
static bool removeDir(std::wstring path)
{
	std::wstring newPath = path;
	newPath.append(1, L'\0');

	SHFILEOPSTRUCTW FileOp;
	memset(&FileOp, 0, sizeof(FileOp));
	FileOp.fFlags = FOF_NOCONFIRMATION;
	FileOp.wFunc  = FO_DELETE;
	FileOp.pFrom  = newPath.c_str();
	return !SHFileOperationW(&FileOp);
}

// @berif test_1: 测试按名字创建dump文件.
static void test_1()
{
	printf("测试按名字创建dump文件.\n");
	if (GetFileAttributes("d:\\dumps") == INVALID_FILE_ATTRIBUTES) {
		CreateDirectoryA("d:\\dumps", NULL);
	}
	
	initCrashReport("d:\\dumps\\dump1.dmp", MiniDumpWithProcessThreadData);
	return;
}

// @berif test_2: 测试指定不存在的目录.
static void test_2()
{
	printf("测试指定不存在的目录.\n");
	if (GetFileAttributes("d:\\dumps") == INVALID_FILE_ATTRIBUTES) {
		CreateDirectoryA("d:\\dumps", NULL);
	}

	if (GetFileAttributes("d:\\dumps\\dir_abc") & FILE_ATTRIBUTE_DIRECTORY) {
		removeDir(L"d:\\dumps\\dir_abc");
	}

	initCrashReport("d:\\dumps\\dir_abc\\dump2.dmp", MiniDumpNormal);
	return;
}

// @berif test_3: 测试指定名字的dump.dmp文件已经存在，且不可写
static void test_3()
{
	printf("测试指定名字的dump.dmp文件已经存在，且不可写.\n");
	if (GetFileAttributes("d:\\dumps") == INVALID_FILE_ATTRIBUTES) {
		CreateDirectoryA("d:\\dumps", NULL);
	}

	removeDir(L"d:\\dumps\\dump3.dmp");

	HANDLE handle = CreateFileW(L"d:\\dumps\\dump3.dmp", GENERIC_ALL, FILE_SHARE_READ, NULL, OPEN_ALWAYS, 0, NULL);

	if (false == initCrashReport("d:\\dumps\\dump3.dmp", MiniDumpNormal))
		MessageBox(NULL, "文件d:\\dumps\\dump3.dmp已经存在，将不能抓取dump文件。", "", MB_OK);

	CloseHandle(handle);
	return;
}

// @berif testMe 按参数启动测试用例
static long testMe(long idx)
{
	switch(idx) {
		case 0:
			return 3;
		case 1:
			test_1();
			break;
		case 2:
			test_2();
			break;
		case 3:
			test_3();
			break;
		default:
			return -1;
	}

	crashMe();
	return 0;
}

int main(int argc, char **argv)
{
	if (argc == 1) { // 无参数时，启动全部测试用例
		STARTUPINFOA si = {sizeof(si)};
		PROCESS_INFORMATION pi;
		char buf[32];
		std::string crashCmdLine = "\"";
		crashCmdLine += argv[0];
		crashCmdLine += "\" ";
		
		// 获取测试用例数量
		long count = testMe(0);

		// 启动测试
		for(long i = 0; i<count; ++i) {
			std::string cmdLineWithParam = crashCmdLine + itoa(i, buf, 10);

 			if (::CreateProcessA(NULL, &cmdLineWithParam[0], NULL, NULL, 
				FALSE, CREATE_UNICODE_ENVIRONMENT, NULL, NULL, &si, &pi))
			{
 				::CloseHandle(pi.hThread);
 				::CloseHandle(pi.hProcess);
 			}
		}

	} else { // 有参数时，按参数启动测试用例
		long idx = atoi(argv[1]);
		if (idx) {
			if (-1 == testMe(idx)) {
				MessageBox(NULL, argv[1], argv[0], MB_OK);
			}
		}
	}
}
