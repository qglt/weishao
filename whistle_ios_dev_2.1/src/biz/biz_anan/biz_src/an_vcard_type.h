#pragma once
#include <string>

// vcard服务器端全集
static const std::string sc_nametb[] = {
	"status",    // 帐号状态, ofuser的冗余字段
	"start_time", // 帐号有效时间 , ofuser的冗余字段
	"end_time", // ofuser的冗余字段
	"create_time", // 创建时间 ofuser的冗余字段
	"identity", // 所属身份 说明：biz.vcard.teacher(老师), biz.vcard.student(学生)
	"sort_string", // 排序字符串
	"name", // 姓名
	"sex", // 性别. 说明：biz.vcard.boy(男), biz.vcard.gril(女) biz.vcard.secret(保密）
	"birthday", // 出生日期 说明：YYYY-MM-DD 
	"blood_type", // 血型 说明： 大写，不含型。例： A B AB O X(其它血型)
	"nativeplace_nation",     // 籍贯国家 说明： 
	"nativeplace_province", // 籍贯省 说明： 
	"nativeplace_city",       // 籍贯市 说明：
	"nativeplace_district",   // 籍贯地区
	"address_nation",      // 所在地国家 
	"address_province",  // 所在地省
	"address_city",         // 所在地市
	"address_district",    // 所在地区
	"address_extend",    // 所在地详细地址 
	"address_postcode",  // 所在地邮编
	"email", // 电子邮箱
	"landline", // 固定电话
	"cellphone", // 移动电话
	"student_number", // 学号
	"id_card_number", // 身份证号码
	"nick_name", // 昵称
	"photo_live", 
	"photo_credential",
	"mood_words", // 心情短语
	"weblog", // 微博地址
	"home_page", // 个人主页
	"hobby", // 爱好
	"information", // 个人说明
	"title", // 职务
	"last_volatile_time", // 最近更新时间
	"last_base_time", // 最近更新时间
	"last_extend_time", // 最近更新时间
	"language",// 语言
	"vcard_privacy",// 隐私设置
	"modificationdate",
	""
};

// 可以通过界面修改的个人信息字段
static const std::string sc_store_name[] = {
	"nick_name", // 昵称
	"landline", // 固定电话
	"cellphone", // 移动电话
	"email", // 电子邮箱
	"weblog", // 微博地址
	"mood_words", // 心情短语
	"blood_type", // 血型 说明： 大写，不含型。例： A B AB O X(其它血型)
	"address_extend",    // 所在地详细地址 
	"address_postcode",  // 所在地邮编
	"hobby", // 爱好
	"home_page", // 个人主页
	"information", // 个人说明
	"vcard_privacy",// 隐私设置
	"photo_credential",
	"photo_live",
	"birthday", // 出生日期 说明：YYYY-MM-DD 
	"blood_type", // 血型 说明： 大写，不含型。例： A B AB O X(其它血型)
	"nativeplace_nation",     // 籍贯国家 说明： 
	"nativeplace_province", // 籍贯省 说明： 
	"nativeplace_city",       // 籍贯市 说明：
	"nativeplace_district",   // 籍贯地区
	"student_number",
	""
};

// vcard服务器端的基本资料子集
static const std::string sc_basenametb[] = {
	"name", // 姓名
	"sex", // 性别. 说明：biz.vcard.boy(男), biz.vcard.gril(女) biz.vcard.secret(保密）
	"identity", // 所属身份 说明：biz.vcard.teacher(老师), biz.vcard.student(学生)
	"nick_name", // 昵称
	"photo_live", 
	"photo_credential",
	"mood_words", // 心情短语
	"hobby", // 爱好
	"modificationdate",
	"birthday",
	"student_number",
	""
};