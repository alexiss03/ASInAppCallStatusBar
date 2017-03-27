//
//  InCallStatusBar.m
//  Noteabout-Chat
//
//  Created by Hanet on 11/24/16.
//  Copyright © 2016 Noteabout. All rights reserved.
//

#import "ASInAppCallStatusBar.h"
#import "TimerTargetWrapper.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


@interface ASInAppCallStatusBar()

@property (weak, nonatomic) IBOutlet UILabel *centerLbl;

@property (nonatomic, strong) NSTimer * callTimer;
@property (nonatomic, strong) UIViewController * returnViewController;
@property (nonatomic, strong) NSString * defaultSpiel;
@property (nonatomic) ASInAppCallStatusBarAnimation animation;
@property (nonatomic) ASInAppCallStatusBarCallStatus callStatus;
@property (nonatomic) int currentTime;

@end


@implementation ASInAppCallStatusBar

+ (instancetype) shared
{
    static ASInAppCallStatusBar *_shared;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _shared = [[ASInAppCallStatusBar alloc] initWithSpiel:NSLocalizedStringWithDefaultValue(@"calling.tap-to-return-call", nil, [NSBundle mainBundle], @"Touch to return to call", @"Label in the status bar when a voice call is put to the background ") withTimer:0 withAnimation:ASInAppCallStatusBarAnimationBlink];
    });
    
    return _shared;
}


- (instancetype) initWithSpiel: (NSString *) spiel withTimer: (int) currentTime withAnimation:(ASInAppCallStatusBarAnimation) animation
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ASInAppCallStatusBar"  owner:self options:nil] objectAtIndex:0];
    
    if (self) {
        _currentTime = currentTime;
        
        if(spiel)
            _defaultSpiel = spiel;
        
        _animation = animation;
        _centerLbl.text = spiel;
        _callStatus = ASInAppCallStatusBarCallStatusNone;
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarTapped)];
        [self addGestureRecognizer:tapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}


- (void) showWithSpiel: (NSString *) spiel withStartSecond: (int) second withStatus:(ASInAppCallStatusBarCallStatus) callStatus withTapViewController: (UIViewController *) vc
{
    [self showASInAppCallStatusBar];
    
    self.callStatus = callStatus;
    self.returnViewController = vc;
    self.defaultSpiel = spiel;
    self.currentTime = second;
    
    [self addInAppCallBarToWindow];
    
    if(self.callStatus == ASInAppCallStatusBarCallStatusOngoing) {
        self.callTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:[[TimerTargetWrapper alloc] initWithDelegate:self] selector:@selector(timerFired:) userInfo:nil repeats:YES];
        
    }
}


- (void) changeStatusToOngoingWithStartTime:(int) startTime {
    
    self.callStatus = ASInAppCallStatusBarCallStatusOngoing;
    self.currentTime = startTime;
    
    if(!self.callTimer) {
        self.callTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:[[TimerTargetWrapper alloc] initWithDelegate:self] selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
    
    [self setWindowColor];
}


#pragma mark - Gesture Recognizers

- (void) statusBarTapped
{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    
    if( [currentWindow.rootViewController isKindOfClass:[UISplitViewController class]] && ((UISplitViewController *)currentWindow.rootViewController).presentedViewController) { return; }
    
    if (self.returnViewController && currentWindow.rootViewController != self.returnViewController) {
        [currentWindow.rootViewController presentViewController:self.returnViewController animated:YES completion:nil];
    }
    
    self.returnViewController = nil;
    
    [self resetASInAppCallStatusBar];
}


#pragma mark - UI Changes

- (void) updateCenterLabelText
{
    if(self.callStatus == ASInAppCallStatusBarCallStatusOngoing) {
        
        self.currentTime = self.currentTime + 1;
        self.centerLbl.text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"calling.tap-to-return-call-time", nil, [NSBundle mainBundle], @"%@ %02d:%02d", @"Touch to return to call"), self.defaultSpiel, self.currentTime/60, self.currentTime%60];
        
        if (self.animation == ASInAppCallStatusBarAnimationBlink) {
            
            __weak ASInAppCallStatusBar * weakSelf = self;
            
            [UIView animateWithDuration:0.15f
                             animations:^{
                                 weakSelf.centerLbl.alpha = 0.5f;
                             } completion:^(BOOL finished) {
                                 weakSelf.centerLbl.alpha = 1.f;
                             }];
        }
    } else if (self.callStatus == ASInAppCallStatusBarCallStatusPending) {
        
        self.centerLbl.text = self.defaultSpiel;
        
    }
}


- (void) updateStatusBarFrame
{
    if(self.superview == nil) { return; }
    
    UIWindow *currentWindow = [self getCurrentWindow];
    UIView * rootVCView = currentWindow.rootViewController.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            if([self isUIInterfacePortrait]) {
                [UIView animateWithDuration:0.15f animations:^{
                    rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
                    self.centerLbl.hidden = NO;
                }];
            } else {
                [UIView animateWithDuration:0.15f animations:^{
                    rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 0, rootVCView.frame.size.width, currentWindow.frame.size.height);
                    self.centerLbl.hidden = YES;
                }];
            }
            
        } else {
            [UIView animateWithDuration:0.15f animations:^{
                rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
            }];
        }
    });
    
}


