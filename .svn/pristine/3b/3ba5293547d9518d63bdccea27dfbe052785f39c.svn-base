//
//  CampusMapViewController.m
//  WhistleIm
//
//  Created by liming on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusMapViewController.h"
#import "CampusActivity.h"
#import "CampusActivityListViewController.h"
#import "ActivityAnnotationView.h"
#import "Constants.h"
#import "CreateCampusActivityController.h"
#import "CampusActivityTypeChooser.h"
#import "CampusNavigationMenuController.h"
#import "RootView.h"
#import "CampusActivityListController.h"
#import <QuartzCore/QuartzCore.h>
#import "CloudDockButton.h"
#import "CampusActivityDetailController.h"

#define FILTERHEIGHT    0
#define kCalloutViewMargin  0


@interface CampusMapViewController () <CampusActivityListDelegate,CampusActivityTypeChooserDelegate, CampusNavigationDelegate>


@property (nonatomic,strong) UIView *networkStatusContainer;
@property (nonatomic,strong) UIView *contentContainer;


//map

@property (nonatomic,strong) UIView *mapContainer;

//topbar
@property (nonatomic,strong) UIView *topbarContainer;
@property (nonatomic,strong) UIButton *activityViewSwitcher;
@property (nonatomic,strong) UIButton *activityType;

@property (nonatomic,strong) UIButton *backButton;
//@property (nonatomic,strong) UIButton *mapViewButton;
//@property (nonatomic,strong) UIButton *listViewButton;

@property (nonatomic,strong) UIButton *mapTypeSwitcher;

@property (nonatomic,assign) BOOL isActivityListShowing;

//toolbar
@property (nonatomic,strong) UIView *toolbarContainer;
//@property (nonatomic,strong) UIToolbar *toolbarForActivity;

@property (nonatomic,strong) UIButton *nextPage;
@property (nonatomic,strong) UIButton *createActivity;


//Activity type filter
//@property (nonatomic,strong) UITableView *activityTypeFilter;



//@property (nonatomic, assign) BOOL layoutDone;
@property (nonatomic, strong) NSMutableArray *activityAnnotations;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) BOOL onlyShowMyActivity;
@property (nonatomic, assign) int currentSegment;
@property (nonatomic, assign) int currentFilterIndex;
@property (nonatomic, strong) NSMutableArray *activityFilterText;

//Activity list view
@property (nonatomic,strong) UIView *activityListViewContainer;
@property (nonatomic,strong) CampusActivityListController *activitiesList;
//@property (nonatomic,strong) UIScrollView *listViewScrollerView;
//@property (nonatomic,strong) UIButton *showAllActivity;
//@property (nonatomic,strong) UIButton *showMyActivity;

//Activity type chooser view
@property (nonatomic,strong) UIView *activityTypeChooserContainer;
@property (nonatomic,strong) CampusActivityTypeChooser *activityTypeChooser;
@property (nonatomic,assign) BOOL chooserShown;

@end


@implementation CampusMapViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.activityAnnotations = [[NSMutableArray alloc] init];
        
        if (isIOS7) {
            
            self.automaticallyAdjustsScrollViewInsets = NO;
        }


        self.activityFilterText = [[NSMutableArray alloc] initWithObjects:@"全部",@"学习交流",@"培训讲座",@"课外实践",@"招聘求职",@"文化联谊",@"体育活动",@"聚会玩乐",@"展览展会",@"社团活动",@"其他活动", nil];
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, MAPTOPBARHEIGHT, rect.size.width *2, rect.size.height - MAPTOOLBARHEIGHT - MAPTOPBARHEIGHT)];
        
    }
    return self;
}

#pragma mark - Utility

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    //self.search.delegate = nil;
}

#pragma mark - AMapSearchDelegate

