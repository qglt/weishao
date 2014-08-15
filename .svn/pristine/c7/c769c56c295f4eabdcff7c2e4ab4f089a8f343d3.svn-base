//
//  CrowdInfoViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdInfoViewController.h"
#import "NBNavigationController.h"
#import "CrowdDetailInfoSetting.h"
#import "CrowdInfoTableView.h"
#import "PersonalSettingData.h"
#import "RosterManager.h"
#import "ImUtils.h"
#import "TalkingRecordViewController.h"

#import "CrowdInfo.h"
#import "CrowdCategoryViewController.h"
#import "ChangeTextInfoViewController.h"
#import "CrowdMembersViewController.h"
#import "CrowdInfo.h"
#import "CrowdManager.h"
#import "NetworkBrokenAlert.h"
#import "CustomActionSheet.h"

@interface CrowdInfoViewController ()
<CrowdInfoTableViewDelegate, CustomActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RosterDelegate, CrowdDetailInfoSettingDelegate>
{
    CGRect m_frame;
    NSMutableArray * m_arrTableData;
    
    CrowdInfoTableView * m_infoTableView;
    
    BOOL m_canRequestNextTime;
    
    BOOL m_hadCreateTableView;
    NSUInteger m_maxLimit;
}

@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) CrowdInfoTableView * m_infoTableView;

@end

@implementation CrowdInfoViewController

@synthesize m_arrTableData;
@synthesize m_infoTableView;

@synthesize m_crowdInfo;
@synthesize m_crowdSessionID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setBasicCondition];
    [self createNavigationBar:YES];
    if (!self.m_crowdSessionID) {
        self.m_crowdSessionID = self.m_crowdInfo.session_id;
    }
    [self getCrowdDetailInfo];
}

- (void)getCrowdDetailInfo
{
    if (self.m_crowdInfo) {
        [self createDetailInfoSettingWithSessionId:self.m_crowdInfo.session_id];
    } else if (self.m_crowdSessionID) {
        [self createDetailInfoSettingWithSessionId:self.m_crowdSessionID];
    }
}

- (void)createDetailInfoSettingWithSessionId:(NSString *)sessionId
{
    CrowdDetailInfoSetting * setting = [[CrowdDetailInfoSetting alloc] init];
    setting.m_delegate = self;
    [setting getCrowdDetailInfoWithSessionId:sessionId];
}

- (void)sendCrowdDetailInfo:(NSMutableArray *)dataArr andDetailCrowdInfo:(CrowdInfo *)crowdInfo andMySelfAuthority:(NSString *)authority
{
    self.m_arrTableData = dataArr;
    if (m_hadCreateTableView) {
        [self refreshTableViewWithMySelfAuthority:authority];
    } else {
        [self createInfoTableViewWithMySelfAuthority:authority];
    }
  
    self.m_crowdInfo = crowdInfo;
    m_hadCreateTableView = YES;
    m_maxLimit = self.m_crowdInfo.max_member_size;
}

- (void)refreshTableViewWithMySelfAuthority:(NSString *)authority
{
    [self.m_infoTableView refreshCrowdInfoTableViewWithDataArr:self.m_arrTableData andMySelfAuthority:authority];
}

- (void)setBasicCondition
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"群资料" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createInfoTableViewWithMySelfAuthority:(NSString *)authority
{
    CGFloat y = 0.0f;
    
    if (isIOS7) {
        y += 64.0f;
    }
    CGFloat height = m_frame.size.height - 20 - 44;
    
    self.m_infoTableView = [[CrowdInfoTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) withTableDataArr:self.m_arrTableData andMySelfAuthority:authority];
    self.m_infoTableView.m_delegate = self;
    [self.view addSubview:self.m_infoTableView];
}

// CrowdInfoTableView delegate
- (void)changeCrowdImage
{
    [self changePhoto];
}

// CrowdInfoTableView delegate
- (void)changeCrowdOthersInfoWithIndex:(NSIndexPath *)indexPath
{
    NSString * content = nil;
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * settingData = [eachSectionArr objectAtIndex:indexPath.row];
    content = settingData.m_content;
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self pushToChangeTextInfoViewControllerWithTitle:@"群名称" andPlaceHolder:content andNumberOfWords:12 andType:@"crowdName"];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self pushToChangeTextInfoViewControllerWithTitle:@"群备注" andPlaceHolder:content andNumberOfWords:12 andType:@"crowdRemark"];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self pushToChangeTextInfoViewControllerWithTitle:@"群公告" andPlaceHolder:content andNumberOfWords:140 andType:@"crowdNotice"];
    } else if (indexPath.section == 1 && indexPath.row == 3) {
        [self pushToChangeTextInfoViewControllerWithTitle:@"群简介" andPlaceHolder:content andNumberOfWords:140 andType:@"crowdIntroduce"];
    }
    
    NSLog(@"crowd text change placeholder == %@", content);
}

// CrowdInfoTableView delegate
- (void)changeCrowdCategory
{
    [self pushToCrowdCategoryViewController];
}

// CrowdInfoTableView delegate
- (void)changeCrowdAcceptStateWithIndex:(NSInteger)index
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    [self changecrowdInfomationTypeWithIndex:index];
}

