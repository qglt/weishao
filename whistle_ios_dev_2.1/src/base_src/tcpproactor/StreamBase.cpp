#include <base/tcpproactor/StreamBase.h>
#include <boost/array.hpp>
#include <boost/bind.hpp>
#include <boost/make_shared.hpp>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/json/tinyjson.hpp>

using namespace std;
using namespace boost;
namespace epius
{
	namespace proactor
	{
		boost::system::error_code getStreamError(stream_error_id val)
		{
			static shared_ptr<stream_error> err_info[SERR_PLACEHOLDER] =
			{
                shared_ptr<stream_error>(new stream_error("the stream has already been connected, try close it then connect again")),
				shared_ptr<stream_error>(new stream_error("Write to a stream before connected or after closed!"))
			};
			return boost::system::error_code(val,*(err_info[val]));
		}
	}

	namespace proactor
	{
		CStreamBase::CStreamBase()
		{

		}

		CStreamBase::~CStreamBase(void)
		{
		}
		void CStreamBase::write(string const& str)
		{
			json::jobject jobj;
			jobj["command"] = "write";
			jobj["to_write"] = str;
			stream_action act = {jobj};
			(*actionCmd_)(act);
		}
		
		void CStreamBase::close(void)
		{
			json::jobject jobj;
			jobj["command"] = "close";
			stream_action act = {jobj};
			(*actionCmd_)(act);
		}
		void CStreamBase::post(boost::function<void(void)>cmd)
		{
			json::jobject jobj;
			jobj["command"] = "post";
			stream_action act = {jobj,cmd};
			(*actionCmd_)(act);
		}
		void CStreamBase::set_timer(int nInterval, boost::function<void()> cmd)
		{
			json::jobject jobj;
			jobj["command"] = "set_timer";
			jobj["interval"] = nInterval;
			stream_action act = {jobj,cmd};
			(*actionCmd_)(act);
		}

		void CStreamBase::setActionCmd( shared_ptr<boost::function<void(stream_action)> > cmd )
		{
			actionCmd_ = cmd;
		}
	}
}
