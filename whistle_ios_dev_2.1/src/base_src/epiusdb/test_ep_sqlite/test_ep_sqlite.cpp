// test_ep_sqlite.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <base/epiusdb/ep_sqlite.h>
#include <iostream>
#include <base/txtutil/txtutil.h>
using namespace std;

void testepdb(std::wstring db_name, std::wstring op)
{
	using namespace epius::epius_sqlite3;
	using namespace std;
	if(op==L"encode")
	{
		epDb db(txtconv::convert_wcs_to_utf8(db_name), "");
		db.rekey("whistle_2013_will_win");
	}
	else if(op==L"decode")
	{
		epDb db(txtconv::convert_wcs_to_utf8(db_name), "whistle_2013_will_win");
		db.rekey("");
	}
	else
	{
		cout<<"test_ep_sqlite db encode/decode"<<endl;
	}
}

int _tmain(int argc, _TCHAR* argv[])
{
	if(argc<3) cout<<"test_ep_sqlite db encode/decode"<<endl;
	testepdb(argv[1],argv[2]);
	return 0;
}