- (void)changecrowdInfomationTypeWithIndex:(NSUInteger)index
{
    if (index == 0) {
        [[CrowdManager shareInstance] setCrowdAlert_Recv:self.m_crowdSessionID callback:^(BOOL success) {
            NSLog(@"set crowd info state accept and remind == %d", success);
        }];
    } else if (index == 1) {
        [[CrowdManager shareInstance] setCrowdAlert_Recv_NO_Tint:self.m_crowdSessionID callback:^(BOOL success) {
            NSLog(@"set crowd info state accept and none remind == %d", success);
        }];
    } else if (index == 2) {
        [[CrowdManager shareInstance] setCrowdAlert_Reject:self.m_crowdSessionID callback:^(BOOL success) {
            NSLog(@"set crowd info state shield == %d", success);
        }];
    }
}

// CrowdInfoTableView delegate
- (void)showCrowdTalkRecord
{
    [self pushToCrowdRecordViewController];
}



// CrowdInfoTableView delegate
- (void)showCrowdMembers
{
    NSString * sessionID = nil;
    if (self.m_crowdInfo) {
        sessionID = self.m_crowdInfo.session_id;
    } else if (self.m_crowdSessionID) {
        sessionID = self.m_crowdSessionID;
    }

    [self pushToCrowdMembersViewControllerWithCrowdSessionID:sessionID];
}

- (void)pushToCrowdRecordViewController
{
    TalkingRecordViewController * controller = [[TalkingRecordViewController alloc] init];
    controller.inputObject = self.m_crowdInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushToCrowdCategoryViewController
{
    CrowdCategoryViewController * controller = [[CrowdCategoryViewController alloc] init];
    controller.m_category = self.m_crowdInfo.category;
    controller.m_crowdSessionID = self.m_crowdSessionID;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushToChangeTextInfoViewControllerWithTitle:(NSString *)title andPlaceHolder:(NSString *)holder andNumberOfWords:(NSUInteger)words andType:(NSString *)type
{
    ChangeTextInfoViewController * controller = [[ChangeTextInfoViewController alloc] init];
    controller.m_title = title;
    controller.m_placeHolder = holder;
    controller.m_numberOfWords = words;
    controller.m_type = type;
    controller.m_crowdSessionID = self.m_crowdInfo.session_id;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushToCrowdMembersViewControllerWithCrowdSessionID:(NSString *)sessionID
{
    CrowdMembersViewController * controller = [[CrowdMembersViewController alloc] init];
    controller.m_crowdSessionID = sessionID;
    controller.m_maxLimit = m_maxLimit;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)changePhoto
{
    NSArray * titleArr = [NSArray arrayWithObjects:@"拍照", @"相册", @"取消", nil];
    CustomActionSheet * sheet = [[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:nil];
    sheet.tag = 1000;
    [sheet show];
}

// CrowdInfoTableView delegate
- (void)dissolveCrowd
{
    NSArray * titleArr = [NSArray arrayWithObjects:@"确定", @"取消", nil];
    CustomActionSheet * sheet = [[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:@"确定解散该群?"];
    sheet.tag = 2000;
    [sheet show];
}

// 退出群
- (void)quitCrowd
{
    NSArray * titleArr = [NSArray arrayWithObjects:@"确定", @"取消", nil];
    CustomActionSheet * sheet = [[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:@"确定退出该群?"];
    sheet.tag = 3000;
    [sheet show];
}

- (void)customActionSheet:(CustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"user select %d",buttonIndex);

    if (customActionSheet.tag == 2000) {
        if (buttonIndex == 0) {
            [self dismissCrowd];
        }
    } else if (customActionSheet.tag == 1000){
        if(buttonIndex != 2){
            [self useSystemCameraOrPhotoLibrary:buttonIndex];
        }
    } else if (customActionSheet.tag == 3000) {
        if (buttonIndex == 0) {
            [self leaveCrowd];
        }
    }
}

- (void)leaveCrowd
{
    [[CrowdManager shareInstance] leaveCrowd:self.m_crowdSessionID callback:^(BOOL success) {
        NSLog(@"leave crowd success == %d", success);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)dismissCrowd
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    [[CrowdManager shareInstance] dismissCrowd:self.m_crowdSessionID callback:^(BOOL success) {
        NSLog(@"dismiss crowd success == %d", success);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
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
    NSString * portraitPath = [whistleFolder stringByAppendingPathComponent:@"crowdIcon.png"];
    [binaryImageData writeToFile:portraitPath atomically:YES];
    [self sendNewImageToServer:portraitPath];
}

- (void)sendNewImageToServer:(NSString *)imagePath
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    NSLog(@"save crowd icon path == %@", imagePath);
    [[CrowdManager shareInstance] setCrowdIcon:self.m_crowdSessionID icon:imagePath callback:^(BOOL success) {
        NSLog(@"change crowd icon success == %d", success);
        if (success) {
            [self getCrowdDetailInfo];
        }
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
    if (m_canRequestNextTime) {
        [self getCrowdDetailInfo];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_canRequestNextTime = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
