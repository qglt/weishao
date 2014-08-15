//
//  PhotoPreviewController.m
//  WhistleIm
//
//  Created by LI on 14-2-25.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "PhotoPreviewController.h"
#import "NBNavigationController.h"

#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kMaxZoom 3.0
#define kScaleRate 0.8


static const CGFloat __overlayAlpha = 0.7f;						// opacity of the black overlay displayed below the focused image
static const CGFloat __animationDuration = 0.18f;				// the base duration for present/dismiss animations (except physics-related ones)
static const CGFloat __maximumDismissDelay = 0.5f;				// maximum time of delay (in seconds) between when image view is push out and dismissal animations begin
static const CGFloat __resistance = 0.0f;						// linear resistance applied to the image’s dynamic item behavior
static const CGFloat __density = 1.0f;							// relative mass density applied to the image's dynamic item behavior
static const CGFloat __velocityFactor = 1.0f;					// affects how quickly the view is pushed out of the view
static const CGFloat __angularVelocityFactor = 1.0f;			// adjusts the amount of spin applied to the view during a push force, increases towards the view bounds
static const CGFloat __minimumVelocityRequiredForPush = 50.0f;	// defines how much velocity is required for the push behavior to be applied

/* parallax options */
static const CGFloat __backgroundScale = 0.9f;					// defines how much the background view should be scaled
static const CGFloat __blurRadius = 2.0f;						// defines how much the background view is blurred
static const CGFloat __blurSaturationDeltaMask = 0.8f;
static const CGFloat __blurTintColorAlpha = 0.2f;				// defines how much to tint the background view

@interface PhotoPreviewController () <NBNavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *docPanel;



@end

@implementation PhotoPreviewController
{
    CGRect _originalFrame;
	CGFloat _minScale;
	CGFloat _maxScale;
	CGFloat _lastPinchScale;
	CGFloat _lastZoomScale;
	UIInterfaceOrientation _currentOrientation;
	BOOL _hasLaidOut;
	BOOL _unhideStatusBarOnDismiss;
    NSInteger rotation;
}
@synthesize imageView;
@synthesize imagePath;
@synthesize docPanel;
@synthesize scrollView;


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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9f) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self createNavigationBar:YES];
    [self createViews];
    [self createDocViews];
    [self loadImage];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:NSLocalizedString(@"preview",nil) andRightTitle:nil andNeedCreateSubViews:needCreate];
}

-(void)createDocViews
{
    docPanel = [[UIView alloc] initWithFrame:CGRectMake(0,[[UIScreen mainScreen] bounds].size.height-20-44-49 , [[UIScreen mainScreen] bounds].size.width,49)];
    
    docPanel.backgroundColor = [((NBNavigationController *)self.navigationController) getThemeBGColor];
    
    
    
    UIButton *letftBtn = [self createDocBtn:@"preview_left.png" HilightImageName:@"preview_left_pre.png" withframe:CGRectMake(40, 9.5, 30,30) withAction:@selector(turnLeft:)];
    
    UIButton *rightBtn = [self createDocBtn:@"preview_right.png" HilightImageName:@"preview_right_pre.png" withframe:CGRectMake(110, 9.5, 30,30) withAction:@selector(turnRight:)];
    
    UIButton *zoomOutBtn = [self createDocBtn:@"preview_zoomout.png" HilightImageName:@"preview_zoomout_pre.png" withframe:CGRectMake(180, 9.5, 30,30) withAction:@selector(zoomOut:)];
    
    UIButton *zoomInBtn = [self createDocBtn:@"preview_zoomin.png" HilightImageName:@"preview_zoomin_pre.png" withframe:CGRectMake(250, 9.5, 30,30) withAction:@selector(zoomIn:)];
    
    [docPanel addSubview:letftBtn];
    
    [docPanel addSubview:rightBtn];
    
    [docPanel addSubview:zoomOutBtn];
    
    [docPanel addSubview:zoomInBtn];
    
    [self.view addSubview:docPanel];
}

-(void)turnLeft:(UIButton *)btn
{
    [self setRotation:rotation - 1 animated:YES];
}

-(void)turnRight:(UIButton *)btn
{
     [self setRotation:rotation + 1 animated:YES];
}