- (void)search:(id)searchRequest error:(NSString *)errInfo
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [searchRequest class], errInfo);
}
#pragma mark - CampusActivityListDelegate
-(void)onSelectedActivity:(CampusActivity *)activity
{
    CampusActivityDetailController *controller = [[CampusActivityDetailController alloc] init];
    controller.activityObject = activity;
    self.navigationController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Initialization

- (void)initMapView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect cMapRect = CGRectMake(0,0 , rect.size.width, rect.size.height - MAPTOOLBARHEIGHT - MAPTOPBARHEIGHT-0.5);
    self.mapContainer = [[UIView alloc] initWithFrame:cMapRect];
    self.mapTypeSwitcher = [self createButtonWithTitle:@"" withFrame:CGRectMake(cMapRect.size.width - 40, 10, 30, 30) withTag:0];
    [self.mapTypeSwitcher setImage:[UIImage imageNamed:@"maptypeswitch.png"] forState:UIControlStateNormal];
    [self.mapTypeSwitcher setImage:[UIImage imageNamed:@"maptypeswitch_pressed.png"] forState:UIControlStateHighlighted];
    
    self.mapView = [[MAMapView alloc] initWithFrame:cMapRect];
    //self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + MAPTOPBARHEIGHT, cMapRect.size.width *2, cMapRect.size.height)];
    //self.mapView.frame = self.view.bounds;
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
    self.mapView.delegate = self;
    self.mapView.zoomLevel = MAPDEFAULTZOOMLEVEL;
    self.mapView.mapType = MAMapTypeSatellite;
    self.mapView.showsScale = YES;
    [self.mapContainer addSubview:self.mapView];
    [self.mapContainer addSubview:self.mapTypeSwitcher];
    [self.contentContainer addSubview:self.mapContainer];
    [self.view addSubview:self.contentContainer];
    
    //self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}


- (void)configDockButton:(UIButton *)button withNormalImage:(NSString *)normalImageName withHighlightImage:(NSString *)highlightImageName
{
    [button setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightImageName] forState:UIControlStateHighlighted];
    //[button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //button.imageView.frame = CGRectMake((button.frame.size.width - 21)/2, 5, 21, 21);
    NSLog(@"configDockButton for image to %f,%f,%f,%f",button.imageView.frame.origin.x,button.imageView.frame.origin.y,button.imageView.frame.size.width,button.imageView.frame.size.height);
    //[button.imageView.layer setBorderWidth:2.0f];
    //[button.imageView.layer setBorderColor:[UIColor greenColor].CGColor];
    //button.titleLabel.frame = CGRectMake(0, 29, 35, 20);
    //[button.titleLabel.layer setBorderWidth:2.0f];
    //[button.titleLabel.layer setBorderColor:[UIColor greenColor].CGColor];
    
    //[button setTintColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0]];
    [button setTitleColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    button.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    
}



- (void)initSearch
{
    //self.search.delegate = self;
}


- (void)initNavigationBar
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.topbarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, MAPTOPBARHEIGHT+0.5)];
    //self.topbarContainer.layer.borderColor = [UIColor greenColor].CGColor;
    //[self.topbarContainer.layer setBorderWidth:1.0f];
    self.backButton = [self createButtonWithTitle:@"动态" withFrame:CGRectMake(0, 20, 86, MAPTOPBARHEIGHT-20) withTag:0];
    [self.backButton setTintColor:[UIColor clearColor]];
    [self.backButton setImage:[UIImage imageNamed:@"campact_myspace.png"] forState:UIControlStateNormal];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];

    UIImageView *toparrow = [[UIImageView alloc] initWithFrame:CGRectMake(86, 20, 5, MAPTOPBARHEIGHT - 20)];
    [toparrow setImage:[UIImage imageNamed:@"campact_top_arrow.png"]];

    self.activityType = [self createButtonWithTitle:@"全部" withFrame:CGRectMake(96, 20, 120, MAPTOPBARHEIGHT-20) withTag:0];
    //self.activityType.center = CGPointMake(self.topbarContainer.frame.size.width/2, (self.topbarContainer.frame.size.height)/2 + 20);
    self.activityType.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    UIImageView *rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(271, 20, 1, MAPTOPBARHEIGHT - 20)];
    [rightLine setImage:[UIImage imageNamed:@"campact_top_rightline.png"]];

    self.activityViewSwitcher = [self createButtonWithTitle:@"" withFrame:CGRectMake(272, 20, 48, MAPTOPBARHEIGHT - 20) withTag:0];
    self.isActivityListShowing = NO;
    [self.activityViewSwitcher setImage:[UIImage imageNamed:@"campact_mapview.png"] forState:UIControlStateNormal];
    self.activityViewSwitcher.backgroundColor = [UIColor clearColor];

    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, MAPTOPBARHEIGHT, rect.size.width, 1)];
    bottomLine.backgroundColor = [UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0];//[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    
    
    [self.topbarContainer addSubview:self.backButton];
    [self.topbarContainer addSubview:toparrow];
    [self.topbarContainer addSubview:self.activityType];
    [self.topbarContainer addSubview:rightLine];
    [self.topbarContainer addSubview:self.activityViewSwitcher];
    [self.topbarContainer addSubview:bottomLine];
    
    [self.view addSubview:self.topbarContainer];
    self.topbarContainer.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];

    
}

