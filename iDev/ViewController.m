//
//  ViewController.m
//  iDev
//
//  Created by rnallave on 3/2/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "ViewController.h"
#import "iDev.h"

@interface ViewController ()
@property(nonatomic, retain) UIImageView *_iDevTheme;
@property(nonatomic, retain) UIButton *_joinCommunity;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    __iDevTheme = [[UIImageView alloc] initWithFrame:self.view.bounds];
    __iDevTheme.image = [UIImage imageNamed:@"LaunchImage"];
    [self.view addSubview:__iDevTheme];
    
    __joinCommunity = [UIButton buttonWithType:UIButtonTypeCustom];
    __joinCommunity.frame = CGRectMake(100,500,175,30);
    [__joinCommunity setTitle:JOIN_COMMUNITY_BUTTON_TITLE forState:UIControlStateNormal];
    [__joinCommunity setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:__joinCommunity];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
