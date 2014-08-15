//
//  OtherManager.h
//  WhistleIm
//
//  Created by liuke on 13-12-18.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "Manager.h"

@interface OtherManager : Manager

SINGLETON_DEFINE(OtherManager)

- (void) getFeedback:(NSString *)content WithEmotion:(NSString*)emotion withCallback:(void (^)(NSString *))callback;

/**
 *  上传图片
 *
 *  @param path     图片路径
 *  @param left     截取图片左
 *  @param right    截取图片右
 *  @param top      截取图片上
 *  @param bottom   截取图片下
 *  @param callback 参数分别为：是否上传成功、uri、理由、上传后的本地图片路径
 */
- (void) doUploadImage:(NSString *)path crop_left:(NSUInteger)left crop_right:(NSUInteger)right crop_top:(NSUInteger)top crop_bottom:(NSUInteger)bottom
              callback:(void(^)(BOOL isSuccess, NSString* uri, NSString* reason, NSString* localImg))callback;
@end
