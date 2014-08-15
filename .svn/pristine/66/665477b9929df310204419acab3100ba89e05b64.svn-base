//
//  EditPersonalInfoViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-6.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "EditPersonalInfoViewController.h"
#import "NBNavigationController.h"
#import "PersonalSettingData.h"
#import "FriendInfo.h"
#import "PersonalTableViewCell.h"
#import "GetFrame.h"
#import "FriendsDetailInfoViewController.h"
#import "ChangeRemarkViewController.h"
#import "RosterManager.h"
#import "AccountManager.h"
#import "ImUtils.h"
#import "ChangeTextInfoViewController.h"
#import "NetworkBrokenAlert.h"
#import "CustomActionSheet.h"

#define HEADER_HEIGHT 8.0f
#define MYSELF @"myself"

@interface EditPersonalInfoViewController ()
<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RosterDelegate, CustomActionSheetDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;

@end

@implementation EditPersonalInfoViewController

@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_friendInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)changeTheme:(NSNotification *)notification
{
    [self createNavigationBar:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    [self setbasicCondition];
    [self createNavigationBar:YES];
    [[RosterManager shareInstance] addListener:self];
    [self setMemoryData];
    [self createTableView];
}

- (void)setbasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"编辑资料" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setMemoryData
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    [self.m_arrTableData addObject:[self getFirstSectionArr]];
    [self.m_arrTableData addObject:[self getSecondSectionArr]];
    [self.m_arrTableData addObject:[self getThirdSectionArr]];
    [self.m_arrTableData addObject:[self getFouthSectionArr]];
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * headData = [[PersonalSettingData alloc] init];
    headData.m_title = @"头像";
    
    headData.m_image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:self.m_friendInfo convertToGray:NO];
    headData.m_cellHeight = 45;
    headData.m_hasHeaderLine = YES;
    headData.m_hasIndicator = YES;
    headData.m_hasImageView = YES;
    
    [sectionArr addObject:headData];
    return  sectionArr;
}

- (NSMutableArray *)getSecondSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * nickData = [[PersonalSettingData alloc] init];
    nickData.m_title = @"昵称";
    nickData.m_cellHeight = 45.0f;
    nickData.m_hasHeaderLine = YES;
    nickData.m_hasIndicator = YES;
    nickData.m_hasLabel = YES;
    nickData.m_content = self.m_friendInfo.nickName;
    
    [sectionArr addObject:nickData];
    
    PersonalSettingData * signatureData = [[PersonalSettingData alloc] init];
    signatureData.m_title = @"个性签名";
    signatureData.m_cellHeight = 45.0f;
    signatureData.m_hasIndicator = YES;
    signatureData.m_hasLabel = YES;
    signatureData.m_content = self.m_friendInfo.moodWords;

    CGSize textSize = [self.m_friendInfo.moodWords sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(200, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    if (textSize.height < 30) {
        signatureData.m_cellHeight = 45;
    } else {
        signatureData.m_cellHeight = textSize.height + 10;
    }
    signatureData.m_textHeight = textSize.height;
    NSLog(@"textSize for sign in edit page == %@", NSStringFromCGSize(textSize));
    
    [sectionArr addObject:signatureData];
    return  sectionArr;
}

- (NSMutableArray *)getThirdSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    PersonalSettingData * onlineData = [[PersonalSettingData alloc] init];
    onlineData.m_title = @"在线";
    onlineData.m_hasHeaderLine = YES;
    onlineData.m_cellHeight = 45;
    onlineData.m_hasSelected = YES;
    [sectionArr addObject:onlineData];
    
    PersonalSettingData * hidingData = [[PersonalSettingData alloc] init];
    hidingData.m_title = @"隐身";
    hidingData.m_cellHeight = 45;
    hidingData.m_hasSelected = YES;
    [sectionArr addObject:hidingData];
    
    onlineData.m_isOnLine = NO;
    hidingData.m_isOnLine = NO;
    if ([self.m_friendInfo isOnline]) {
        onlineData.m_isOnLine = YES;
    } else {
        hidingData.m_isOnLine = YES;
    }
    
    return sectionArr;
}

- (NSMutableArray *)getFouthSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    PersonalSettingData * detailData = [[PersonalSettingData alloc] init];
    detailData.m_title = @"详细资料";
    detailData.m_cellHeight = 45;
    detailData.m_hasHeaderLine = YES;
    detailData.m_hasIndicator = YES;
    [sectionArr addObject:detailData];
    return sectionArr;
}

- (void)updateMyInfo:(FriendInfo *)my
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.m_friendInfo = my;
        [self resetTableData];
    });
}

