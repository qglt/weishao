#define MAX_MEMBER_NUMBER 50

#define MAX_MEMBER_NUMBER_DEC_1 	 49
#define MAX_MEMBER_NUMBER_DEC_2 	 48
#define MAX_MEMBER_NUMBER_DEC_3 	 47
#define MAX_MEMBER_NUMBER_DEC_4 	 46
#define MAX_MEMBER_NUMBER_DEC_5 	 45
#define MAX_MEMBER_NUMBER_DEC_6 	 44
#define MAX_MEMBER_NUMBER_DEC_7 	 43
#define MAX_MEMBER_NUMBER_DEC_8 	 42
#define MAX_MEMBER_NUMBER_DEC_9 	 41
#define MAX_MEMBER_NUMBER_DEC_10 	 40
#define MAX_MEMBER_NUMBER_DEC_11 	 39
#define MAX_MEMBER_NUMBER_DEC_12 	 38
#define MAX_MEMBER_NUMBER_DEC_13 	 37
#define MAX_MEMBER_NUMBER_DEC_14 	 36
#define MAX_MEMBER_NUMBER_DEC_15 	 35
#define MAX_MEMBER_NUMBER_DEC_16 	 34
#define MAX_MEMBER_NUMBER_DEC_17 	 33
#define MAX_MEMBER_NUMBER_DEC_18 	 32
#define MAX_MEMBER_NUMBER_DEC_19 	 31
#define MAX_MEMBER_NUMBER_DEC_20 	 30
#define MAX_MEMBER_NUMBER_DEC_21 	 29
#define MAX_MEMBER_NUMBER_DEC_22 	 28
#define MAX_MEMBER_NUMBER_DEC_23 	 27
#define MAX_MEMBER_NUMBER_DEC_24 	 26
#define MAX_MEMBER_NUMBER_DEC_25 	 25
#define MAX_MEMBER_NUMBER_DEC_26 	 24
#define MAX_MEMBER_NUMBER_DEC_27 	 23
#define MAX_MEMBER_NUMBER_DEC_28 	 22
#define MAX_MEMBER_NUMBER_DEC_29 	 21
#define MAX_MEMBER_NUMBER_DEC_30 	 20
#define MAX_MEMBER_NUMBER_DEC_31 	 19
#define MAX_MEMBER_NUMBER_DEC_32 	 18
#define MAX_MEMBER_NUMBER_DEC_33 	 17
#define MAX_MEMBER_NUMBER_DEC_34 	 16
#define MAX_MEMBER_NUMBER_DEC_35 	 15
#define MAX_MEMBER_NUMBER_DEC_36 	 14
#define MAX_MEMBER_NUMBER_DEC_37 	 13
#define MAX_MEMBER_NUMBER_DEC_38 	 12
#define MAX_MEMBER_NUMBER_DEC_39 	 11
#define MAX_MEMBER_NUMBER_DEC_40 	 10
#define MAX_MEMBER_NUMBER_DEC_41 	 9
#define MAX_MEMBER_NUMBER_DEC_42 	 8
#define MAX_MEMBER_NUMBER_DEC_43 	 7
#define MAX_MEMBER_NUMBER_DEC_44 	 6
#define MAX_MEMBER_NUMBER_DEC_45 	 5
#define MAX_MEMBER_NUMBER_DEC_46 	 4
#define MAX_MEMBER_NUMBER_DEC_47 	 3
#define MAX_MEMBER_NUMBER_DEC_48 	 2
#define MAX_MEMBER_NUMBER_DEC_49 	 1
#define MAX_MEMBER_NUMBER_DEC_50 	 0