- (void)initToolbar
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.toolbarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - MAPTOOLBARHEIGHT, rect.size.width, MAPTOOLBARHEIGHT)];
    self.toolbarContainer.backgroundColor = [UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0];
    self.toolbarContainer.autoresizesSubviews = NO;
    
    
    //self.activityViewTypeSwitcher = [self createButtonWithTitle:@"活动" withFrame:CGRectMake(0, 0.5, 79.5f, MAPTOOLBARHEIGHT-0.5) withTag:1];
    //[self configDockButton:self.activityViewTypeSwitcher withNormalImage:@"campact.png" withHighlightImage:@"campact_pressed.png"];
    self.nextPage = [self createButtonWithTitle:@"刷新" withFrame:CGRectMake(0, 0.5, 159.5f, MAPTOOLBARHEIGHT-0.5) withTag:1];
    [self configDockButton:self.nextPage withNormalImage:@"campact_refresh.png" withHighlightImage:@"campact_refresh_pressed.png"];
    self.createActivity = [self createButtonWithTitle:@"添加" withFrame:CGRectMake(160, 0.5, 159.5f, MAPTOOLBARHEIGHT-0.5) withTag:1];
    [self configDockButton:self.createActivity withNormalImage:@"campact_add.png" withHighlightImage:@"campact_add_pressed.png"];
    
    
    
    [self.toolbarContainer addSubview:self.nextPage];
    [self.toolbarContainer addSubview:self.createActivity];
    
    
    //[self.toolbarContainer addSubview:self.toolbarForActivity];
    //[self.toolbarForActivity setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    //[self.toolbarForActivity setBarStyle:UIBarStyleBlack];
    //self.toolbarForActivity.translucent = YES;
    
    
    //NSLog(@"toolbar size <%f,%f,%f,%f>",cToolbarRect.origin.x,cToolbarRect.origin.y,cToolbarRect.size.width,cToolbarRect.size.height);
    [self.view addSubview:self.toolbarContainer];
    
    //self.toolbarContainer.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleBlackTranslucent;
}

- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}


-(void)initTypeChooser
{
    self.activityTypeChooser = [[CampusActivityTypeChooser alloc] initWithDelegate:self];
    
    self.activityTypeChooserContainer = [self.activityTypeChooser getView];
    
    self.chooserShown = NO;
    
    //[self.view addSubview:self.activityTypeChooserContainer];
    
}

-(UIButton *)createButtonWithTitle:(NSString *)string withFrame:(CGRect) rect withTag:(NSInteger) tag
{
    UIButton *button = nil;
    if(tag == 0){
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = rect;
    }else{
        button = [[CloudDockButton alloc] initWithFrame:rect];
    }
    
    [button setTitle:string forState:UIControlStateNormal];
    //button.backgroundColor = [UIColor blueColor];
    //[button setTintColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0]];
    [button setTitleColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0] forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    return  button;
}


-(void)initActivityListView

