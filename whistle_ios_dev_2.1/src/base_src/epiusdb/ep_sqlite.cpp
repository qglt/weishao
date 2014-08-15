#include <boost/array.hpp>
#include <base/utility/tuple/tuple.hpp>
#include <base/epiusdb/ep_sqlite.h>
#include <base/txtutil/txtutil.h>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/format.hpp>
#include <base/log/elog/elog.h>
#include <boost/filesystem.hpp>
#include <base/module_path/epfilesystem.h>
using namespace std;
namespace epius
{
	namespace epius_sqlite3
	{
		const epius_dberror & getEpdbError(epius_dberror_id val)
		{
			static boost::array<epius_dberror,EP_DBERR_HOLDER> err_info =
			{
				epius_dberror( OPENDB_FAILED, "unable to open database" ),
				epius_dberror( TRANS_WITHOUT_DBIMPL, "a transaction operation can not be finished because the db instance killed" ),
				epius_dberror( DBFILE_IS_HOLD_BY_OTHER_APPS, "database file is opened by other application")
			};
			return err_info[val];
		}

		epius_dberror generateEpdbError(sqlite3* stat)
		{
			return epius_dberror( INNER_DB_ERROR, sqlite3_errmsg( stat ) );
		}

//implement of epDbImpl------------------------------------------------------------------------------
		static bool IsDBValid(sqlite3* pSqlite)
		{
			const char *tail = NULL;
			sqlite3_stmt* pstmt;
			std::string sql_utf8 = "select count(*) from sqlite_master";
			if (sqlite3_prepare(pSqlite, sql_utf8.c_str(), sql_utf8.length(), &pstmt, &tail)!=SQLITE_OK)
			{
					return false;
			}
			boost::shared_ptr<sqlite3_stmt> inner_stmt(pstmt,sqlite3_finalize);
			switch (sqlite3_step(pstmt))
			{
			case SQLITE_DONE:
			case SQLITE_ROW:return true;
			default:return false;
			}
		}
		epDbImpl::epDbImpl(std::string const&dbname, std::string const& password):dberror_flag(false)
		{
			sqlite3* pSqlite;
			if(sqlite3_open(dbname.c_str(),&pSqlite)!=SQLITE_OK)throw getEpdbError(OPENDB_FAILED);
			if(!password.empty())
			{
				sqlite3_key(pSqlite, password.c_str(),password.length());
			}
			if(!IsDBValid(pSqlite))
			{
				sqlite3_close(pSqlite);
				try{
					epfilesystem::instance().remove_file(dbname);
				}
				catch(...){
					throw getEpdbError(DBFILE_IS_HOLD_BY_OTHER_APPS);
				}
				if(sqlite3_open(dbname.c_str(),&pSqlite)!=SQLITE_OK)throw getEpdbError(OPENDB_FAILED);
				if(!password.empty())
				{
					sqlite3_key(pSqlite, password.c_str(),password.length());
				}
			}
			dbinstance_ = boost::shared_ptr<sqlite3>(pSqlite,sqlite3_close);
		}
		int epDbImpl::execDML(const std::wstring& sql, epDbBinder const& epbinder)
		{
			execQuery(sql,epbinder);
			return sqlite3_changes(dbinstance_.get());
		}
		data_iterator epDbImpl::execQuery(const std::wstring& sql, epDbBinder const& epbinder)
		{
			std::string sql_utf8 = txtconv::convert_wcs_to_utf8(sql);
			ELOG("db")->debug(sql_utf8);
			const char *tail = NULL;
			sqlite3_stmt* pstmt;
			if (sqlite3_prepare(dbinstance_.get(), sql_utf8.c_str(), sql_utf8.length(), &pstmt, &tail)!=SQLITE_OK)	inner_throw(generateEpdbError(dbinstance_.get()));
			boost::shared_ptr<sqlite3_stmt> inner_stmt(pstmt,sqlite3_finalize);
			if(!epbinder.dobind(pstmt))inner_throw(generateEpdbError(dbinstance_.get()));
			switch (sqlite3_step(pstmt))
			{
				case SQLITE_DONE:return data_iterator();
				case SQLITE_ROW:return data_iterator(shared_from_this(),inner_stmt);
				default:inner_throw (generateEpdbError(dbinstance_.get()));
			}
			return data_iterator();//avoid compile warning
		}
		bool epDbImpl::tableExist(std::wstring const&wtablename)
		{
			return execQuery(L"select count(*) from sqlite_master where type='table' and name=?",epDbBinder(wtablename))->getField<int>(0)>0;
		}
		