#define TBIND_1(p,pad,...) p(__VA_ARGS__,1)
#define TBIND_2(p,pad,x,...)  p(x,2) EXPAND(PAD_##pad) EXPAND(TBIND_1(p,pad,__VA_ARGS__))
#define TBIND_3(p,pad,x,...)  p(x,3) EXPAND(PAD_##pad) EXPAND(TBIND_2(p,pad,__VA_ARGS__))
#define TBIND_4(p,pad,x,...)  p(x,4) EXPAND(PAD_##pad) EXPAND(TBIND_3(p,pad,__VA_ARGS__))
#define TBIND_5(p,pad,x,...)  p(x,5) EXPAND(PAD_##pad) EXPAND(TBIND_4(p,pad,__VA_ARGS__))
#define TBIND_6(p,pad,x,...)  p(x,6) EXPAND(PAD_##pad) EXPAND(TBIND_5(p,pad,__VA_ARGS__))
#define TBIND_7(p,pad,x,...)  p(x,7) EXPAND(PAD_##pad) EXPAND(TBIND_6(p,pad,__VA_ARGS__))
#define TBIND_8(p,pad,x,...)  p(x,8) EXPAND(PAD_##pad) EXPAND(TBIND_7(p,pad,__VA_ARGS__))
#define TBIND_9(p,pad,x,...)  p(x,9) EXPAND(PAD_##pad) EXPAND(TBIND_8(p,pad,__VA_ARGS__))
#define TBIND_10(p,pad,x,...)  p(x,10) EXPAND(PAD_##pad) EXPAND(TBIND_9(p,pad,__VA_ARGS__))
#define TBIND_11(p,pad,x,...)  p(x,11) EXPAND(PAD_##pad) EXPAND(TBIND_10(p,pad,__VA_ARGS__))
#define TBIND_12(p,pad,x,...)  p(x,12) EXPAND(PAD_##pad) EXPAND(TBIND_11(p,pad,__VA_ARGS__))
#define TBIND_13(p,pad,x,...)  p(x,13) EXPAND(PAD_##pad) EXPAND(TBIND_12(p,pad,__VA_ARGS__))
#define TBIND_14(p,pad,x,...)  p(x,14) EXPAND(PAD_##pad) EXPAND(TBIND_13(p,pad,__VA_ARGS__))
#define TBIND_15(p,pad,x,...)  p(x,15) EXPAND(PAD_##pad) EXPAND(TBIND_14(p,pad,__VA_ARGS__))
#define TBIND_16(p,pad,x,...)  p(x,16) EXPAND(PAD_##pad) EXPAND(TBIND_15(p,pad,__VA_ARGS__))
#define TBIND_17(p,pad,x,...)  p(x,17) EXPAND(PAD_##pad) EXPAND(TBIND_16(p,pad,__VA_ARGS__))
#define TBIND_18(p,pad,x,...)  p(x,18) EXPAND(PAD_##pad) EXPAND(TBIND_17(p,pad,__VA_ARGS__))
#define TBIND_19(p,pad,x,...)  p(x,19) EXPAND(PAD_##pad) EXPAND(TBIND_18(p,pad,__VA_ARGS__))
#define TBIND_20(p,pad,x,...)  p(x,20) EXPAND(PAD_##pad) EXPAND(TBIND_19(p,pad,__VA_ARGS__))
#define TBIND_21(p,pad,x,...)  p(x,21) EXPAND(PAD_##pad) EXPAND(TBIND_20(p,pad,__VA_ARGS__))
#define TBIND_22(p,pad,x,...)  p(x,22) EXPAND(PAD_##pad) EXPAND(TBIND_21(p,pad,__VA_ARGS__))
#define TBIND_23(p,pad,x,...)  p(x,23) EXPAND(PAD_##pad) EXPAND(TBIND_22(p,pad,__VA_ARGS__))
#define TBIND_24(p,pad,x,...)  p(x,24) EXPAND(PAD_##pad) EXPAND(TBIND_23(p,pad,__VA_ARGS__))
#define TBIND_25(p,pad,x,...)  p(x,25) EXPAND(PAD_##pad) EXPAND(TBIND_24(p,pad,__VA_ARGS__))
#define TBIND_26(p,pad,x,...)  p(x,26) EXPAND(PAD_##pad) EXPAND(TBIND_25(p,pad,__VA_ARGS__))
#define TBIND_27(p,pad,x,...)  p(x,27) EXPAND(PAD_##pad) EXPAND(TBIND_26(p,pad,__VA_ARGS__))
#define TBIND_28(p,pad,x,...)  p(x,28) EXPAND(PAD_##pad) EXPAND(TBIND_27(p,pad,__VA_ARGS__))
#define TBIND_29(p,pad,x,...)  p(x,29) EXPAND(PAD_##pad) EXPAND(TBIND_28(p,pad,__VA_ARGS__))
#define TBIND_30(p,pad,x,...)  p(x,30) EXPAND(PAD_##pad) EXPAND(TBIND_29(p,pad,__VA_ARGS__))
#define TBIND_31(p,pad,x,...)  p(x,31) EXPAND(PAD_##pad) EXPAND(TBIND_30(p,pad,__VA_ARGS__))
#define TBIND_32(p,pad,x,...)  p(x,32) EXPAND(PAD_##pad) EXPAND(TBIND_31(p,pad,__VA_ARGS__))
#define TBIND_33(p,pad,x,...)  p(x,33) EXPAND(PAD_##pad) EXPAND(TBIND_32(p,pad,__VA_ARGS__))
#define TBIND_34(p,pad,x,...)  p(x,34) EXPAND(PAD_##pad) EXPAND(TBIND_33(p,pad,__VA_ARGS__))
#define TBIND_35(p,pad,x,...)  p(x,35) EXPAND(PAD_##pad) EXPAND(TBIND_34(p,pad,__VA_ARGS__))
#define TBIND_36(p,pad,x,...)  p(x,36) EXPAND(PAD_##pad) EXPAND(TBIND_35(p,pad,__VA_ARGS__))
#define TBIND_37(p,pad,x,...)  p(x,37) EXPAND(PAD_##pad) EXPAND(TBIND_36(p,pad,__VA_ARGS__))
#define TBIND_38(p,pad,x,...)  p(x,38) EXPAND(PAD_##pad) EXPAND(TBIND_37(p,pad,__VA_ARGS__))
#define TBIND_39(p,pad,x,...)  p(x,39) EXPAND(PAD_##pad) EXPAND(TBIND_38(p,pad,__VA_ARGS__))
#define TBIND_40(p,pad,x,...)  p(x,40) EXPAND(PAD_##pad) EXPAND(TBIND_39(p,pad,__VA_ARGS__))
#define TBIND_41(p,pad,x,...)  p(x,41) EXPAND(PAD_##pad) EXPAND(TBIND_40(p,pad,__VA_ARGS__))
#define TBIND_42(p,pad,x,...)  p(x,42) EXPAND(PAD_##pad) EXPAND(TBIND_41(p,pad,__VA_ARGS__))
#define TBIND_43(p,pad,x,...)  p(x,43) EXPAND(PAD_##pad) EXPAND(TBIND_42(p,pad,__VA_ARGS__))
#define TBIND_44(p,pad,x,...)  p(x,44) EXPAND(PAD_##pad) EXPAND(TBIND_43(p,pad,__VA_ARGS__))
#define TBIND_45(p,pad,x,...)  p(x,45) EXPAND(PAD_##pad) EXPAND(TBIND_44(p,pad,__VA_ARGS__))
#define TBIND_46(p,pad,x,...)  p(x,46) EXPAND(PAD_##pad) EXPAND(TBIND_45(p,pad,__VA_ARGS__))
#define TBIND_47(p,pad,x,...)  p(x,47) EXPAND(PAD_##pad) EXPAND(TBIND_46(p,pad,__VA_ARGS__))
#define TBIND_48(p,pad,x,...)  p(x,48) EXPAND(PAD_##pad) EXPAND(TBIND_47(p,pad,__VA_ARGS__))
#define TBIND_49(p,pad,x,...)  p(x,49) EXPAND(PAD_##pad) EXPAND(TBIND_48(p,pad,__VA_ARGS__))
#define TBIND_50(p,pad,x,...)  p(x,50) EXPAND(PAD_##pad) EXPAND(TBIND_49(p,pad,__VA_ARGS__))

