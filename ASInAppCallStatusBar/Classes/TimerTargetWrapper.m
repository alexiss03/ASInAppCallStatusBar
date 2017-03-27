//
//  TimerTargetWrapper.m
//  Noteabout-Chat
//
//  Created by Hanet on 8/18/16.
//  Copyright © 2016 Noteabout. All rights reserved.
//

#import "TimerTargetWrapper.h"

@implementation TimerTargetWrapper

- (instancetype)initWithDelegate:(id<TimerTargetWrapperDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)timerFired:(NSTimer *)timer
{
    [self.delegate timerDidFire:timer];
}

@end
