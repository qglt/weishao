#pragma once


#include <string>
#include <vector>
#include <map>
#include <boost/assert.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <third_party/sqlite/sqlite3.h>
#include <base/config/configure.hpp>
#include <base/utility/tuple/tuple.hpp>
#include <base/utility/macro_helper/meta_macro.h>
#include <stdexcept>

#define MAKEEPBINDER_IMPL_ONELINE(n,y)																								\
	template<LINE_EXPAND_N(n,RBIND,TYPE_PARAM)>																						\
	epDbBinder(LINE_EXPAND_N(n,RBIND,FUN_CONST_REF_PARAM)):																			\
		binderImpl_(																												\
			new epDbBinderImpl<typename epius::tuples::detail::make_tuple_mapper< LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::type>(		\
				epius::make_tuple( LINE_EXPAND_N(n,RBIND,FUN_IMPL ))																		\
				)){}

namespace epius
{
	namespace epius_sqlite3
	{
		enum epius_dberror_id {OPENDB_FAILED,TRANS_WITHOUT_DBIMPL, DBFILE_IS_HOLD_BY_OTHER_APPS, EP_DBERR_HOLDER, INNER_DB_ERROR};
		class epius_dberror: public std::runtime_error
		{
		public:
			epius_dberror(epius_dberror_id val, std::string const& errMsg);//:std::runtime_error(errMsg.c_str()), m_msg(errMsg) { };
			~epius_dberror() throw() { } //by LiMing
			epius_dberror_id get_id() const;
			virtual const char * what() const throw();
		private:
			epius_dberror_id error_id_;
			std::string err_msg_;
		};
		const epius_dberror &getEpdbError(epius_dberror_id val);
		template<int n>struct Int2Type
		{
			enum {val=n};
		};

		using namespace boost;
		class epDbBinder;
		class data_iterator;
		class epDbImpl:public boost::enable_shared_from_this<epDbImpl>
		{
			friend class data_iterator;
			friend class epDbTrans;
			friend class epDbAutoCreate;
		public:
			epDbImpl(std::string const&dbname, std::string const& password);
			bool tableExist(std::wstring const&wtablename);
			int execDML(const std::wstring& szSQL, epDbBinder const &epbinder);
			data_iterator execQuery(const std::wstring& szSQL, epDbBinder const &epbinder);
			void rekey(std::string new_key);
			sqlite3_int64 last_insert_rowid();

		private:
			void inner_throw(epius_dberror const& err);
			bool dberror_flag;
			boost::shared_ptr<sqlite3> dbinstance_;
		};
        //for string type, epDbBinder only support wstring and string in utf8 format.
        //for info stored in db, it can be get in wstring and in string format, where string will be in utf8 format.
		class data_iterator
		{
		public:
			data_iterator();
			data_iterator(boost::shared_ptr<epDbImpl> pimpl,boost::shared_ptr<sqlite3_stmt> stmt);
			data_iterator(data_iterator const& dst);
			template<class T>T getField(int nCol)
			{
				T val;
 				getField(nCol,val);
				return val;
			}
			template<class T>void getField(int nCol, T&val);
			bool operator==(data_iterator const& dst);
			bool operator!=(data_iterator const& dst);
			data_iterator* operator->(){return this;}
			data_iterator& operator++();
		private:
			boost::weak_ptr<epDbImpl> dbimpl_;
			boost::shared_ptr<sqlite3_stmt> dbstmt_;
		};
		class epDbBinder
		{
		private:
			template<class T> static bool bind_element(sqlite3_stmt* pstmt,int nCol, T val);
			struct epDbBinderImplBase
			{
				virtual bool dobind(sqlite3_stmt* pstmt)=0;
				virtual void takevalue(data_iterator it)=0;
				virtual ~epDbBinderImplBase(){}
			};
			template<class tuple_type> struct epDbBinderImpl:public epDbBinderImplBase
			{
				tuple_type bindObjs_;
				epDbBinderImpl(tuple_type const& val):bindObjs_(val){}
				virtual bool dobind(sqlite3_stmt* pstmt){return inner_bind(pstmt,Int2Type<epius::tuples::length<tuple_type>::value>());}
				virtual void takevalue(data_iterator it){inner_takevalue(it,Int2Type<epius::tuples::length<tuple_type>::value>());}
			private:
				template<class IntType> bool inner_bind(sqlite3_stmt* pstmt, IntType)
				{
					if(!epDbBinder::bind_element(pstmt,IntType::val, bindObjs_.template get<IntType::val-1>()))return false;
					return inner_bind(pstmt,Int2Type<IntType::val-1>());
				}
				template<class IntType> void inner_takevalue(data_iterator it, IntType)
				{
					it->getField(IntType::val-1, bindObjs_.template get<IntType::val-1>());
					inner_takevalue(it,Int2Type<IntType::val-1>());
				}
				bool inner_bind(sqlite3_stmt* pstmt, Int2Type<1>)
				{
					return epDbBinder::bind_element(pstmt,1, bindObjs_.template get<0>());
				}
				void inner_takevalue(data_iterator it, Int2Type<1>)
				{
					it->getField(0, bindObjs_.template get<0>());
				}
			};
		public:
			struct blob:public std::string
			{
				blob(){}
				blob(const void* ptr, int len):std::string((char*)ptr,len){}
				void* get_ptr() const{return (void*)c_str();}
			};
			epDbBinder(){}
			CONSTRUCT(MAX_MEMBER_NUMBER,MAKEEPBINDER_IMPL_ONELINE);
			bool dobind(sqlite3_stmt* pstmt) const;
			epDbBinder& operator=(epius::epius_sqlite3::data_iterator it);
		private:
			boost::shared_ptr<epDbBinderImplBase> binderImpl_;
		};
		
		class epDbTrans
		{
		public:
			epDbTrans(boost::shared_ptr<epDbImpl> impl);
			~epDbTrans();
		private:
			boost::weak_ptr<epDbImpl> dbimpl_;
		};

		class epDb
		{
		public:
			epDb(std::string const&dbname, std::string const& password = "");
			bool tableExists(std::wstring const&wtablename);
			boost::shared_ptr<epDbTrans> beginTrans();
			int execDML(const std::wstring& sql, epDbBinder epbinder = epDbBinder());
			data_iterator execQuery(const std::wstring& sql, epDbBinder epbinder = epDbBinder());
			std::wstring epDbVersion();
			void rekey(std::string new_key);
			sqlite3_int64 last_insert_rowid();
		protected:
			boost::shared_ptr<epDbImpl> dbimpl_;
		};
		class epDbAutoCreate:public epDb
		{
			struct epDbAllowChangeImpl;
		public:
			epDbAutoCreate(std::string const&dbname, std::string const& password = "");
			int execDML(std::wstring const& table_name, const std::wstring& sql, epDbBinder epbinder = epDbBinder());
			data_iterator execQuery(std::wstring const& table_name, const std::wstring& sql, epDbBinder epbinder = epDbBinder());
			void setTableInit(std::map<std::wstring, std::vector<std::wstring> > inits);
		private:
			boost::shared_ptr<epDbAllowChangeImpl> impl_;
		};
	}
}
