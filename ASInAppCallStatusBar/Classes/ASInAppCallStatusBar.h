//
//  InCallStatusBar.h
//  Noteabout-Chat
//
//  Created by Hanet on 11/24/16.
//  Copyright © 2016 Noteabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum ASInAppCallStatusBarAnimation: NSUInteger
{
    ASInAppCallStatusBarAnimationNone = 0,
    ASInAppCallStatusBarAnimationBlink = 1
    
} ASInAppCallStatusBarAnimation;

typedef enum ASInAppCallStatusBarCallStatus: NSUInteger
{
    ASInAppCallStatusBarCallStatusNone = 0,
    ASInAppCallStatusBarCallStatusPending = 1,
    ASInAppCallStatusBarCallStatusOngoing = 2,
    ASInAppCallStatusBarCallStatusEnded = 3
    
} ASInAppCallStatusBarCallStatus;


@interface ASInAppCallStatusBar : UIView

+ (instancetype) shared;

- (void) showWithSpiel: (NSString *) spiel withStartSecond: (int) second withStatus:(ASInAppCallStatusBarCallStatus) callStatus withTapViewController: (UIViewController *) vc;

- (void) changeStatusToOngoingWithStartTime:(int) startTime;

- (void) sendStatusBarToBack;
- (void) resetInAppCallStatusBar;

@end
