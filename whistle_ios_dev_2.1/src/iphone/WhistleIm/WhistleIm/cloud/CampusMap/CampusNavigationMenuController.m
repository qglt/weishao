//
//  CampusNavigationMenuController.m
//  WhistleIm
//
//  Created by liming on 14-3-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusNavigationMenuController.h"
#import "Constants.h"

#define MENU_HEIGHT (40 *3)

@interface CampusNavigationMenuController() <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSArray *menuItems;

@property (nonatomic,strong) UIView *container;

@property (nonatomic,strong) UIView *cover;

@property (nonatomic,strong) UICollectionView *chooserView;

@property (nonatomic,assign) id<CampusNavigationDelegate> delegate;

@end

@implementation CampusNavigationMenuController

-(id)init
{
    self = [super init];
    if(self){
        self.menuItems = [[NSArray alloc] initWithObjects:@"活动",@"优惠",@"退出微时空", nil];
        CGRect rect = [UIScreen mainScreen].bounds;
        self.container = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + MAPTOPBARHEIGHT, rect.size.width, rect.size.height - MAPTOOLBARHEIGHT - MAPTOPBARHEIGHT)];
        self.container.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55f];
        self.container.userInteractionEnabled = YES;
        
        self.cover = [[UIView alloc] initWithFrame:self.container.frame];
        UITapGestureRecognizer *cancelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel:)];
        cancelGesture.numberOfTapsRequired = 1;
        //cancelGesture.delegate = self;
        [self.cover addGestureRecognizer:cancelGesture];
        [self.container addSubview:self.cover];
        self.chooserView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0-MENU_HEIGHT, rect.size.width, MENU_HEIGHT) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        
        self.chooserView.backgroundColor = [UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0];
        self.chooserView.dataSource = self;
        self.chooserView.delegate = self;
        //[self.chooserView registerClass:[CampusActivityTypeCell class] forCellWithReuseIdentifier:kChooseCellReuseId];
        [self.container addSubview:self.chooserView];
        
    }

    return self;
}

-(id)initWithCampusNavigationDelegate:(id<CampusNavigationDelegate>)delegate
{
    self =  [self init];
    if(self){
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - UIGesture
-(void)onCancel:(id)sender
{
    [self.delegate onItemSelected:MenuItem_Cancel];
}

#pragma mark - UI Method
-(void)toggleMenu:(BOOL)flag withCallback:(void (^)())callback
{
    CGRect frame = self.chooserView.frame;
    if(flag){
        self.cover.frame = CGRectMake(0, MENU_HEIGHT, self.cover.frame.size.width, self.cover.frame.size.height);
        self.chooserView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);
    }else{
        self.cover.frame = CGRectMake(0,0, self.cover.frame.size.width, self.cover.frame.size.height);
        self.chooserView.frame = CGRectMake(frame.origin.x,0 - MENU_HEIGHT, frame.size.width, frame.size.height);
        
    }
    
    callback();
   
}

-(void)showMenu:(void (^)())callback
{
    [self toggleMenu:YES withCallback:callback];
}

-(void)hideMenu:(void (^)())callback
{
    [self toggleMenu:NO withCallback:callback];
}

#pragma mark - GenericController methods

-(UIView *)getView
{
    return self.container;
}

-(void)destroy
{
    self.delegate = nil;
}

@end
