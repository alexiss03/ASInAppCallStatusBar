//
//  InCallStatusBar.h
//  Noteabout-Chat
//
//  Created by Hanet on 11/24/16.
//  Copyright © 2016 Noteabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ASInAppCallStatusBar : UIView

+ (instancetype) shared;

- (void) showWithSpiel: (NSString *) spiel withStartSecond: (int) second withTapViewController: (UIViewController *) vc;

- (void) hideInAppCallStatusBar;

@end
