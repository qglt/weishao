//
//  CampusActivityTypeChooser.m
//  WhistleIm
//
//  Created by liming on 14-3-6.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusActivityTypeChooser.h"
#import "CampusActivityTypeCell.h"
#import "Constants.h"

#define kChooseCellReuseId  @"CampusActivityType"
#define CHOOSERHEIGHT   (44*6)
#define CHOOSERSHOWN    (CHOOSERHEIGHT)

@interface CampusActivityTypeChooser() <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSArray *items;
@property (nonatomic,strong) NSArray *itemImages;

@property (nonatomic,strong) UIView *container;
@property (nonatomic,strong) UIView *cover;

@property (nonatomic,strong) UICollectionView *chooserView;

@property (nonatomic,assign) id<CampusActivityTypeChooserDelegate> delegate;

@end

@implementation CampusActivityTypeChooser

-(id)init
{
    self = [super init];
    if(self){
        self.items = [[NSArray alloc] initWithObjects:
                      @"全部类型",@"campacttype_all.png",
                      @"与我相关",@"campacttype_mine.png",
                      @"学习交流",@"campacttype_exchangeculture.png",
                      @"培训讲座",@"campacttype_training.png",
                      @"课外实践",@"campacttype_practise.png",
                      @"招聘求职",@"campacttype_jobs.png",
                      @"文化联谊",@"campacttype_friendship.png",
                      @"体育活动",@"campacttype_sports.png",
                      @"聚会玩乐",@"campacttype_play.png",
                      @"展览展会",@"campacttype_exh.png",
                      @"社团活动",@"campacttype_community.png",
                      @"其他活动",@"campacttype_others.png",
                      
                      nil];
        self.itemImages = [[NSArray alloc] initWithObjects:
                           @"campacttype_alldock.png",@"campacttype_alldock_pressed.png",
                           @"campacttype_minedock.png",@"campacttype_minedock_pressed.png",
                           @"campacttype_exchangeculturedock.png",@"campacttype_exchangeculturedock_pressed.png",
                           @"campacttype_trainingdock.png",@"campacttype_trainingdock_pressed.png",
                           @"campacttype_practisedock.png",@"campacttype_practisedock_pressed.png",
                           @"campacttype_jobsdock.png",@"campacttype_jobsdock_pressed.png",
                           @"campacttype_friendshipdock.png",@"campacttype_friendshipdock_pressed.png",
                           @"campacttype_sportsdock.png",@"campacttype_sportsdock_pressed.png",
                           @"campacttype_playdock.png",@"campacttype_playdock_pressed.png",
                           @"campacttype_exhdock.png",@"campacttype_exhdock_pressed.png",
                           @"campacttype_communitydock.png",@"campacttype_communitydock_pressed.png",
                           @"campacttype_othersdock.png",@"campacttype_othersdock_pressed.png",
                           nil];
        CGRect rect = [UIScreen mainScreen].bounds;
        self.container = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + MAPTOPBARHEIGHT + 0.5, rect.size.width, rect.size.height - MAPTOOLBARHEIGHT - MAPTOPBARHEIGHT - 0.5)];
        self.container.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55f];
        self.container.userInteractionEnabled = YES;
        self.cover = [[UIView alloc] initWithFrame:self.container.frame];
        UITapGestureRecognizer *cancelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel:)];
        cancelGesture.numberOfTapsRequired = 1;
        //cancelGesture.delegate = self;
        [self.cover addGestureRecognizer:cancelGesture];
        [self.container addSubview:self.cover];
        
        self.chooserView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, - CHOOSERHEIGHT, rect.size.width, CHOOSERHEIGHT) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
       // self.chooserView.layer.borderColor = [UIColor redColor].CGColor;
       // self.chooserView.layer.borderWidth = 1.0f;
        self.chooserView.backgroundColor = [UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0];
        self.chooserView.dataSource = self;
        self.chooserView.delegate = self;
        [self.chooserView registerClass:[CampusActivityTypeCell class] forCellWithReuseIdentifier:kChooseCellReuseId];
        [self.container addSubview:self.chooserView];
        
    }
    
    return self;
}

-(id)initWithDelegate:(id<CampusActivityTypeChooserDelegate>)delegate
{
    self = [self init];
    self.delegate = delegate;
    return self;
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if([touch.view isKindOfClass:[UICollectionView class]] || [touch.view isKindOfClass:[UICollectionViewCell class]]){
        return NO;
    }
    return YES;
}

#pragma mark - UIGesture
-(void)onCancel:(id)sender
{
    [self.delegate onTypeSelected:-1 withText:nil withNormalImageName:nil withHighlightImageName:nil];
    
}

#pragma mark - CollectionView delegates

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CampusActivityTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChooseCellReuseId forIndexPath:indexPath];
    cell.typeNameLabel.text = [self.items objectAtIndex:indexPath.row *2];
    [cell.typeIcon setImage:[UIImage imageNamed:[self.items objectAtIndex:(indexPath.row *2 + 1)]]];
    //cell.layer.borderWidth = 2.0f;
    //cell.layer.borderColor = [UIColor redColor].CGColor;
    //cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate onTypeSelected:indexPath.row withText:[self.items objectAtIndex:indexPath.row *2] withNormalImageName:[self.itemImages objectAtIndex:indexPath.row *2] withHighlightImageName:[self.itemImages objectAtIndex:indexPath.row *2 + 1]];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width/2- (indexPath.row % 2 == 0 ? 0.5 : 0), 43.5);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.5f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.5f;
}

#pragma mark - UI methods

-(void)toggleChooser:(BOOL)flag withCallback:(void (^)())callback
{
    CGRect frame = self.chooserView.frame;
    if(flag){
        self.cover.frame = CGRectMake(0, CHOOSERSHOWN, self.cover.frame.size.width, self.cover.frame.size.height);
        self.chooserView.frame = CGRectMake(frame.origin.x, 0.5, frame.size.width, frame.size.height);
    }else{
        self.cover.frame = CGRectMake(0,0, self.cover.frame.size.width, self.cover.frame.size.height);
        self.chooserView.frame = CGRectMake(frame.origin.x,0 - CHOOSERSHOWN, frame.size.width, frame.size.height);
        
    }
    
    callback();
}
-(void)showChooser:(void (^)())callback
{
    [self toggleChooser:YES withCallback:callback];
    
}

-(void)hideChooser:(void (^)())callback
{
    [self toggleChooser:NO withCallback:callback];
    
}

#pragma mark - GenericController methods

-(UIView *)getView
{
    return self.container;
}

-(void)bindView
{
    
}

-(void)destroy
{
    self.items = nil;
    [self.container removeFromSuperview];
    self.chooserView = nil;
    self.delegate = nil;
}
@end
