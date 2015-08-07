//
//  ChatViewController.h
//  iDev
//
//  Created by rnallave on 4/2/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ChatViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,RemoteNotificationsDelegate>
@property(nonatomic, retain) NSString *_userName;
@property(nonatomic, retain) NSString *_chatMateUserName;
@property(nonatomic, retain) UITableView *_tableView;
@end
