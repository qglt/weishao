#pragma once


#include <boost/msm/back/state_machine.hpp>
#include <boost/msm/front/state_machine_def.hpp>
#include <boost/msm/front/functor_row.hpp>
#include <boost/shared_ptr.hpp>

#include <base/json/tinyjson.hpp>
namespace msm = boost::msm;
namespace mpl = boost::mpl;
namespace msmf = boost::msm::front;


#define DEFINE_EVENT(x) struct x:public epius::event_json_base { x(json::jobject jobj):epius::event_json_base(jobj, #x){}; x():epius::event_json_base(json::jobject(), #x){}}
#define DEFINE_STATE(x) struct x:public msm::front::state<>
#define DEFINE_MACHINE(x) struct x;typedef msm::back::state_machine<x> x##_suply;struct x : public msm::front::state_machine_def<x>

namespace epius
{
	struct event_json_base
	{
		event_json_base(json::jobject jobj, std::string env_name):env_data_(jobj), event_name_(env_name){}
		json::jobject env_data_;
		std::string event_name_;
	};
	struct AllActions
	{
		template <class Fsm,class Event, class sourceState, class dstState>
		bool operator()(Event const& e, Fsm& fsm, sourceState&, dstState&) const
		{
			return true;
		}
	};
}