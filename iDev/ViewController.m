//
//  ViewController.m
//  iDev
//
//  Created by rnallave on 3/2/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "ViewController.h"
#import "SignUpHandler.h"
#import "SignInController.h"
#import "iDev.h"

@interface ViewController () 
@property(nonatomic, retain) UILabel *_iDevTitle;
@property(nonatomic, retain) UIImageView *_iDevEssence;
@property(nonatomic, retain) UIButton *_joinCommunity;
@property(nonatomic, retain) UIButton *_signIn;
@end

@implementation ViewController

-(void)joinNow:(id)sender {
    SignUpHandler *signUpView = [[SignUpHandler alloc] init];
    [self presentViewController:signUpView animated:YES completion:nil];
}
-(void)signIn:(id)sender {
    SignInController *signIn = [[SignInController alloc] init];
    [self presentViewController:signIn animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float buttonWidth = sWidth-20;
    float buttonHeight = 40;
    float xyPadding = 10;
    
    __iDevTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,20,sWidth,90)];
    __iDevTitle.text = @"looking to connect with....\nlike minded professionals \nyour in the right place!";
    __iDevTitle.textColor = [UIColor grayColor];
    __iDevTitle.font = [UIFont fontWithName:@"Baskerville-BoldItalic" size:20.0];
    __iDevTitle.lineBreakMode = YES;
    __iDevTitle.numberOfLines = 0;
    [self.view addSubview:__iDevTitle];
    
    NSArray *animationFrames = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"instant_messaging.png"],
                                [UIImage imageNamed:@"sharing_ideas.png"],
                                [UIImage imageNamed:@"Networking.png"],
                                nil];
    
    __iDevEssence = [[UIImageView alloc] initWithFrame:CGRectMake((sWidth-256)/2,120,256,150)];
    __iDevEssence.animationImages = animationFrames;
    // all frames will execute in 1.75 seconds
    __iDevEssence.animationDuration = 3.0;
    // repeat the animation forever
    __iDevEssence.animationRepeatCount = 0;
    [self.view addSubview:__iDevEssence];
    [__iDevEssence startAnimating];
    
    __joinCommunity = [UIButton buttonWithType:UIButtonTypeSystem];
    __joinCommunity.frame = CGRectMake(xyPadding,300,buttonWidth,buttonHeight);
    [__joinCommunity setBackgroundColor:JOIN_BUTTON_BACKGROUND_COLOR];
    [__joinCommunity setTitle:JOIN_COMMUNITY_BUTTON_TITLE forState:UIControlStateNormal];
    [__joinCommunity setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __joinCommunity.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    __joinCommunity.titleLabel.shadowColor = [UIColor blueColor];
    [__joinCommunity addTarget:self action:@selector(joinNow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:__joinCommunity];
    
    __signIn = [UIButton buttonWithType:UIButtonTypeSystem];
    __signIn.frame = CGRectMake((sWidth-xyPadding)-buttonWidth,350,buttonWidth,buttonHeight);
    [__signIn setBackgroundColor:SIGN_IN_BUTTON_BACKGROUND_COLOR];
    [__signIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [__signIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __signIn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    __signIn.titleLabel.shadowColor = [UIColor blueColor];
    [__signIn addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:__signIn];
    
    __iDevEssence = [[UIImageView alloc] initWithFrame:CGRectMake((sWidth-24)/2,420,24,24)];
    __iDevEssence.image = [UIImage imageNamed:@"firebird-logo-48.png"];
    [self.view addSubview:__iDevEssence];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
