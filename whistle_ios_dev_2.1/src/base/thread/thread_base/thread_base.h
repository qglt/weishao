#pragma once
#include <deque>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>
#include <boost/thread/condition.hpp>
#include <base/config/configure.hpp>
namespace epius {
    class thread_base
    {
    public:
        thread_base(void);
        ~thread_base(void);
        void post(boost::function<void()> cmd);
		void continue_work();
        void stop();
        bool is_in_work_thread();
    protected:
        void work();
        virtual boost::function<void()> get_cmd_from_queue();
        std::deque<boost::function<void()> > m_cmdQueue;
        boost::shared_ptr<boost::thread> m_workThread;
        boost::mutex m_mutex;
        boost::condition m_cond;
        bool m_bEndThread;
    };
}
