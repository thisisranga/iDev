//
//  HomeViewController.m
//  iDev
//
//  Created by rnallave on 3/6/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "ViewController.h"
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

//- (NSString *)getCurrentTimeStamp {
//    int precision = 4;
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    formatter.minimumFractionDigits = precision;
//    formatter.maximumFractionDigits = precision;
//    NSString *timeStamp = [formatter stringFromNumber:@([[NSDate date] timeIntervalSince1970])];
//    return timeStamp;
//}

-(void)send:(id)sender {

    // Build a query to match Chatmate user
    PFQuery *innerQuery = [PFUser query];
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
    
    double currentTimeStamp = [[NSDate date] timeIntervalSince1970];
    
    PFObject *messageDB = [PFObject objectWithClassName:@"MessageDB"];
    messageDB[@"message"] = self._query.text;
    messageDB[@"receipientId"] = @"sdudipala";
    messageDB[@"senderId"] = @"rnallave";
    messageDB[@"timeStamp"] = @(currentTimeStamp);
    [messageDB saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }];
    
    [self refreshChatView:self._query.text];
    
     self._query.text = @"";
}

-(void)welcomeScreen {
    ViewController *_welcomeScreen = [[ViewController alloc] init];
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDel.window setRootViewController:_welcomeScreen];
    [_welcomeScreen presentationController];
}

-(void)logOut:(id)sender {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PFUser logOut];
        dispatch_async( dispatch_get_main_queue(), ^{
            [self welcomeScreen];
        });
    });
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
    }
    
    //Calculate the expected size based on the font and linebreak mode of your label
    //FLT_MAX here simply means no constraint in height
    UILabel *_iDevMessage = [[UILabel alloc] initWithFrame:CGRectMake(10,self._yAxis,200,30)];
    _iDevMessage.numberOfLines = 0;
    _iDevMessage.text = message;
    _iDevMessage.backgroundColor = [UIColor whiteColor];
    [_iDevMessage sizeToFit];
    [self._chatView addSubview:_iDevMessage];
    self._firstTimePing = NO;
}

-(void)didReceiveNotifications:(NSDictionary *)notification {
    NSString *iDevMessage = [[notification objectForKey:@"aps"] objectForKey:@"alert"];
    NSLog(@"notification = %@", iDevMessage);
    [self refreshChatView:iDevMessage];
}

-(void)didReceiveNotificationFromParse:(NSDictionary *)notification {
    NSString *iDevMessage = [notification objectForKey:@"message"];
    NSLog(@"notification = %@", iDevMessage);
    [self refreshChatView:iDevMessage];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //    On iOS, you can add a pointer to this user to their associated Installation object:
    
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
    [[PFInstallation currentInstallation] saveEventually];
    
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
    UIBarButtonItem *rightRevealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out"
                                                                              style:UIBarButtonItemStyleBordered target:self action:@selector(logOut:)];
    
    rightRevealButtonItem.tintColor = SIGN_IN_BUTTON_BACKGROUND_COLOR;
    self.navigationItem.rightBarButtonItem = rightRevealButtonItem;
    
    
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
