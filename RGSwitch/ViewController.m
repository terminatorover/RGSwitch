//
//  ViewController.m
//  RGSwitch
//
//  Created by Robera Geleta on 2/23/16.
//  Copyright © 2016 EnterWithBoldness. All rights reserved.
//

#import "ViewController.h"
#import "RGSwitch.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RGSwitch *switchView = [[RGSwitch alloc] initWithFrame:CGRectMake(0, 0, 10000, 90)];//to demonstare that the width value is ignored
    [self.view addSubview:switchView];
    switchView.center = self.view.center;
    self.view.backgroundColor = switchView.backgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