#define TBIND(n,pad,opt,...) EXPAND(TBIND_##n(opt,pad,__VA_ARGS__))

#define RBIND_1(p,pad,x) p(x,1)
#define RBIND_2(p,pad,x,...)  EXPAND(RBIND_1(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,2)
#define RBIND_3(p,pad,x,...)  EXPAND(RBIND_2(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,3)
#define RBIND_4(p,pad,x,...)  EXPAND(RBIND_3(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,4)
#define RBIND_5(p,pad,x,...)  EXPAND(RBIND_4(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,5)
#define RBIND_6(p,pad,x,...)  EXPAND(RBIND_5(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,6)
#define RBIND_7(p,pad,x,...)  EXPAND(RBIND_6(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,7)
#define RBIND_8(p,pad,x,...)  EXPAND(RBIND_7(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,8)
#define RBIND_9(p,pad,x,...)  EXPAND(RBIND_8(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,9)
#define RBIND_10(p,pad,x,...)  EXPAND(RBIND_9(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,10)
#define RBIND_11(p,pad,x,...)  EXPAND(RBIND_10(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,11)
#define RBIND_12(p,pad,x,...)  EXPAND(RBIND_11(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,12)
#define RBIND_13(p,pad,x,...)  EXPAND(RBIND_12(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,13)
#define RBIND_14(p,pad,x,...)  EXPAND(RBIND_13(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,14)
#define RBIND_15(p,pad,x,...)  EXPAND(RBIND_14(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,15)
#define RBIND_16(p,pad,x,...)  EXPAND(RBIND_15(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,16)
#define RBIND_17(p,pad,x,...)  EXPAND(RBIND_16(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,17)
#define RBIND_18(p,pad,x,...)  EXPAND(RBIND_17(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,18)
#define RBIND_19(p,pad,x,...)  EXPAND(RBIND_18(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,19)
#define RBIND_20(p,pad,x,...)  EXPAND(RBIND_19(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,20)
#define RBIND_21(p,pad,x,...)  EXPAND(RBIND_20(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,21)
#define RBIND_22(p,pad,x,...)  EXPAND(RBIND_21(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,22)
#define RBIND_23(p,pad,x,...)  EXPAND(RBIND_22(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,23)
#define RBIND_24(p,pad,x,...)  EXPAND(RBIND_23(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,24)
#define RBIND_25(p,pad,x,...)  EXPAND(RBIND_24(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,25)
#define RBIND_26(p,pad,x,...)  EXPAND(RBIND_25(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,26)
#define RBIND_27(p,pad,x,...)  EXPAND(RBIND_26(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,27)
#define RBIND_28(p,pad,x,...)  EXPAND(RBIND_27(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,28)
#define RBIND_29(p,pad,x,...)  EXPAND(RBIND_28(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,29)
#define RBIND_30(p,pad,x,...)  EXPAND(RBIND_29(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,30)
#define RBIND_31(p,pad,x,...)  EXPAND(RBIND_30(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,31)
#define RBIND_32(p,pad,x,...)  EXPAND(RBIND_31(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,32)
#define RBIND_33(p,pad,x,...)  EXPAND(RBIND_32(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,33)
#define RBIND_34(p,pad,x,...)  EXPAND(RBIND_33(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,34)
#define RBIND_35(p,pad,x,...)  EXPAND(RBIND_34(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,35)
#define RBIND_36(p,pad,x,...)  EXPAND(RBIND_35(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,36)
#define RBIND_37(p,pad,x,...)  EXPAND(RBIND_36(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,37)
#define RBIND_38(p,pad,x,...)  EXPAND(RBIND_37(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,38)
#define RBIND_39(p,pad,x,...)  EXPAND(RBIND_38(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,39)
#define RBIND_40(p,pad,x,...)  EXPAND(RBIND_39(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,40)
#define RBIND_41(p,pad,x,...)  EXPAND(RBIND_40(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,41)
#define RBIND_42(p,pad,x,...)  EXPAND(RBIND_41(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,42)
#define RBIND_43(p,pad,x,...)  EXPAND(RBIND_42(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,43)
#define RBIND_44(p,pad,x,...)  EXPAND(RBIND_43(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,44)
#define RBIND_45(p,pad,x,...)  EXPAND(RBIND_44(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,45)
#define RBIND_46(p,pad,x,...)  EXPAND(RBIND_45(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,46)
#define RBIND_47(p,pad,x,...)  EXPAND(RBIND_46(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,47)
#define RBIND_48(p,pad,x,...)  EXPAND(RBIND_47(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,48)
#define RBIND_49(p,pad,x,...)  EXPAND(RBIND_48(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,49)
#define RBIND_50(p,pad,x,...)  EXPAND(RBIND_49(p,pad,__VA_ARGS__))  EXPAND(PAD_##pad) p(x,50)

