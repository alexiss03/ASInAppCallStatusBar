//
//  InCallStatusBar.m
//  Noteabout-Chat
//
//  Created by Hanet on 11/24/16.
//  Copyright © 2016 Noteabout. All rights reserved.
//

#import "ASInAppCallStatusBar.h"

typedef enum InAppCallStatusBarAnimation: NSUInteger
{
    InAppCallStatusBarAnimationNone = 0,
    InAppCallStatusBarAnimationBlink = 1
    
} InAppCallStatusBarAnimation;



@interface ASInAppCallStatusBar()

@property (weak, nonatomic) IBOutlet UILabel *centerLbl;    

@property (nonatomic, weak) NSTimer * callTimer;
@property (nonatomic, weak) UIViewController * returnViewController;
@property (nonatomic, strong) NSString * defaultSpiel;
@property (nonatomic) InAppCallStatusBarAnimation animation;
@property (nonatomic) int currentTime;

@end


@implementation ASInAppCallStatusBar

+ (instancetype) shared
{
    static ASInAppCallStatusBar *_shared;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _shared = [[ASInAppCallStatusBar alloc] initWithSpiel:@"Touch to return to call" withTimer:0 withAnimation:InAppCallStatusBarAnimationBlink];
    });
    
    return _shared;
}

- (instancetype) initWithSpiel: (NSString *) spiel withTimer: (int) currentTime withAnimation:(InAppCallStatusBarAnimation) animation
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ASInAppCallStatusBar"  owner:self options:nil] objectAtIndex:0];
    
    if (self) {
        _currentTime = currentTime;
        
        _defaultSpiel = spiel;
        _animation = animation;
        _centerLbl.text = spiel;
        
        _callTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                        target:self
                        selector:@selector(updateCenterLabelText)
                        userInfo:nil
                        repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)  name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarTapped)];
        
        [self addGestureRecognizer:tapGesture];

    }
    return self;
}

- (void) showWithSpiel: (NSString *) spiel withStartSecond: (int) second withTapViewController: (UIViewController *) vc
{
    self.returnViewController = vc;
    self.defaultSpiel = spiel;
    self.currentTime = second;
    
    [self addInAppCallBarToWindow];
}


#pragma mark - Gesture Recognizers

- (void) statusBarTapped
{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;

    if (self.returnViewController && currentWindow.rootViewController != self.returnViewController) {
        [currentWindow.rootViewController.splitViewController presentViewController:self.returnViewController animated:YES completion:nil];
    }
    
    [self hideInAppCallStatusBar];
}


#pragma mark - Orientation Changes

- (void) orientationChanged: (NSNotification *) notification
{
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationFaceUp ||
        [UIDevice currentDevice].orientation == UIDeviceOrientationFaceDown)
        return;
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    UIView * rootVCView = currentWindow.rootViewController.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
                self.frame = CGRectMake(0, 25, currentWindow.frame.size.width, 25);
                rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
            } else {
                
                self.frame = CGRectMake(0, 0, currentWindow.frame.size.width, 25);
                rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 25, rootVCView.frame.size.width, currentWindow.frame.size.height - 25);
            }
        } else {
            self.frame = CGRectMake(0, 25, currentWindow.frame.size.width, 25);
            rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
        }
    });
    
}


#pragma mark - UI Changes

- (void) updateCenterLabelText {
    
    self.currentTime = self.currentTime + 1;
    self.centerLbl.text = [NSString stringWithFormat:@"%@ %02d:%02d", self.defaultSpiel, self.currentTime/60, self.currentTime%60];
    
 
    if (self.animation == InAppCallStatusBarAnimationBlink) {
        
        __weak ASInAppCallStatusBar * weakSelf = self;
    
        [UIView animateWithDuration:0.25f
         animations:^{
             weakSelf.centerLbl.alpha = 0.5f;
         } completion:^(BOOL finished) {
             weakSelf.centerLbl.alpha = 1.f;
         }];
    }
}


- (void) addInAppCallBarToWindow {

    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    UIView * rootVCView = currentWindow.rootViewController.view;
    
    if(currentWindow) {
        currentWindow.backgroundColor = [UIColor redColor];
    } else {
        [UIApplication sharedApplication].windows[0].backgroundColor = [UIColor redColor];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
                self.frame = CGRectMake(0, 25, currentWindow.frame.size.width, 25);
                rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
            } else {
                
                self.frame = CGRectMake(0, 0, currentWindow.frame.size.width, 25);
                rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 25, rootVCView.frame.size.width, currentWindow.frame.size.height - 25);
            }
        } else {
            self.frame = CGRectMake(0, 25, currentWindow.frame.size.width, 25);
            rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
        }
        
    });
    
    
    if(currentWindow) {
        [currentWindow addSubview:self];
    } else {
       [[UIApplication sharedApplication].windows[0] addSubview:self];
    }
    
    
    UIViewController * rootViewController = [currentWindow rootViewController];
    [rootViewController.navigationController.view addSubview:self];
}


- (void) hideInAppCallStatusBar {
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    UIView * rootVCView = currentWindow.rootViewController.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        currentWindow.backgroundColor = [UIColor whiteColor];
        rootVCView.frame = CGRectMake(0, 0, rootVCView.frame.size.width, currentWindow.frame.size.height);
        
        [self removeFromSuperview];
    });
    
    self.returnViewController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.callTimer invalidate];
    self.callTimer = nil;
    
    self.currentTime = 0;
}

@end
