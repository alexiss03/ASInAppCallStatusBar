//
//  ViewController.m
//  Sample-InAppCallStatusBar
//
//  Created by Hanet on 11/27/16.
//  Copyright © 2016 Hanet. All rights reserved.
//

#import "ViewController.h"
#import <ASInAppCallStatusBar/ASInAppCallStatusBar.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ASInAppCallStatusBar shared] showWithSpiel:@"Call ongoing " withStartSecond:0 withStatus:ASInAppCallStatusBarCallStatusOngoing withTapViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnTapped:(id)sender {
    [[ASInAppCallStatusBar shared] sendStatusBarToBack];
}


@end