- (void)setRotation:(NSInteger)theRotation animated:(BOOL)animated
{
    rotation = theRotation;
    if (rotation < -4)
        rotation = 4 - abs(rotation);
    if (rotation > 4)
        rotation = rotation - 4;
    if (_lastZoomScale != _minScale) {
        _lastZoomScale = _minScale;
        [self.scrollView setZoomScale:_minScale animated:NO];
    }
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation * M_PI / 2);
            self.imageView.transform = rotationTransform;
            
            // Reposition the image view
//            [self repositionImageView];
        } completion:^(BOOL finished) {
            
//            if (finished)
//            {
//                // Notification
//                if (self.didChangeRotationBlock)
//                    self.didChangeRotationBlock(rotation);
//                
//                // Reposition ratio controls
//                [self resetRatioControls];
//            }
        }];
    } else
    {
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation * M_PI / 2);
        self.imageView.transform = rotationTransform;
        
//        // Reposition the image view
//        [self repositionImageView];
//        
//        // Notification
//        if (self.didChangeRotationBlock)
//            self.didChangeRotationBlock(rotation);
//        
//        // Reposition ratio controls
//        [self resetRatioControls];
    }
}

-(void)zoomIn:(UIButton *)btn
{
    _lastZoomScale-=kScaleRate;
    if (_lastZoomScale==self.scrollView.minimumZoomScale) return;
    if (_lastZoomScale<self.scrollView.minimumZoomScale) _lastZoomScale= self.scrollView.minimumZoomScale;
    [self.scrollView setZoomScale:_lastZoomScale animated:YES];
}

-(void)zoomOut:(UIButton *)btn
{
    _lastZoomScale+=kScaleRate;
    if (_lastZoomScale==self.scrollView.maximumZoomScale) return;
    if (_lastZoomScale>self.scrollView.maximumZoomScale) _lastZoomScale= self.scrollView.maximumZoomScale;
    [self.scrollView setZoomScale:_lastZoomScale animated:YES];
}

-(UIButton *)createDocBtn:(NSString *)imageName HilightImageName:(NSString *)hName withframe:(CGRect) rect withAction:(SEL)action
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame = rect;
    
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    [btn setImage:[UIImage imageNamed:hName] forState:UIControlStateHighlighted];
  
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

-(void)createViews
{
    _currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight-20-44-49)];
	self.scrollView.backgroundColor = [UIColor clearColor];
	self.scrollView.delegate = self;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollEnabled = NO;
	[self.view addSubview:self.scrollView];
	
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.alpha = 0.0f;
	self.imageView.userInteractionEnabled = YES;
	[self.scrollView addSubview:self.imageView];
	
	/* setup gesture recognizers */
	// double tap gesture to return scaled image back to center for easier dismissal
	UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    //	doubleTapRecognizer.delegate = self;
	doubleTapRecognizer.numberOfTapsRequired = 2;
	doubleTapRecognizer.numberOfTouchesRequired = 1;
	[self.imageView addGestureRecognizer:doubleTapRecognizer];
    
    rotation = 0;
    
}

-(void) loadImage
{
    self.imageView.transform = CGAffineTransformIdentity;
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	self.imageView.image = image;
	self.imageView.alpha = 0.2;
    
    // update scrollView.contentSize to the size of the image
	self.scrollView.contentSize = image.size;
	CGFloat scaleWidth = CGRectGetWidth(self.scrollView.frame) / self.scrollView.contentSize.width;
	CGFloat scaleHeight = CGRectGetHeight(self.scrollView.frame) / self.scrollView.contentSize.height;
	CGFloat scale = MIN(scaleWidth, scaleHeight);
	
	// image view's destination frame is the size of the image capped to the width/height of the target view
	CGPoint midpoint = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.scrollView.bounds));
	CGSize scaledImageSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
	CGRect targetRect = CGRectMake(midpoint.x - scaledImageSize.width / 2.0, midpoint.y - scaledImageSize.height / 2.0, scaledImageSize.width, scaledImageSize.height);
	self.imageView.frame = targetRect;
	
	// set initial frame of image view to match that of the presenting image
	//self.imageView.frame = CGRectMake(midpoint.x - image.size.width / 2.0, midpoint.y - image.size.height / 2.0, image.size.width, image.size.height);
