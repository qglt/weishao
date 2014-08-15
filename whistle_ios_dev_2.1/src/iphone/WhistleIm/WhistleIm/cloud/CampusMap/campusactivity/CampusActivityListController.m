//
//  CampusActivityEntryController.m
//  WhistleIm
//
//  Created by liming on 14-2-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusActivityListController.h"
#import "CampusActivityCell.h"
#import "CloudAccountManager.h"
#import "ClouldActivityManager.h"
#import "JSONObjectHelper.h"

#define kReuseId    @"CampusActivityListEntryView"

@interface CampusActivityListController()<CampusActivityCellDelegate>

@property (nonatomic,strong) NSMutableArray *activies;

@property (nonatomic,strong) UITableView *activiesList;

@property (nonatomic,assign) id<CampusActivityListDelegate> delegate;

@end

@implementation CampusActivityListController
@synthesize pushDalegate;

-(id)init
{
    self = [super init];
    if(self){
        self.activies = [[NSMutableArray alloc] init];
        self.activiesList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.activiesList.dataSource = self;
        self.activiesList.delegate = self;
        [self.activiesList registerNib:[UINib nibWithNibName:@"CampusActivityListEntryView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kReuseId];
    }
    return self;
}
-(id)initWithCampusActivityListDelegate:(id<CampusActivityListDelegate>)delegate
{
    self = [self init];
    if(self){
        self.delegate = delegate;
    }
    
    return self;
}

-(UIView *)getView
{
    return self.activiesList;
}

-(void)bindView
{
    [[ClouldActivityManager shareInstance] addActivityListListener:self];
    //[self.activiesList setContentSize:self.activiesList.frame.size];
    //[self.activiesList setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
    self.activiesList.contentOffset = CGPointZero;
    //[self.activiesList set]
    //[self loadData];
}

-(void)unbindView
{
    [self.activies removeAllObjects];
}

-(void)destroy
{
    self.activiesList = nil;
    
    [self.activies removeAllObjects];
    self.activies = nil;
    self.delegate = nil;
}

-(void)onActivityListRefreshed:(NSArray *)newList forPage:(int)page
{
    [self.activies removeAllObjects];
    [self.activies addObjectsFromArray:newList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activiesList reloadData];
        //[self createMainPage];
    });

}

-(void)loadData
{
    
    [[ClouldActivityManager shareInstance] listNearbyActivities:1 withType:0/*forLocation:CLLocationCoordinate2DMake(39.9075f,116.299722f)*/];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CampusActivity *act = (CampusActivity *)[self.activies objectAtIndex:indexPath.row];
    if ([self.pushDalegate conformsToProtocol:@protocol(CampusActivityListDelegate) ]) {
        [self.pushDalegate onSelectedActivity:act];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activies count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CampusActivityCell *cell = (CampusActivityCell *)[tableView dequeueReusableCellWithIdentifier:kReuseId];
    cell.delegate = self;
    
    UILabel *lab = (UILabel *)[cell viewWithTag:2];
    CampusActivity *act = (CampusActivity *)[self.activies objectAtIndex:indexPath.row];
    lab.text = act.game_name;
    
    lab = (UILabel *)[cell viewWithTag:4];
    lab.text = act.creator_jid;

    lab = (UILabel *)[cell viewWithTag:5];
    lab.text = act.type;//[CampusActivity getActivityTypeText:act.type];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    
    lab = (UILabel *)[cell viewWithTag:6];
    lab.text = [dateFormatter stringFromDate:act.begin_time];//[CampusActivity getActivityTypeText:act.type];
    lab = (UILabel *)[cell viewWithTag:7];
    lab.text = [dateFormatter stringFromDate:act.end_time];//[CampusActivity getActivityTypeText:act.type];
    
    lab = (UILabel *)[cell viewWithTag:9];
    lab.text = [NSString stringWithFormat:@"%d",act.member_number];
   
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (void)onSelectedButtonInWhichCell:(UITableViewCell *)cell joinGame:(BOOL)whether_join
{
    NSIndexPath * path = [self.activiesList indexPathForCell:cell];
    NSLog(@"index row%d", [path row]);
    
    CampusActivity *act = (CampusActivity *)[self.activies objectAtIndex:path.row];
    [[ClouldActivityManager shareInstance] participateInActivities:whether_join toActivity:act.game_id];
}
@end
