#ifndef __mylog_h_
#define __mylog_h_

#include <fcntl.h>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
using namespace std;
static const char* default_file_name = "D:\\default_log_file.log";
static std::string prepareFileNmae()
{
    return default_file_name;
}
template<class T>
ostream& operator << (ostream&os, std::vector<T> &data)
{
	int i;for(i = 0;i<data.size();i++)
		os<< data[i] <<"    ";
	os<<endl;
	return os;
}
class _MyLog
{
public:
    _MyLog(void) : _logfile(prepareFileNmae()) {}
    ~_MyLog(void) {}

    void setf(const std::string& logfile) {
        if (!logfile.empty())
            _logfile = logfile;
    }
	template<typename C> _MyLog& operator << (C data) {
		ofstream of(_logfile.c_str(),ios::app|ios::out);
 		std::ostringstream ostr;
 		ostr << data;
 		std::string s = ostr.str();
 		of<<s;
	return *this;
}
    _MyLog& operator << (_MyLog& (*f)(_MyLog&)) {
        return f(*this); 
    }
	
protected:
    _MyLog(const _MyLog&);
    _MyLog& operator = (const _MyLog&);

private:
    std::string _logfile;
};
static _MyLog &endl(_MyLog &strim)
{
	strim<<'\n';
	return strim;
}
static _MyLog mylog;

#endif //#ifndef __mylog_h_
