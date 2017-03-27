//
//  TimerTargetWrapper.h
//  Noteabout-Chat
//
//  Created by Hanet on 8/18/16.
//  Copyright © 2016 Noteabout. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimerTargetWrapperDelegate <NSObject>

- (void)timerDidFire:(NSTimer *)timer;

@end

@interface TimerTargetWrapper : NSObject

@property (weak, nonatomic) id<TimerTargetWrapperDelegate> delegate;

- (instancetype)initWithDelegate:(id<TimerTargetWrapperDelegate>)delegate;

- (void)timerFired:(NSTimer *)timer;

@end

