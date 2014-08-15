#include <shlobj.h>
#include <shellapi.h>
#include <client/windows/handler/exception_handler.h>
#include <base/txtutil/txtutil.h>
#include "../include/crash.h"
#include <boost/filesystem.hpp>
#include <base/module_path/create_dir_nofailed.h>


using namespace google_breakpad;
std::wstring g_wstr_filename;
static bool dumpDoneCallback(const wchar_t *dumpPath,
	const wchar_t *dumpFile,
	void* context,
	EXCEPTION_POINTERS* exinfo,
	MDRawAssertionInfo* assertion,
	bool succeeded)
{
	boost::filesystem::wpath src_path(dumpPath);
	src_path /= std::wstring(dumpFile) + L".dmp";
	boost::filesystem::wpath dst_path(g_wstr_filename);
	try{
		boost::filesystem::copy_file(src_path, dst_path, boost::filesystem::copy_option::overwrite_if_exists);
		boost::filesystem::remove(src_path);
	}
	catch(...){}
	return true;
}

bool initCrashReport(const std::string &file_name, MINIDUMP_TYPE type)
{
	g_wstr_filename = txtconv::convert_utf8_to_wcs(file_name);
	boost::filesystem::wpath file_path(g_wstr_filename);
	std::wstring file_branch_path = file_path.branch_path().directory_string();
	biz::create_dir_nofailed::create_directories_nofailed(file_branch_path);
	google_breakpad::ExceptionHandler *pCrashHandler =
		new google_breakpad::ExceptionHandler(file_path.branch_path().directory_string(),NULL,dumpDoneCallback,NULL,
		google_breakpad::ExceptionHandler::HANDLER_ALL);
	if(pCrashHandler == NULL) {
		return false;
	}
	return true;
}