		void epDbImpl::inner_throw( epius_dberror const& err )
		{
			dberror_flag = true;
			throw err;
		}

		void epDbImpl::rekey( std::string new_key )
		{
			if(dbinstance_)
			{
				sqlite3_rekey(dbinstance_.get(),new_key.c_str(),new_key.length());
			}
		}

		sqlite3_int64 epDbImpl::last_insert_rowid()
		{
			if(!dbinstance_)return 0;
			return sqlite3_last_insert_rowid(dbinstance_.get());
		}

		//implement of epDbTrans-------------------------------------------------------------------------
		epDbTrans::epDbTrans(boost::shared_ptr<epDbImpl> impl):dbimpl_(impl)
		{
			if(!impl)throw getEpdbError(TRANS_WITHOUT_DBIMPL);
			impl->dberror_flag = false;
			impl->execDML(L"begin transaction",epDbBinder());
		}
		epDbTrans::~epDbTrans()
		{
			boost::shared_ptr<epDbImpl> tmpsp(dbimpl_);
			if(!tmpsp)throw getEpdbError(TRANS_WITHOUT_DBIMPL);
			if(tmpsp->dberror_flag)tmpsp->execDML(L"rollback transaction",epDbBinder());
			else tmpsp->execDML(L"commit transaction",epDbBinder());
		}
//implement of epDbBinder------------------------------------------------------------------------------
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, std::string value)
		{
#ifdef _WIN32
            std::wstring tmp  = txtutil::convert_utf8_to_wcs(value);
            int nRes = sqlite3_bind_text16(pstmt, nIndex, tmp.c_str(), -1, SQLITE_TRANSIENT);
#else
            int nRes = sqlite3_bind_text(pstmt, nIndex, value.c_str(), -1, SQLITE_TRANSIENT);

#endif
            if (nRes != SQLITE_OK) return false;
            return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, const char* value)
		{
#ifdef _WIN32
            std::wstring tmp  = txtutil::convert_utf8_to_wcs(value?value:"");
            int nRes = sqlite3_bind_text16(pstmt, nIndex, tmp.c_str(), -1, SQLITE_TRANSIENT);
#else
            int nRes = sqlite3_bind_text(pstmt, nIndex, value?value:"", -1, SQLITE_TRANSIENT);
#endif
            if (nRes != SQLITE_OK) return false;
            return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, char* value)
		{
#ifdef _WIN32
            std::wstring tmp  = txtutil::convert_utf8_to_wcs(value?value:"");
            int nRes = sqlite3_bind_text16(pstmt, nIndex, tmp.c_str(), -1, SQLITE_TRANSIENT);
#else
            int nRes = sqlite3_bind_text(pstmt, nIndex, value?value:"", -1, SQLITE_TRANSIENT);

#endif
            if (nRes != SQLITE_OK) return false;
            return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, std::wstring value)
		{
#ifdef _WIN32
			int nRes = sqlite3_bind_text16(pstmt, nIndex, value.c_str(), -1, SQLITE_TRANSIENT);
#else
			int nRes = sqlite3_bind_text(pstmt, nIndex, txtutil::convert_wcs_to_utf8(value).c_str(), -1, SQLITE_TRANSIENT);
#endif
			if (nRes != SQLITE_OK) return false;
			return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, const wchar_t* value)
		{

#ifdef _WIN32
			int nRes = sqlite3_bind_text16(pstmt, nIndex, value, -1, SQLITE_TRANSIENT);
#else
			std::wstring tmp(value);
			int nRes = sqlite3_bind_text(pstmt, nIndex, txtutil::convert_wcs_to_utf8(tmp).c_str(), -1, SQLITE_TRANSIENT);

#endif
			if (nRes != SQLITE_OK) return false;
			return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, wchar_t* value)
		{
#ifdef _WIN32
			int nRes = sqlite3_bind_text16(pstmt, nIndex, value, -1, SQLITE_TRANSIENT);
#else
			std::wstring tmp(value);
			int nRes = sqlite3_bind_text(pstmt, nIndex, txtutil::convert_wcs_to_utf8(tmp).c_str(), -1, SQLITE_TRANSIENT);

#endif
			if (nRes != SQLITE_OK) return false;
			return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, int value)
		{
			int nRes = sqlite3_bind_int(pstmt, nIndex, value);
			if (nRes != SQLITE_OK) return false;
			return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, double value)
		{
			int nRes = sqlite3_bind_double(pstmt, nIndex, value);
			if (nRes != SQLITE_OK) return false;
			return true;
		}
		template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, epDbBinder::blob value)
		{
			int nRes = sqlite3_bind_blob(pstmt, nIndex, value.get_ptr(), value.length(), SQLITE_TRANSIENT);
			if (nRes != SQLITE_OK) return false;
			return true;
		}
        template<> bool epDbBinder::bind_element(sqlite3_stmt* pstmt,int nIndex, boost::posix_time::ptime time)
        {
            int year = time.date().year();
            int month = time.date().month();
            int day = time.date().day();
            std::string time_str = boost::str(boost::format("%04d%02d%02d")%year%month%day);
            if(!time.time_of_day().is_special()) {
                char sep = 'T';
                time_str += sep + boost::posix_time::to_iso_string_type<char>(time.time_of_day());
            }
            return bind_element(pstmt, nIndex, time_str);
        }

		epDbBinder& epDbBinder::operator=( epius::epius_sqlite3::data_iterator it )
		{
			if(it != data_iterator() && binderImpl_)binderImpl_->takevalue(it);
			return *this;
		}

		bool epDbBinder::dobind( sqlite3_stmt* pstmt ) const
		{
			if(binderImpl_) return binderImpl_->dobind(pstmt);return true;
		}