//	self.imageView.frame = [self.view convertRect:fromRect fromView:nil];
	_originalFrame = targetRect;
	// rotate imageView based on current device orientation
	[self reposition];
    
	if (scale < 1.0f) {
		self.scrollView.minimumZoomScale = 1.0f;
		self.scrollView.maximumZoomScale = 1.0f / scale;
	}
	else {
		self.scrollView.minimumZoomScale = 1.0f / scale;
		self.scrollView.maximumZoomScale = 1.0f;
	}
	
	_lastZoomScale = _minScale = self.scrollView.minimumZoomScale;
	_maxScale = self.scrollView.maximumZoomScale;
	_lastPinchScale = 1.0f;
	_hasLaidOut = YES;

	
	[UIView animateWithDuration:__animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.imageView.alpha = 1.0f;
		self.imageView.frame = targetRect;
		
	} completion:^(BOOL finished) {
		
	}];
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
	if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
        _lastZoomScale = self.scrollView.minimumZoomScale;
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
	}
	else {
		CGPoint tapPoint = [self.imageView convertPoint:[gestureRecognizer locationInView:gestureRecognizer.view] fromView:self.scrollView];
		CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        _lastZoomScale = newZoomScale;
		CGFloat w = CGRectGetWidth(self.imageView.frame) / newZoomScale;
		CGFloat h = CGRectGetHeight(self.imageView.frame) / newZoomScale;
		CGRect zoomRect = CGRectMake(tapPoint.x - (w / 2.0f), tapPoint.y - (h / 2.0f), w, h);
		
		[self.scrollView zoomToRect:zoomRect animated:YES];
	}
}

- (void)reposition {
	CGAffineTransform baseTransform = [self transformForOrientation:_currentOrientation];
	
	// determine if the rotation we're about to undergo is 90 or 180 degrees
	CGAffineTransform t1 = self.imageView.transform;
	CGAffineTransform t2 = baseTransform;
	CGFloat dot = t1.a * t2.a + t1.c * t2.c;
	CGFloat n1 = sqrtf(t1.a * t1.a + t1.c * t1.c);
	CGFloat n2 = sqrtf(t2.a * t2.a + t2.c * t2.c);
	CGFloat rotationDelta = acosf(dot / (n1 * n2));
	BOOL isDoubleRotation = (rotationDelta > M_PI_2);
	
	// use the system rotation duration
	CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
	// iPad lies about its rotation duration
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { duration = 0.4; }
	
	// double the animation duration if we're rotation 180 degrees
	if (isDoubleRotation) { duration *= 2; }
	
	// if we haven't laid out the subviews yet, we don't want to animate rotation and position transforms
	if (_hasLaidOut) {
		[UIView animateWithDuration:duration animations:^{
			self.imageView.transform = CGAffineTransformConcat(self.imageView.transform, baseTransform);
		}];
	}
	else {
		self.imageView.transform = CGAffineTransformConcat(self.imageView.transform, baseTransform);
    }
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	// calculate a rotation transform that matches the required orientation
	if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		transform = CGAffineTransformMakeRotation(M_PI);
	}
	else if (orientation == UIInterfaceOrientationLandscapeLeft) {
		transform = CGAffineTransformMakeRotation(-M_PI_2);
	}
	else if (orientation == UIInterfaceOrientationLandscapeRight) {
		transform = CGAffineTransformMakeRotation(M_PI_2);
	}
	
	return transform;
}

-(void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollview {
	// zoomScale of 1.0 is always our starting point, so anything other than that we disable the pan gesture recognizer
	if (scrollview.zoomScale <= 0.75f && !scrollview.zooming) {
//		if (self.panRecognizer) {
//			[self.imageView addGestureRecognizer:self.panRecognizer];
//		}
		scrollview.scrollEnabled = NO;
	}
	else {
//		if (self.panRecognizer) {
//			[self.imageView removeGestureRecognizer:self.panRecognizer];
//		}
		scrollview.scrollEnabled = YES;
	}
	[self centerScrollViewContents];
}

- (void)centerScrollViewContents {
	CGSize contentSize = self.scrollView.contentSize;
	CGFloat offsetX = (CGRectGetWidth(self.scrollView.frame) > contentSize.width) ? (CGRectGetWidth(self.scrollView.frame) - contentSize.width) / 2.0f : 0.0f;
	CGFloat offsetY = (CGRectGetHeight(self.scrollView.frame) > contentSize.height) ? (CGRectGetHeight(self.scrollView.frame) - contentSize.height) / 2.0f : 0.0f;
	self.imageView.center = CGPointMake(self.scrollView.contentSize.width / 2.0f + offsetX, self.scrollView.contentSize.height / 2.0f + offsetY);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