- (void) updateStatusBarFrameWithReloadSelectedIndexTab
{
    if(self.superview == nil) { return; }
    
    UIWindow *currentWindow = [self getCurrentWindow];
    UIView * rootVCView = currentWindow.rootViewController.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            if([self isUIInterfacePortrait]) {
                [UIView animateWithDuration:0.15f animations:^{
                    rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
                    self.centerLbl.hidden = NO;
                }];
            } else {
                [UIView animateWithDuration:0.15f animations:^{
                    rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 0, rootVCView.frame.size.width, currentWindow.frame.size.height);
                    self.centerLbl.hidden = YES;
                }];
            }
            
        } else {
            [UIView animateWithDuration:0.15f animations:^{
                rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 50, rootVCView.frame.size.width, currentWindow.frame.size.height - 50);
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    NSInteger selectedIndex = ((UITabBarController *)((UISplitViewController *) currentWindow.rootViewController).viewControllers[0]).selectedIndex;
                    ((UITabBarController *)((UISplitViewController *) currentWindow.rootViewController).viewControllers[0]).selectedIndex = (selectedIndex+1) % 5;
                    ((UITabBarController *)((UISplitViewController *) currentWindow.rootViewController).viewControllers[0]).selectedIndex = selectedIndex;
                }
                
            }];
        }
        
    });
    
}

- (void) orientationDidChange: (NSNotification *) notification
{
    if(IS_IPAD) return;
    [self updateStatusBarFrame];
    
}


- (UIWindow *) getCurrentWindow
{
    UIWindow * currentWindow = [UIApplication sharedApplication].keyWindow;
    
    if(!currentWindow || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        currentWindow = [UIApplication sharedApplication].windows[0];
    }
    
    return currentWindow;
}


- (void) setWindowColor
{
    UIWindow *currentWindow = [self getCurrentWindow];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callStatus == ASInAppCallStatusBarCallStatusOngoing || self.callStatus == ASInAppCallStatusBarCallStatusEnded) {
            currentWindow.backgroundColor = [UIColor redColor];
        } else if(self.callStatus == ASInAppCallStatusBarCallStatusPending) {
            currentWindow.backgroundColor = [UIColor greenColor];
        }
    });
}


#pragma mark - Public Methods

- (void) addInAppCallBarToWindow
{
    UIWindow *currentWindow = [self getCurrentWindow];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [currentWindow addSubview:self];
    
    [currentWindow addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:currentWindow attribute:NSLayoutAttributeTop multiplier:1 constant:25]];
    [currentWindow addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:25]];
    [currentWindow addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:currentWindow attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [currentWindow addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:currentWindow attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self updateStatusBarFrameWithReloadSelectedIndexTab];
    [self updateCenterLabelText];
    [self setWindowColor];
}


- (void) sendStatusBarToBack
{
    self.layer.zPosition = self.layer.zPosition - 10;
}



- (void) showASInAppCallStatusBar
{
    
    [self updateStatusBarFrame];
    [self updateCenterLabelText];
    [self setWindowColor];
    
}


- (void) resetASInAppCallStatusBar
{
    UIWindow *currentWindow = [self getCurrentWindow];
    UIView * rootVCView = currentWindow.rootViewController.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        
        currentWindow.backgroundColor = UIColorFromRGB(0x022940);
        rootVCView.backgroundColor = UIColorFromRGB(0x022940);
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [UIView animateWithDuration:0.15f
                animations:^{
                 rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 0, rootVCView.frame.size.width, currentWindow.frame.size.height);
                 if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                     if([currentWindow.rootViewController isKindOfClass:[UISplitViewController class]]){
                         NSInteger selectedIndex = ((UITabBarController *)((UISplitViewController *) currentWindow.rootViewController).viewControllers[0]).selectedIndex;
                         ((UITabBarController *)((UISplitViewController *) currentWindow.rootViewController).viewControllers[0]).selectedIndex = (selectedIndex+1) % 5;
                         ((UITabBarController *)((UISplitViewController *) currentWindow.rootViewController).viewControllers[0]).selectedIndex = selectedIndex;
                     }
                 }
             }];
        }
        else {
            [UIView animateWithDuration:0.15f animations:^{
                rootVCView.frame = CGRectMake(rootVCView.frame.origin.x, 0, rootVCView.frame.size.width, currentWindow.frame.size.height);
            }];
        }
    });
    
    self.returnViewController = nil;
    [self.callTimer invalidate];
    self.callTimer = nil;
    
    self.callStatus = ASInAppCallStatusBarCallStatusNone;
    self.currentTime = 0;
}



#pragma mark - TimerTargetWrapperDelegate Methods

- (void) timerDidFire:(NSTimer *)timer {
    
    if(self.callTimer == timer) {
        [self updateCenterLabelText];
    }
}


#pragma mark - UIInterfaceOrientation Status Checkers

- (BOOL) isUIInterfacePortrait {
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return NO;
    }
    return YES;
}


- (BOOL) isUIInterfaceLandscape {
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return YES;
    }
    return NO;
}
@end