//implement of data_iterator---------------------------------------------------------------------
		data_iterator::data_iterator(boost::shared_ptr<epDbImpl> pimpl,boost::shared_ptr<sqlite3_stmt> stmt):dbimpl_(pimpl),dbstmt_(stmt){}
		data_iterator::data_iterator(){}
		data_iterator::data_iterator(data_iterator const& dst)
		{
			dbimpl_ = dst.dbimpl_;
			dbstmt_ = dst.dbstmt_;
		}
		bool data_iterator::operator==(data_iterator const& dst){return dbstmt_ == dst.dbstmt_;}
		bool data_iterator::operator!=(data_iterator const& dst) {return !(*this == dst);}
		data_iterator& data_iterator::operator++()
		{
 			int nRet = sqlite3_step(dbstmt_.get());
			if (nRet == SQLITE_DONE)dbstmt_.reset();
			else if(nRet==SQLITE_ROW){}
			else boost::shared_ptr<epDbImpl>(dbimpl_)->inner_throw(generateEpdbError(boost::shared_ptr<epDbImpl>(dbimpl_)->dbinstance_.get()));
			return *this;
		}
		template<> void data_iterator::getField(int nCol,int& val)
		{
			val=sqlite3_column_int(dbstmt_.get(),nCol);
		}
		template<> void data_iterator::getField(int nCol,double& val)
		{
			val=sqlite3_column_double(dbstmt_.get(),nCol);
		}
		template<> void data_iterator::getField(int nCol,std::string& val)
		{
#ifdef _WIN32
            wchar_t* dbval = (wchar_t*)sqlite3_column_text16(dbstmt_.get(),nCol);
            std::wstring tmp = dbval?dbval:L"";
            val = txtutil::convert_wcs_to_utf8(tmp);
#else
	    const unsigned char* dbval = sqlite3_column_text(dbstmt_.get(),nCol);
	    
            val = dbval ? reinterpret_cast<const char*>(dbval) : reinterpret_cast<const char*>("");
#endif
		}
		template<> void data_iterator::getField(int nCol,std::wstring&val)
		{
            wchar_t* dbval = (wchar_t*)sqlite3_column_text16(dbstmt_.get(),nCol);
			val = dbval?dbval:L"";
		}
		template<> void data_iterator::getField(int nCol,epDbBinder::blob&val)
		{
			val= epDbBinder::blob(sqlite3_column_blob(dbstmt_.get(),nCol),sqlite3_column_bytes(dbstmt_.get(),nCol));
		}
        template<> void data_iterator::getField(int nCol,boost::posix_time::ptime&time)
        {
            std::string time_str;
            getField(nCol, time_str);
            time = boost::posix_time::from_iso_string(time_str);
        }

