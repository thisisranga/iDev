//
//  HomeViewController.m
//  iDev
//
//  Created by rnallave on 3/6/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "iDev.h"
@interface HomeViewController ()
@property (nonatomic, retain) UIView *_toolBar;
@property (nonatomic, retain) UITextField *_query;
@property (nonatomic, retain) UIScrollView *_chatView;
@property (nonatomic, retain) SWRevealViewController *_revealController;
@property (nonatomic, retain) UIButton *_send;
@property (nonatomic, assign) int _yAxis;
@property (nonatomic, assign) BOOL _firstTimePing;
@end

@implementation HomeViewController

-(void)send:(id)sender {
//    MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
//    [messageComposer setMessageComposeDelegate:self];
//    
//    if ([MFMessageComposeViewController canSendText])
//    {
//        NSArray *recipientsArray = [NSArray arrayWithObjects:@"18455327497",@"",nil];
//        [messageComposer setRecipients:recipientsArray];
//        [messageComposer setBody:self._query.text];
//        [self presentViewController:messageComposer animated:YES completion:nil];
//    }
//    else {
//        NSLog(@"Can't Open text");
//    }
    

    
//    On iOS, you can add a pointer to this user to their associated Installation object:
    
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
    [[PFInstallation currentInstallation] saveEventually];

    
    // Build a query to match users with a birthday today
    PFQuery *innerQuery = [PFUser query];
    
    // Use hasPrefix: to only match against the month/date
    [innerQuery whereKey:@"username" hasPrefix:@"sdudipala"];
    
    // Build the actual push notification target query
    PFQuery *query = [PFInstallation query];
    
    // only return Installations that belong to a User that
    // matches the innerQuery
    [query whereKey:@"user" matchesQuery:innerQuery];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setMessage:self._query.text];
    [push sendPushInBackground];
    [self refreshChatView:self._query.text];

    
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result  {
    
//    switch (result) {
//        case MessageComposeResultSent:
//            NSLog(@"Sent");
//            break;
//            
//        case MessageComposeResultFailed:
//            NSLog(@"Failed");
//            break;
//            
//        case MessageComposeResultCancelled:
//            NSLog(@"Cancelled");
//            break;
//            
//        default:
//            break;
//    }
}
-(void)revealToggle:(id)sender {
    [self._query resignFirstResponder];
    self._revealController= [self revealViewController];
    [self._revealController panGestureRecognizer];
    [self._revealController tapGestureRecognizer];
    [self._revealController revealToggle:nil];
}
-(void)refreshChatView:(NSString*)message {
    
   
    self._yAxis = self._yAxis + 30;
    
    if (!self._firstTimePing)
    {
        CGPoint bottomOffset = CGPointMake(0,self._yAxis-110);
        [self._chatView setContentOffset:bottomOffset animated:YES];
        NSLog(@"y axis value = %i", self._yAxis );
    }
    
    //Calculate the expected size based on the font and linebreak mode of your label
    //FLT_MAX here simply means no constraint in height
    UILabel *_iDevMessage = [[UILabel alloc] initWithFrame:CGRectMake(10,self._yAxis,200,30)];
    _iDevMessage.numberOfLines = 0;
    _iDevMessage.text = message;
    _iDevMessage.backgroundColor = [UIColor whiteColor];
    [_iDevMessage sizeToFit];
    [self._chatView addSubview:_iDevMessage];
    self._query.text = @"";
    self._firstTimePing = NO;
}
-(void)didReceiveNotifications:(NSDictionary *)notification {
   
    
    NSString *iDevMessage = [[notification objectForKey:@"aps"] objectForKey:@"alert"];
    NSLog(@"notification = %@", iDevMessage);
    [self refreshChatView:iDevMessage];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.delegate = self;
    
    self._yAxis = 60;
    self._firstTimePing = YES;
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
   
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    revealButtonItem.tintColor = SIGN_IN_BUTTON_BACKGROUND_COLOR;
    self.navigationController.navigationBar.barTintColor = HOME_VIEW_TOOL_BAR_COLOR;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.title = @"DashBoard";
    //    UIBarButtonItem *rightRevealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
    //                                                                              style:UIBarButtonItemStylePlain target:revealController action:@selector(rightRevealToggle:)];
    //
    //    self.navigationItem.rightBarButtonItem = rightRevealButtonItem;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float sHeight = screenRect.size.height;
    float toolBarHeight = 50;
    
    __chatView = [[UIScrollView alloc] init];
    __chatView.backgroundColor = [UIColor grayColor];
    __chatView.frame = CGRectMake(0,70,sWidth,sHeight-60);
    __chatView.contentSize = CGSizeMake(sWidth,1000);
    __chatView.showsVerticalScrollIndicator = YES;
    __chatView.scrollEnabled = YES;
    [self.view addSubview:__chatView];
    
    __toolBar = [[UIView alloc] initWithFrame:CGRectMake(0,sHeight-toolBarHeight,sWidth,toolBarHeight)];
    __toolBar.backgroundColor = HOME_VIEW_TOOL_BAR_COLOR;
    
    __query = [[UITextField alloc] initWithFrame:CGRectMake(5,5,sWidth-100,40)];
    __query.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Ask a question?" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    __query.textAlignment = NSTextAlignmentLeft;
    __query.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    __query.layer.cornerRadius = 0.2;
    __query.backgroundColor = [UIColor whiteColor];
    __query.delegate = self;
    [__query setBackgroundColor:[UIColor whiteColor]];
    [__query.layer setBorderColor:[UIColor clearColor].CGColor];
    [__query.layer setBorderWidth:1.0];
    [__query.layer setCornerRadius:12.0f];
    [__toolBar addSubview:__query];
    
    __send = [UIButton buttonWithType:UIButtonTypeSystem];
    __send.frame = CGRectMake(sWidth-100+10,5,90,40);
    [__send setBackgroundColor:SIGN_IN_BUTTON_BACKGROUND_COLOR];
    [__send setTitle:@"Send" forState:UIControlStateNormal];
    [__send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __send.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    __send.titleLabel.shadowColor = [UIColor blueColor];
    [__send addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [__toolBar addSubview:__send];
   
    [self.view addSubview:__toolBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    

}
-(void)dismissKeyboard {
    [self._query resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardWillShow {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float toolBarHeight = 50;
    // Animate the current view out of the way
    [UIView animateWithDuration:0.3f animations:^ {
    self._toolBar.frame = CGRectMake(0,265,sWidth,toolBarHeight);
    self._chatView.frame = CGRectMake(0,70,sWidth,190);
         }];
}
-(void)keyboardWillHide {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float sHeight = screenRect.size.height;
    float toolBarHeight = 50;
    // Animate the current view out of the way
    [UIView animateWithDuration:0.3f animations:^ {
    self._toolBar.frame= CGRectMake(0,sHeight-toolBarHeight,sWidth,toolBarHeight);
    self._chatView.frame = CGRectMake(0,70,sWidth,sHeight-50);
         }];
}
@end
