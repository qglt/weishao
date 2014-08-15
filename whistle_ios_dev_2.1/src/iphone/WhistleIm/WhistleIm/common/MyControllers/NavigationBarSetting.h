//
//  NavigationBarSetting.h
//  MyWhistle
//
//  Created by lizuoying on 13-11-30.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationBarSetting : NSObject
{
    NSString * m_frame;
    NSString * m_normalImage;
    NSString * m_selectedImage;
    NSString * m_btnType;
    NSString * m_buttonSide;
}

@property (nonatomic, strong) NSString * m_frame;
@property (nonatomic, strong) NSString * m_normalImage;
@property (nonatomic, strong) NSString * m_selectedImage;
@property (nonatomic, strong) NSString * m_btnType;
@property (nonatomic, strong) NSString * m_buttonSide;



@end