//implement of epDb------------------------------------------------------------------------------
		//epDb::epDb(std::string const&dbname):dbimpl_(new epDbImpl(dbname)){}
		epDb::epDb(std::string const&dbname, std::string const& password):dbimpl_(new epDbImpl(dbname, password)){}
		bool epDb::tableExists(std::wstring const&wtablename)
		{
			return dbimpl_->tableExist(wtablename);
		}
		int epDb::execDML(const std::wstring& sql, epDbBinder epbinder)
		{
			return dbimpl_->execDML(sql,epbinder);
		}
		data_iterator epDb::execQuery(const std::wstring& sql, epDbBinder epbinder)
		{
			return dbimpl_->execQuery(sql,epbinder);
		}
		std::wstring epDb::epDbVersion()
		{
			return L"v1.0.00build0001";
		}
		boost::shared_ptr<epDbTrans> epDb::beginTrans()
		{
			return boost::shared_ptr<epDbTrans>(new epDbTrans(dbimpl_));
		}

		void epDb::rekey( std::string new_key )
		{
			dbimpl_->rekey(new_key);
		}

		sqlite3_int64 epDb::last_insert_rowid()
		{
			return dbimpl_->last_insert_rowid();
		}

		struct epDbAutoCreate::epDbAllowChangeImpl
		{
			std::map<wstring, std::vector<wstring> > name_to_init_sql_;
			bool has_table_init_sql(wstring table_name)
			{
				return name_to_init_sql_.find(table_name)!=name_to_init_sql_.end();
			}
		};

		int epDbAutoCreate::execDML( std::wstring const& table_name, const std::wstring& sql, epDbBinder epbinder)
		{
			try{
				return epDb::execDML(sql,epbinder);
			}catch(epius_dberror const& dberr){
				if(impl_->has_table_init_sql(table_name) && dberr.get_id() == INNER_DB_ERROR)
				{
					dbimpl_->dberror_flag = false;
					std::wstring drop_sql = (boost::wformat(L"drop table if exists %s")%table_name).str();
					epDb::execDML(drop_sql);
					BOOST_FOREACH(std::wstring init_sql, impl_->name_to_init_sql_[table_name])
					{
						epDb::execDML(init_sql);
					}
					return epDb::execDML(sql, epbinder);
				}
				else
				{
					throw dberr;
				}
			}
		}

		epius::epius_sqlite3::data_iterator epDbAutoCreate::execQuery(std::wstring const& table_name, const std::wstring& sql, epDbBinder epbinder /*= epDbBinder()*/ )
		{
			try{
				return epDb::execQuery(sql,epbinder);
			}catch(epius_dberror const& dberr){
				ELOG("db")->error(WCOOL(L"sql执行出错，表将被重建，错误原因是") + dberr.what());
				if(impl_->has_table_init_sql(table_name) && dberr.get_id() == INNER_DB_ERROR)
				{
					dbimpl_->dberror_flag = false;
					std::wstring drop_sql = (boost::wformat(L"drop table if exists %s")%table_name).str();
					epDb::execDML(drop_sql);
					BOOST_FOREACH(std::wstring init_sql, impl_->name_to_init_sql_[table_name])
					{
						epDb::execDML(init_sql);
					}
				}
				return data_iterator();
			}
		}
		void epDbAutoCreate::setTableInit( std::map<std::wstring, std::vector<std::wstring> > inits )
		{
			impl_->name_to_init_sql_ = inits;
		}

		epDbAutoCreate::epDbAutoCreate( std::string const&dbname, std::string const& password):epDb(dbname,password),impl_(new epDbAllowChangeImpl)
		{
		}

		epius_dberror::epius_dberror( epius_dberror_id val, std::string const& errMsg ) :std::runtime_error(errMsg.c_str()),err_msg_(errMsg), error_id_(val)
		{

		}

		epius::epius_sqlite3::epius_dberror_id epius_dberror::get_id() const
		{
			return error_id_;
		}

		const char * epius_dberror::what() const throw()
		{
			return err_msg_.c_str();
		}

	}
}

