//
//  ChatViewController.m
//  iDev
//
//  Created by rnallave on 4/2/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "ChatViewController.h"
#import "SWRevealViewController.h"
#import "PTSMessagingCell.h"
#import <Parse/Parse.h>
#import "iDev.h"
@interface ChatViewController ()
@property (nonatomic, retain) SWRevealViewController *_revealController;
@property (nonatomic, retain) UIView *_toolBar;
@property (nonatomic, retain) UITextField *_query;
@property (nonatomic, retain) UIButton *_send;
@property (nonatomic, retain) NSMutableArray *_myMessages;
@property (nonatomic, assign) float _toolBarHeight;
@property (nonatomic, assign) float _toolBarXC;
@end

@implementation ChatViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self._myMessages = [[NSMutableArray alloc] init];
        self._toolBarHeight = 50;
        self._toolBarXC = 265;
    }
    return self;
}
-(void)send:(id)sender {
    if (self._query.text.length>0) {
        // Build a query to match Chatmate user
        PFQuery *innerQuery = [PFUser query];
        [innerQuery whereKey:@"username" hasPrefix:self._chatMateUserName];
        
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
            messageDB[@"receipientId"] = self._chatMateUserName;
            messageDB[@"senderId"] = self._userName;
            messageDB[@"timeStamp"] = @(currentTimeStamp);
            [messageDB saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }];
//        NSMutableString *inputString;
//        if ([self._myMessages count]!=0 && [self._myMessages count] % 2 == 1) {
//            inputString = [NSMutableString stringWithString:self._query.text];
//            [inputString insertString:@"me" atIndex:0];
//        }
//        else {
//            inputString = [NSMutableString stringWithString:self._query.text];
//            [inputString insertString:@"mate" atIndex:0];
//        }
        
        NSMutableString *inputString = [NSMutableString stringWithString:self._query.text];
        [inputString insertString:@"me" atIndex:0];
        [self._myMessages addObject:inputString];
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self._myMessages count]-1 inSection:0];
        NSArray *insertRows = [NSArray arrayWithObjects:indexPath, nil];
        [self._tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationNone];
        
        [self._tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];

        self._query.text = @"";
}
}
-(void)receive:(NSString*)chatMateMessage {
    
    NSMutableString *inputString = [NSMutableString stringWithString:chatMateMessage];
    [inputString insertString:@"mate" atIndex:0];
    
    [self._myMessages addObject:inputString];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self._myMessages count]-1 inSection:0];
    NSArray *insertRows = [NSArray arrayWithObjects:indexPath, nil];
    [self._tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationNone];
    
}
-(void)didReceiveNotifications:(NSDictionary *)notification {
    NSString *_chatMateMessage  = [[notification objectForKey:@"aps"] objectForKey:@"alert"];
    NSLog(@"notification = %@", _chatMateMessage);
    [self receive:_chatMateMessage];

}

-(void)didReceiveNotificationFromParse:(NSDictionary *)notification {
    NSString *_chatMateMessage  = [notification objectForKey:@"message"];
    NSLog(@"notification = %@", _chatMateMessage);
    [self receive:_chatMateMessage];
}

-(void)revealToggle:(id)sender {
    [self._query resignFirstResponder];
    self._revealController= [self revealViewController];
    [self._revealController panGestureRecognizer];
    [self._revealController tapGestureRecognizer];
    [self._revealController revealToggle:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
    [[PFInstallation currentInstallation] saveEventually];

    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    revealButtonItem.tintColor = SIGN_IN_BUTTON_BACKGROUND_COLOR;
    self.navigationController.navigationBar.barTintColor = HOME_VIEW_TOOL_BAR_COLOR;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.title = self._chatMateUserName;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.delegate = self;

    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float sHeight = screenRect.size.height;
    
    __tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,sWidth,sHeight-self._toolBarHeight)];
    __tableView.delegate = self;
    __tableView.dataSource = self;
    __tableView.scrollEnabled = YES;
    __tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:__tableView];
    
    
    __toolBar = [[UIView alloc] initWithFrame:CGRectMake(0,sHeight-self._toolBarHeight,sWidth,self._toolBarHeight)];
    __toolBar.backgroundColor = HOME_VIEW_TOOL_BAR_COLOR;
    
    __query = [[UITextField alloc] initWithFrame:CGRectMake(40,5,sWidth-100,40)];
    __query.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Text Message" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    __query.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
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
    __send.frame = CGRectMake(sWidth-60,5,60,40);
    [__send setTitle:@"Send" forState:UIControlStateNormal];
    [__send setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    self._toolBarHeight = self._toolBarHeight + 20;
    self._toolBarXC = self._toolBarXC-20;
    self._toolBar.frame = CGRectMake(0,self._toolBarXC ,sWidth,self._toolBarHeight);
    self._query.frame = CGRectMake(40,5,sWidth-100,self._toolBarHeight-10);
    return NO;
}
-(void)dismissKeyboard {
    [self._query resignFirstResponder];
}
-(void)keyboardWillShow {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    
    self._toolBar.frame = CGRectMake(0,265,sWidth,self._toolBarHeight);
    self._tableView.frame = CGRectMake(0,0,sWidth,265);

    if ([self._myMessages count]>1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self._myMessages count]-1 inSection:0];
        [self._tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
  
}
-(void)keyboardWillHide {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float sHeight = screenRect.size.height;
    
    self._toolBar.frame= CGRectMake(0,sHeight-self._toolBarHeight,sWidth,self._toolBarHeight);
    self._tableView.frame = CGRectMake(0,0,sWidth,sHeight-self._toolBarHeight);
    
    if ([self._myMessages count]>1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self._myMessages count]-1 inSection:0];
        [self._tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }

}
// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self._myMessages count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    CGSize messageSize = [PTSMessagingCell messageSize:[self._myMessages objectAtIndex:indexPath.row]];
    return messageSize.height + 2*[PTSMessagingCell textMarginVertical]+10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*This method sets up the table-view.*/
    
    static NSString *CellIdentifier = @"Cell";
    PTSMessagingCell *cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil)
    {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if([[self._myMessages objectAtIndex:indexPath.row] hasPrefix:@"me"]) {
        NSString *rawString = [self._myMessages objectAtIndex:indexPath.row];
        NSString *actualString = [rawString substringFromIndex:2];
        NSLog(@"elements of an array = %@",actualString);
//        cell.textLabel.text = actualString;
//        cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.messageLabel.text = actualString;
        cell.sent = YES;
      
    }
    else if ([[self._myMessages objectAtIndex:indexPath.row] hasPrefix:@"mate"])
    {
        NSString *rawString = [self._myMessages objectAtIndex:indexPath.row];
        NSString *actualString = [rawString substringFromIndex:4];
        NSLog(@"elements of an array = %@",actualString);
//        cell.textLabel.text = actualString;
//        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.messageLabel.text = actualString;
        cell.sent = NO;

    }
    return cell;
}
@end
