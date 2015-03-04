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
@property(nonatomic, retain) UIButton *_signIn;
@end

@implementation ViewController

-(void)subscribe:(id)sender {
    NSLog(@"Thanks for registering with iDev Comminuty");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    __iDevTheme = [[UIImageView alloc] initWithFrame:self.view.bounds];
    __iDevTheme.image = [UIImage imageNamed:@"Background_View.png"];
    [self.view addSubview:__iDevTheme];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float sHeight = screenRect.size.height;
    float buttonWidth = 130;
    float buttonHeight = 45;
    float xyPadding = 10;
    
    __joinCommunity = [UIButton buttonWithType:UIButtonTypeSystem];
    __joinCommunity.frame = CGRectMake(xyPadding,sHeight-125,buttonWidth,buttonHeight);
    [__joinCommunity setBackgroundColor:JOIN_BUTTON_BACKGROUND_COLOR];
    [__joinCommunity setTitle:JOIN_COMMUNITY_BUTTON_TITLE forState:UIControlStateNormal];
    [__joinCommunity setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __joinCommunity.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    __joinCommunity.titleLabel.shadowColor = [UIColor blueColor];
    [__joinCommunity addTarget:self action:@selector(subscribe:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:__joinCommunity];
    
    __signIn = [UIButton buttonWithType:UIButtonTypeSystem];
    __signIn.frame = CGRectMake((sWidth-xyPadding)-buttonWidth,sHeight-125,buttonWidth,buttonHeight);
    [__signIn setBackgroundColor:SIGN_IN_BUTTON_BACKGROUND_COLOR];
    [__signIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [__signIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __signIn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    __signIn.titleLabel.shadowColor = [UIColor blueColor];
    [__signIn addTarget:self action:@selector(subscribe:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:__signIn];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
