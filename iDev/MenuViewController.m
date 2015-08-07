//
//  MenuViewController.m
//  iDev
//
//  Created by rnallave on 3/6/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "ChatViewController.h"
#import <Parse/Parse.h>
#import "iDev.h"
@interface MenuViewController ()
@property (nonatomic, retain) NSArray *usersList;
@end

@implementation MenuViewController

- (void)retrieveMembersFromParse {
    PFQuery *userQuery = [PFUser query];
    [userQuery orderByAscending:@"username"];
    [userQuery whereKey:@"username" notEqualTo:self._userName];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        NSArray *userArray = [users mutableCopy];
        self.usersList = userArray;
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Members";
    self.navigationController.navigationBar.barTintColor = HOME_VIEW_TOOL_BAR_COLOR;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self retrieveMembersFromParse];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    
    return [self.usersList count];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section){
        case 0:
            if(indexPath.row ==0)
                return 150.0;
            else
                return 40.0;
        case 1:
            return 40;
        default:
            return 40.0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Your Profile";
            break;
        case 1:
            sectionName = @"Others";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    view.tintColor = SIGN_IN_BUTTON_BACKGROUND_COLOR;
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    switch (indexPath.section)
    {
        case 0:
            if (indexPath.row ==0)
            {
                UIImageView *_profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,120,100)];
                _profileImage.backgroundColor = [UIColor grayColor];
                _profileImage.image = [UIImage imageNamed:@"profile.png"];
                [cell.contentView addSubview:_profileImage];
                UILabel *_userName = [[UILabel alloc] initWithFrame:CGRectMake(10,125,200,20)];
                _userName.text = self._userName;
                _userName.textAlignment = NSTextAlignmentLeft;
                _userName.textColor = [UIColor blackColor];
                [cell.contentView addSubview:_userName];
            }
            break;
        case 1:
                cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.usersList objectAtIndex:indexPath.row] objectForKey:@"username"]];
            
            break;
            
        default:
            break;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==1) {
        // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
        SWRevealViewController *revealController = self.revealViewController;
        [self.revealViewController revealToggleAnimated:YES];
        ChatViewController *chatView = [[ChatViewController alloc] init];
        chatView._userName = self._userName;
        chatView._chatMateUserName = [[self.usersList objectAtIndex:indexPath.row] objectForKey:@"username"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatView];
        [revealController setFrontViewController:navigationController animated:YES];
 }
    
}

@end