#define RBIND(n,pad,opt,...) EXPAND(RBIND_##n(opt,pad,__VA_ARGS__))

#define RBIND2BG_2(p,pad,x,...)  p(x,2)
#define RBIND2BG_3(p,pad,x,...)  EXPAND(RBIND2BG_2(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,3)
#define RBIND2BG_4(p,pad,x,...)  EXPAND(RBIND2BG_3(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,4)
#define RBIND2BG_5(p,pad,x,...)  EXPAND(RBIND2BG_4(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,5)
#define RBIND2BG_6(p,pad,x,...)  EXPAND(RBIND2BG_5(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,6)
#define RBIND2BG_7(p,pad,x,...)  EXPAND(RBIND2BG_6(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,7)
#define RBIND2BG_8(p,pad,x,...)  EXPAND(RBIND2BG_7(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,8)
#define RBIND2BG_9(p,pad,x,...)  EXPAND(RBIND2BG_8(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,9)
#define RBIND2BG_10(p,pad,x,...)  EXPAND(RBIND2BG_9(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,10)
#define RBIND2BG_11(p,pad,x,...)  EXPAND(RBIND2BG_10(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,11)
#define RBIND2BG_12(p,pad,x,...)  EXPAND(RBIND2BG_11(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,12)
#define RBIND2BG_13(p,pad,x,...)  EXPAND(RBIND2BG_12(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,13)
#define RBIND2BG_14(p,pad,x,...)  EXPAND(RBIND2BG_13(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,14)
#define RBIND2BG_15(p,pad,x,...)  EXPAND(RBIND2BG_14(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,15)
#define RBIND2BG_16(p,pad,x,...)  EXPAND(RBIND2BG_15(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,16)
#define RBIND2BG_17(p,pad,x,...)  EXPAND(RBIND2BG_16(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,17)
#define RBIND2BG_18(p,pad,x,...)  EXPAND(RBIND2BG_17(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,18)
#define RBIND2BG_19(p,pad,x,...)  EXPAND(RBIND2BG_18(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,19)
#define RBIND2BG_20(p,pad,x,...)  EXPAND(RBIND2BG_19(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,20)
#define RBIND2BG_21(p,pad,x,...)  EXPAND(RBIND2BG_20(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,21)
#define RBIND2BG_22(p,pad,x,...)  EXPAND(RBIND2BG_21(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,22)
#define RBIND2BG_23(p,pad,x,...)  EXPAND(RBIND2BG_22(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,23)
#define RBIND2BG_24(p,pad,x,...)  EXPAND(RBIND2BG_23(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,24)
#define RBIND2BG_25(p,pad,x,...)  EXPAND(RBIND2BG_24(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,25)
#define RBIND2BG_26(p,pad,x,...)  EXPAND(RBIND2BG_25(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,26)
#define RBIND2BG_27(p,pad,x,...)  EXPAND(RBIND2BG_26(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,27)
#define RBIND2BG_28(p,pad,x,...)  EXPAND(RBIND2BG_27(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,28)
#define RBIND2BG_29(p,pad,x,...)  EXPAND(RBIND2BG_28(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,29)
#define RBIND2BG_30(p,pad,x,...)  EXPAND(RBIND2BG_29(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,30)
#define RBIND2BG_31(p,pad,x,...)  EXPAND(RBIND2BG_30(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,31)
#define RBIND2BG_32(p,pad,x,...)  EXPAND(RBIND2BG_31(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,32)
#define RBIND2BG_33(p,pad,x,...)  EXPAND(RBIND2BG_32(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,33)
#define RBIND2BG_34(p,pad,x,...)  EXPAND(RBIND2BG_33(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,34)
#define RBIND2BG_35(p,pad,x,...)  EXPAND(RBIND2BG_34(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,35)
#define RBIND2BG_36(p,pad,x,...)  EXPAND(RBIND2BG_35(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,36)
#define RBIND2BG_37(p,pad,x,...)  EXPAND(RBIND2BG_36(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,37)
#define RBIND2BG_38(p,pad,x,...)  EXPAND(RBIND2BG_37(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,38)
#define RBIND2BG_39(p,pad,x,...)  EXPAND(RBIND2BG_38(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,39)
#define RBIND2BG_40(p,pad,x,...)  EXPAND(RBIND2BG_39(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,40)
#define RBIND2BG_41(p,pad,x,...)  EXPAND(RBIND2BG_40(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,41)
#define RBIND2BG_42(p,pad,x,...)  EXPAND(RBIND2BG_41(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,42)
#define RBIND2BG_43(p,pad,x,...)  EXPAND(RBIND2BG_42(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,43)
#define RBIND2BG_44(p,pad,x,...)  EXPAND(RBIND2BG_43(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,44)
#define RBIND2BG_45(p,pad,x,...)  EXPAND(RBIND2BG_44(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,45)
#define RBIND2BG_46(p,pad,x,...)  EXPAND(RBIND2BG_45(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,46)
#define RBIND2BG_47(p,pad,x,...)  EXPAND(RBIND2BG_46(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,47)
#define RBIND2BG_48(p,pad,x,...)  EXPAND(RBIND2BG_47(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,48)
#define RBIND2BG_49(p,pad,x,...)  EXPAND(RBIND2BG_48(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,49)
#define RBIND2BG_50(p,pad,x,...)  EXPAND(RBIND2BG_49(p,pad,__VA_ARGS__)) EXPAND(PAD_##pad) p(x,50)

#define RBIND2BG(n,pad,opt,...) EXPAND(RBIND2BG_##n(opt,pad,__VA_ARGS__))

