#pragma once

namespace biz {

	struct ConvDate
	{
		int Source;
		int SolarYear;
		int SolarMonth;
		int SolarDay;
		int LunarYear;
		int LunarMonth;
		int LunarDate;
		int Weekday;
		int Kan;
		int Chih;
	};

	/* 求此西曆年是否爲閏年, 返回 0 爲平年, 1 爲閏年 */
	int GetLeap( int year );

	/* 西曆農曆轉換 */
	int CalConv( struct ConvDate *cd );

}; // namespace biz