{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.activityListViewContainer = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x + rect.size.width,0, rect.size.width, rect.size.height - MAPTOPBARHEIGHT - MAPTOOLBARHEIGHT)];
    
    self.activitiesList = [[CampusActivityListController alloc] init];
    self.activitiesList.pushDalegate = self;
    UIView *listView = [self.activitiesList getView];
    [listView setFrame:CGRectMake(0,0,self.activityListViewContainer.frame.size.width,self.activityListViewContainer.frame.size.height)];
    [self.activityListViewContainer addSubview:listView];
    //listView.layer.borderWidth = 2.0f;
    //listView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.activitiesList bindView];
    
    [self.contentContainer addSubview:self.activityListViewContainer];

}


#pragma mark - Request Callback

-(void)requestForNextActivitySet:(BOOL)resetPageNumber
{
    if(resetPageNumber){
        self.currentPage = 1;
    }
    if(!self.onlyShowMyActivity){// all activity
        [[ClouldActivityManager shareInstance] listNearbyActivities: 1 /*self.currentPage ++ */ withType:self.currentFilterIndex];
    }else{
        [[ClouldActivityManager shareInstance] listMyRelatedActivities: 1 /*self.currentPage ++*/ withType:self.currentFilterIndex];
    }
}


#pragma mark - Handle Map Delegate
-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[ActivityAnnotationView class]]) {
        ActivityAnnotationView *cusView = (ActivityAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.mapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(self.mapView.frame, frame))
        {
            /* Calculate the offset to make the callout view show up. */
            CGSize offset = [self offsetToContainRect:frame inRect:self.mapView.frame];
            
            CGPoint theCenter = self.mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter toCoordinateFromView:self.mapView];
            
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
        
    }

}

-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"activityPointReuseIndetifier";
        ActivityAnnotationView *annotationView = (ActivityAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[ActivityAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            
            annotationView.canShowCallout            = YES;
            annotationView.draggable                 = NO;
            //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        //annotationView.pinColor = 1;
        
        return annotationView;
    }
    
    return nil;
}


#pragma mark - Utility
- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}


#pragma mark - Handle Button Event

-(void)pressBtn:(UIButton *)btn
{
    if(btn == self.backButton){
        //[self dismissViewControllerAnimated:YES completion:^(void){
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self clearMapView];
        [self.activityAnnotations removeAllObjects];
        self.activityAnnotations = nil;
        [self.activityFilterText removeAllObjects];
        self.activityFilterText = nil;
        [self.activitiesList destroy];
        self.activitiesList = nil;
        //}];
    }else if(btn == self.mapTypeSwitcher){
        [self onSwitchMapType];
    }else if(btn == self.activityViewSwitcher){
        [self onViewSwitch];
    }else if(btn == self.nextPage){
        [self onNextPage];
    }else if(btn == self.createActivity){
        [self onNewActivity];
    }else if(btn == self.activityType){
        [self onActivityType];
    }
}

-(void)filterActivitySet:(BOOL)onlyMine withIndex:(NSInteger)index
{
    if(onlyMine != self.onlyShowMyActivity){
        self.onlyShowMyActivity = onlyMine;
        [self requestForNextActivitySet:YES];
    }else{
        if(self.currentFilterIndex != index){
            self.currentFilterIndex = index;
            [self requestForNextActivitySet:YES];
        }
    }
}


-(void)onSwitchMapType
{
    if (self.mapView.mapType ==  MAMapTypeSatellite ) {
        self.mapView.mapType = MAMapTypeStandard;
        [self.mapTypeSwitcher setTitle:@"标准" forState:UIControlStateNormal];
    }else{
        self.mapView.mapType = MAMapTypeSatellite;
        [self.mapTypeSwitcher setTitle:@"卫星" forState:UIControlStateNormal];
    }
    
}

- (void)onActivityOrCoopon
{
    [self toggleChooser:NO];
}

-(void)onNextPage
{
    [self toggleChooser:NO];
    [self requestForNextActivitySet:NO];
}

-(void)toggleMenu:(BOOL)flag
{
    
}