- (void)resetTableData
{
    NSMutableArray * firstSectionArr = [self.m_arrTableData objectAtIndex:0];
    PersonalSettingData * headData = [firstSectionArr objectAtIndex:0];
    headData.m_image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:self.m_friendInfo convertToGray:NO];
    
    NSMutableArray * secondSectionArr = [self.m_arrTableData objectAtIndex:1];
    
    PersonalSettingData * nickData = [secondSectionArr objectAtIndex:0];
    nickData.m_content = self.m_friendInfo.nickName;
    
    PersonalSettingData * signatureData = [secondSectionArr objectAtIndex:1];
    signatureData.m_content = self.m_friendInfo.moodWords;
    
    CGSize textSize = [self.m_friendInfo.moodWords sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(200, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    
    
    if (textSize.height < 30) {
        signatureData.m_cellHeight = 45;
    } else {
        signatureData.m_cellHeight = textSize.height + 10;
    }
    signatureData.m_textHeight = textSize.height;
    NSLog(@"textSize for sign in edit page == %@", NSStringFromCGSize(textSize));

    
    [self.m_tableView reloadData];
}

- (void)createTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, m_frame.size.height - 64) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.scrollEnabled = NO;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.m_arrTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.m_arrTableData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * data = [eachSectionArr objectAtIndex:indexPath.row];
    return data.m_cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"edit";
    PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * settingData = [eachSectionArr objectAtIndex:indexPath.row];
    [cell setCellWithSettingData:settingData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 3 && indexPath.row == 0) {
        [self showDetailInfo];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self changeNickName];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self changeRemark];
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        [self changePhoto];
    } else if (indexPath.section == 2) {
        
        if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
            return;
        }
        
        if (indexPath.row == 0) {
            [[AccountManager shareInstance] setOnlineStatus:^(BOOL isSuccess) {
                
            }];
        }else if (indexPath.row == 1){
            [[AccountManager shareInstance] setInvisibleStatus:^(BOOL isSuccess) {
                
            }];
        }
        [self changeOnlineState:indexPath.row];
    }
}

- (void)changeOnlineState:(NSUInteger)index
{
    if ([self.m_arrTableData count] > 2) {
        NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:2];
        for (NSUInteger i = 0; i < [eachSectionArr count]; i++) {
            PersonalSettingData * onLineData = [eachSectionArr objectAtIndex:i];
            
            if (i == index) {
                onLineData.m_isOnLine = YES;
            } else {
                onLineData.m_isOnLine = NO;
            }
            
            NSLog(@"m_isOnLine == %d", onLineData.m_isOnLine);
        }
    }
    [self.m_tableView reloadData];
}

- (void)showDetailInfo
{
    FriendsDetailInfoViewController * controller = [[FriendsDetailInfoViewController alloc] init];
    controller.m_friendInfo = self.m_friendInfo;
    controller.m_type = MYSELF;
    [controller setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)changeNickName
{
    ChangeTextInfoViewController * controller = [[ChangeTextInfoViewController alloc] init];
    controller.m_title = @"昵称";
    controller.m_placeHolder = self.m_friendInfo.nickName;
    controller.m_numberOfWords = 12;
    controller.m_type = @"myNickName";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)changeRemark
{
    ChangeTextInfoViewController * controller = [[ChangeTextInfoViewController alloc] init];
    controller.m_title = @"个性签名";
    controller.m_placeHolder = self.m_friendInfo.moodWords;
    controller.m_numberOfWords = 50;
    controller.m_type = @"myMoodWords";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)changePhoto
{
    NSLog(@"cameraButtonPressed in personalNameCardViewContrller");
    NSArray * titleArr = [NSArray arrayWithObjects:@"拍照", @"相册", @"取消", nil];
    [[[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:nil] show];
}

- (void)customActionSheet:(CustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"user select %d",buttonIndex);
    if(buttonIndex != 2){
        [self useSystemCameraOrPhotoLibrary:buttonIndex];
    }
}

- (void)useSystemCameraOrPhotoLibrary:(NSUInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    if (buttonIndex == 1) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    NSLog(@"image -----> %@", image);
    image = [self rescalImageToSize:CGSizeMake(150, 150) andImage:image];
    NSData *binaryImageData = UIImageJPEGRepresentation(image, 0.5);
    
    NSString * destRootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * whistleFolder = [destRootPath stringByAppendingPathComponent:@"Whistle"];
    NSString * portraitPath = [whistleFolder stringByAppendingPathComponent:@"myportrait.png"];
    [binaryImageData writeToFile:portraitPath atomically:YES];
    [self sendNewImageToServer:portraitPath];
}

- (void)sendNewImageToServer:(NSString *)imagePath
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    [[RosterManager shareInstance] storeMyPic:imagePath withCallback:^(BOOL success) {
        NSLog(@"change my image == %d", success);
    }];
}

- (UIImage *)rescalImageToSize:(CGSize)size andImage:(UIImage *)image
{
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);
    // 强制把这个图片自己画到这个区域中
	[image drawInRect:rect];  // scales image to rect
    // 取出这个缩小的图片
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
