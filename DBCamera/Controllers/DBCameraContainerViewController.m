//
//  DBCameraContainerViewController.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraContainerViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraMacros.h"
#import "DBCameraView.h"

@interface DBCameraContainerViewController () <DBCameraContainerDelegate> {
    CameraSettingsBlock _settingsBlock;
    BOOL _wasStatusBarHidden;
    BOOL _wasWantsFullScreenLayout;
}
@property (nonatomic, strong) DBCameraViewController *defaultCameraViewController;
@end

@implementation DBCameraContainerViewController
@synthesize tintColor = _tintColor;
@synthesize selectedTintColor = _selectedTintColor;

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
{
    return [[DBCameraContainerViewController alloc] initWithDelegate:delegate cameraSettingsBlock:nil];
}

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraSettingsBlock:(CameraSettingsBlock)block
{
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _settingsBlock = block;
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    _wasStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    _wasWantsFullScreenLayout = self.wantsFullScreenLayout;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self setWantsFullScreenLayout:YES];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
    
    [self.view setBackgroundColor:RGBColor(0x000000, 1)];
    [self addChildViewController:self.defaultCameraViewController];
    [self.view addSubview:self.defaultCameraViewController.view];
    if ( _settingsBlock )
        _settingsBlock(self.cameraViewController.cameraView, self);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    [[UIApplication sharedApplication] setStatusBarHidden:_wasStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
    [self setWantsFullScreenLayout:_wasWantsFullScreenLayout];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - DBCameraContainerDelegate

- (void) backFromController:(id)fromController
{
    [self switchFromController:fromController
                  toController:self.defaultCameraViewController];
}

- (void) switchFromController:(id)fromController toController:(id)controller
{
    [[(UIViewController *)controller view] setAlpha:1];
    [[(UIViewController *)controller view] setTransform:CGAffineTransformMakeScale(1, 1)];
    [self addChildViewController:controller];
    
    __block id blockViewController = fromController;
    
    [self transitionFromViewController:blockViewController
                      toViewController:controller
                              duration:.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void){ }
                            completion:^(BOOL finished) {
                                [blockViewController removeFromParentViewController];
                                blockViewController = nil;
                            }];
}

#pragma mark - Properties

- (DBCameraViewController *) defaultCameraViewController
{
    if ( !_defaultCameraViewController ) {
        _defaultCameraViewController = [DBCameraViewController initWithDelegate:_delegate];
        if ( self.tintColor )
            [_defaultCameraViewController setTintColor:self.tintColor];
        if ( self.selectedTintColor )
            [_defaultCameraViewController setSelectedTintColor:self.selectedTintColor];
    }
    
    if ( !self.cameraViewController )
        [self setCameraViewController:_defaultCameraViewController];
    
    return self.cameraViewController;
}

- (void) setCameraViewController:(DBCameraViewController *)cameraViewController
{
    _cameraViewController = cameraViewController;
    [_cameraViewController setIsContained:YES];
    [_cameraViewController setContainerDelegate:self];
    _defaultCameraViewController = nil;
}

@end