-(void)toggleChooser:(BOOL)flag
{
    if(flag){
        if(self.chooserShown){
            return;
        }else{
            [self.view addSubview:self.activityTypeChooserContainer];
            [self.activityTypeChooser showChooser:^(){
                NSLog(@"toggle chooser callback from %d",flag);
                self.chooserShown = YES;
                //[self.activityTypeChooserContainer removeFromSuperview];
            }];
            
        }
    }else{
        if(!self.chooserShown){
            return;
        }else{
            [self.activityTypeChooser hideChooser:^(){
                self.chooserShown = NO;
                [self.activityTypeChooserContainer removeFromSuperview];
            }];
            
        }
    }
}

-(void)onActivityType
{
    //[self toggleTypeFilter:YES];
    if(self.chooserShown){
        [self toggleChooser:NO];
        
    }else{
        [self toggleChooser:YES];
    }
    
    
}

-(void)onNewActivity
{
    [self toggleChooser:NO];
    //CreateCampusActivityController *controller = [[CreateCampusActivityController alloc] init];
    //[self.navigationController pushViewController:controller animated:YES];
}

- (void)onViewSwitch
{
    if(self.isActivityListShowing){
        
        [UIView animateWithDuration:0.5 animations:^{
                
            self.contentContainer.frame = CGRectMake(0, MAPTOPBARHEIGHT, self.contentContainer.frame.size.width, self.contentContainer.frame.size.height);
            [self.activityViewSwitcher setImage:[UIImage imageNamed:@"campact_mapview.png"] forState:UIControlStateNormal];
    
        }];
    
        self.isActivityListShowing = NO;
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.contentContainer.frame = CGRectMake(-self.contentContainer.frame.size.width / 2, MAPTOPBARHEIGHT, self.contentContainer.frame.size.width, self.contentContainer.frame.size.height);
            [self.activityViewSwitcher setImage:[UIImage imageNamed:@"campact_listview.png"] forState:UIControlStateNormal];

        }];
        self.isActivityListShowing = YES;
    }
    //[[self.activityViewSwitcher.subviews objectAtIndex:self.currentSegment] setTintColor:[UIColor grayColor]];
    
}


-(void)onActivityListRefreshed:(NSArray *)newList forPage:(int)page
{
    //[self.annotations addObjectsFromArray:newList];
    __block NSArray *old = [[NSArray alloc] initWithArray:self.activityAnnotations];
    [self.activityAnnotations removeAllObjects];
    for (id<MAAnnotation> obj in newList) {
        MAPointAnnotation *red = [[MAPointAnnotation alloc] init];
        
        red.coordinate = [obj coordinate]; //CLLocationCoordinate2DMake(39.911447, 116.406026);
        //red.coordinate = CLLocationCoordinate2DMake(40.045837, 116.460577);
        red.title      = [obj title];
        
        [self.activityAnnotations addObject:red];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([old count] > 0){
            [self.mapView removeAnnotations:old];
        }
        old = nil;
        if([self.activityAnnotations count] > 0){
            [self.mapView addAnnotations:self.activityAnnotations];
        //[self.mapView setZoomLevel:1.0 animated:YES];
        }else{
            //TODO show no activity available toast
        }
    });
    
    
    //[self performSelectorOnMainThread:@selector(addAnnotationsIntoMap) withObject:nil waitUntilDone:NO];
    
}

- (void)addAnnotationsIntoMap
{
    
    [self.mapView addAnnotations:self.activityAnnotations];
    //[self.mapView addAnnotation:[self.annotations objectAtIndex:0]];
}



#pragma mark - CampusActivityTypeChooserDelegate
- (void)onTypeSelected:(NSInteger)typeIndex withText:(NSString *)text withNormalImageName:(NSString *)normalName withHighlightImageName:(NSString *)hightlightName
{
    if(typeIndex >= 0){
        
        [self.activityType setTitle:text forState:UIControlStateNormal];
        [self.activityType setTitle:text forState:UIControlStateHighlighted];
        //[self.activityType setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
        //[self.activityType setImage:[UIImage imageNamed:hightlightName] forState:UIControlStateHighlighted];
    
        if(typeIndex == 2){
            [self filterActivitySet:YES withIndex:typeIndex];
        }else{
            [self filterActivitySet:NO withIndex:typeIndex];
        }
    }
    [self toggleChooser:NO];
}

