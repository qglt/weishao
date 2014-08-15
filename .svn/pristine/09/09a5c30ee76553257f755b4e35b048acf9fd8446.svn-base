#include <base/thread/thread_base/thread_base.h>
using namespace boost;
using namespace std;
using namespace epius;

thread_base::thread_base(void):m_bEndThread(false)
{
	m_workThread.reset(new thread(thread(boost::bind(&thread_base::work,this))));
}

thread_base::~thread_base(void)
{
	stop();
}
void thread_base::post( boost::function<void()> cmd )
{
    boost::mutex::scoped_lock lock(m_mutex);
	m_cmdQueue.push_back(cmd);
	m_cond.notify_all();
}
void thread_base::work()
{
	while(!m_cmdQueue.empty() || !m_bEndThread)
	{
		boost::function<void()> cmd;
		{
            boost::mutex::scoped_lock lock(m_mutex);
            cmd = get_cmd_from_queue();
		}
		if(cmd.empty())
		{
            boost::mutex::scoped_lock lock(m_mutex);
			boost::xtime xt;  
			boost::xtime_get(&xt,boost::TIME_UTC_);  
			xt.sec += 1;   
			m_cond.timed_wait(lock,xt);
		}
		else
		{
			cmd();
		}
	}
}

void thread_base::stop()
{
	m_bEndThread = true;
	m_cond.notify_all();
	try {m_workThread->join();}catch(...){}
}

boost::function<void()> thread_base::get_cmd_from_queue()
{
    boost::function<void()> cmd;
    if(!m_cmdQueue.empty())
    {
        cmd = *m_cmdQueue.begin();
        m_cmdQueue.pop_front();
    }
    return cmd;
}

bool epius::thread_base::is_in_work_thread()
{
    if(!m_workThread)return false;
    return m_workThread->get_id() == boost::this_thread::get_id();
}

void epius::thread_base::continue_work()
{
	m_cond.notify_one();
}