-(void)onItemSelected:(CampusMapItem)itemIndex
{
    
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.currentPage = 1;
    self.currentSegment = 0;
    self.onlyShowMyActivity = NO;
    self.currentFilterIndex = 0;

    [ClouldActivityManager shareInstance].lastUserLocation = [ClouldActivityManager shareInstance].cachedCenterPoint ;
    [ClouldActivityManager shareInstance].cachedCenterPoint = nil;
    
    [self initTitle:self.title];
    [self initActivityListView];

    
    [self initMapView];
    
    [self initNavigationBar];
    
    [self initSearch];
    
    [self initToolbar];
    
    [self initTypeChooser];
    
    
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    
    [[ClouldActivityManager shareInstance] addActivityListListener:self];
    //[[ClouldActivityManager shareInstance] listNearbyActivities:1 forLocation:CLLocationCoordinate2DMake(39.9075f,116.299722f)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //NSLog(@"view will appear with top container <%f,%f,%f,%f>",self.topbarContainer.frame.origin.x,self.topbarContainer.frame.origin.y,self.topbarContainer.frame.size.width,self.topbarContainer.frame.size.height);
    UITableView *table = (UITableView *)[self.activitiesList getView];
    
    NSLog(@"table insets top %f",table.contentInset.top);
    NSLog(@"table offset top %f",table.contentOffset.y);
    NSLog(@"table content top %f",table.contentSize.height);

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
   
    /*
    CGRect frame = self.activityViewTypeSwitcher.imageView.frame;
    
    NSLog(@"frame for button activity %f,%f,%f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    self.activityViewTypeSwitcher.imageView.frame = CGRectMake((self.activityViewTypeSwitcher.frame.size.width - 21)/2, 5, 21, 21);
    self.activityViewTypeSwitcher.titleLabel.frame = CGRectMake(0, 29, 35, 20);
*/
//    if(!self.layoutDone){
//        CGRect rect = self.view.frame;
//        CGRect cMapRect = CGRectMake(0, 0, rect.size.width, rect.size.height /* - MAPTOOLBARHEIGHT */);
//        self.mapView.frame = cMapRect;
        //NSLog(@"initMapView %f,%f,%f,%f",self.mapView.frame.origin.x,self.mapView.frame.origin.y,self.view.bounds.size.width,self.view.bounds.size.height);
//        self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
//        CGRect cToolbarRect = CGRectMake(0, rect.size.height - MAPTOOLBARHEIGHT, rect.size.width, MAPTOOLBARHEIGHT);
//        self.toolbarContainer.frame = cToolbarRect;
//        self.activityTypeFilter.frame = CGRectMake(0-rect.size.width, 0, rect.size.width, rect.size.height /*- MAPTOOLBARHEIGHT*/);
//        self.layoutDone = YES;
//    }

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.mapView.showsUserLocation = YES;
    [self.mapView setZoomLevel:MAPDEFAULTZOOMLEVEL animated:YES];
}


-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    //NSLog(@"location changed to %d <%f,%f>!",updatingLocation,userLocation.coordinate.longitude,userLocation.coordinate.latitude);
    if(updatingLocation){
        if ([[ClouldActivityManager shareInstance] cachedCenterPoint] == nil) {
            //NSLog(@"set center point now!");
            [ClouldActivityManager shareInstance].cachedCenterPoint = userLocation;
            [self.mapView setCenterCoordinate:userLocation.coordinate];
            [self requestForNextActivitySet:NO];
            
        }else{
            CLLocationDistance distance = [[[ClouldActivityManager shareInstance].cachedCenterPoint location] distanceFromLocation:userLocation.location];
            
            if (distance > MAXUPDATERANGE) {
                [ClouldActivityManager shareInstance].cachedCenterPoint = userLocation;
                [self.mapView setCenterCoordinate:userLocation.coordinate];
                [self requestForNextActivitySet:YES];
                
            }
        }
    }
    
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
