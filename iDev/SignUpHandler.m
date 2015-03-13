//
//  SignUpHandler.m
//  iDev
//
//  Created by rnallave on 3/3/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "SignUpHandler.h"
#import <Parse/Parse.h>
#import "iDev.h"

@interface SignUpHandler ()
@property(nonatomic, retain) UIView *_ContainerView;
@property(nonatomic, retain) UITextField *_fullName;
@property(nonatomic, retain) UITextField *_userName;
@property(nonatomic, retain) UITextField *_emailID;
@property(nonatomic, retain) UITextField *_password;
@property(nonatomic, retain) UITextField *_confirmPassword;
@property(nonatomic, retain) UIButton *_joinNow;
@property(nonatomic, retain) UIButton *_dismiss;
@property(nonatomic, retain) UIActivityIndicatorView *_spinner;
@property(nonatomic, retain) UIView *_errorContainerView;
@property(nonatomic, retain) UILabel *_disclaimer;
@end

@implementation SignUpHandler

- (void)briteValidateUserEmail
{
    NSString *url = [NSString stringWithFormat:@"https://bpi.briteverify.com/emails.json?address=%@&apikey=13e28caa-9517-4241-9077-d283ba46992f",self._emailID.text];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response;
    NSError* error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 200)
    {
        NSDictionary *profile = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error];
        // Did API return valid dataset?
        if ([[profile objectForKey:@"status"] isEqualToString:@"valid"])
        {
            [self saveUserProfileInfo];
            NSLog(@"Email id Verification response = %@", profile);
        }
        else
        {
            
            [self.view addSubview:[self errorView:@"Invalid email id"]];
        
            
        }
        
    }
    else
    {
#if DEBUG
        NSLog(@"Profile API Error = %@", error);
#endif
        [self.view addSubview:[self errorView:@"Unable to verify email id, please use other email id."]];
    }
}
-(void)dismissErrorView:(id)sender
{
    [self._errorContainerView removeFromSuperview];
}
-(UIView *)errorView:(NSString*)errorMessage;
{
    [self._errorContainerView removeFromSuperview];
    [self._spinner stopAnimating];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float xyPadding = 20;
    
    self._errorContainerView = [[UIView alloc] initWithFrame:CGRectMake(xyPadding,170,sWidth-2*xyPadding,80)];
    self._errorContainerView.backgroundColor = [UIColor blackColor];
    [self._errorContainerView setAlpha:0.75];
    
    __dismiss = [UIButton buttonWithType:UIButtonTypeSystem];
    __dismiss.frame = CGRectMake((sWidth-2*xyPadding-30)/2,10,30,30);
    [__dismiss setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [__dismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __dismiss.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [__dismiss addTarget:self action:@selector(dismissErrorView:) forControlEvents:UIControlEventTouchUpInside];
    [self._errorContainerView addSubview:__dismiss];

    
    UILabel *error = [[UILabel alloc] initWithFrame:CGRectMake(10,40,sWidth-2*xyPadding-10,30)];
    error.text = errorMessage;
    error.textColor = [UIColor whiteColor];
    error.textAlignment = NSTextAlignmentCenter;
    [self._errorContainerView addSubview:error];
    return self._errorContainerView;
}

-(BOOL) NSStringIsValidEmail:(NSString *)emailString
{
    BOOL strictFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = strictFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

-(BOOL)validateInputs
{
    BOOL isEmailIdValid = [self NSStringIsValidEmail:self._emailID.text];
    if (self._fullName.text.length == 0)
    {
        [self.view addSubview:[self errorView:@"Please enter your first name"]];
        return NO;
    }
    else if (self._userName.text.length == 0)
    {
        [self.view addSubview:[self errorView:@"Please enter your last name"]];
        return NO;
    }
    else if (self._emailID.text.length == 0 || !isEmailIdValid)
    {
        [self.view addSubview:[self errorView:@"Please enter a valid email"]];
        return NO;
    }
    else if (self._password.text.length == 0) {
        [self.view addSubview:[self errorView:@"Please enter a password"]];
        return NO;
    }
    return YES;
}
-(void)saveUserProfileInfo {
    PFUser *iDevUser = [PFUser user];
    iDevUser.username = self._userName.text;
    iDevUser.email = self._emailID.text;
    iDevUser.password = self._password.text;
    [iDevUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.view addSubview:[self errorView:@"Regsitration Successful"]];
            [self reloadInputViews];
        } else {
            // There was a problem, check error.description
            [self errorView:@"Registration Failure, please try again."];
        }
}];
}
//-(void)checkUserExistence
//{
//    PFQuery *query = [PFQuery queryWithClassName:@"ProfileInfo"];
//    [query whereKey:@"emailId" equalTo:self._emailID.text];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
//            if (objects.count == 0)
//            {
//                 [self saveUserProfileInfo];
//            }
//            else
//            {
//                [self.view addSubview:[self errorView:@"This email id is already registered with iDev"]];
//                [self reloadInputViews];
//                
//            }
//           
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//}
-(void)reloadInputViews {
    [self._spinner stopAnimating];
    self._fullName.text = @"";
    self._userName.text = @"";
    self._emailID.text = @"";
    self._password.text = @"";
    [self._fullName becomeFirstResponder];
}
-(void)submit:(id)sender
{
    if ([self validateInputs])
    {
        [self._spinner startAnimating];
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self briteValidateUserEmail];
            dispatch_async( dispatch_get_main_queue(), ^{
                nil;
            });
        });

        
    }
}
-(void)dismiss:(id)sender {
    
    [self.view endEditing:YES];
    // Animate the current view out of the way
    [UIView animateWithDuration:0.3f animations:^ {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float xyPadding = 10;
    
    // Do any additional setup after loading the view, typically from a nib.
    __ContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    __ContainerView.backgroundColor = [UIColor grayColor];
    
    __dismiss = [UIButton buttonWithType:UIButtonTypeSystem];
    __dismiss.frame = CGRectMake(sWidth-40,20,30,30);
    [__dismiss setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [__dismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __dismiss.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [__dismiss addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [__ContainerView addSubview:__dismiss];
    
    __fullName = [[UITextField alloc] initWithFrame:CGRectMake(xyPadding,50,sWidth-2*xyPadding,40)];
    __fullName.placeholder = @"Full Name";
    __fullName.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    [__fullName becomeFirstResponder];
    __fullName.delegate = self;
    __fullName.autocorrectionType = UITextAutocorrectionTypeNo;
    __fullName.autocapitalizationType = NO;
    __fullName.clearButtonMode = YES;
    [__ContainerView addSubview:__fullName];
    
    __emailID = [[UITextField alloc] initWithFrame:CGRectMake(xyPadding,91,sWidth-2*xyPadding,40)];
    __emailID.placeholder = @"Email ID";
    __emailID.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __emailID.delegate = self;
    __emailID.autocorrectionType = UITextAutocorrectionTypeNo;
    __emailID.autocapitalizationType = NO;
    __emailID.clearButtonMode = YES;
    [__ContainerView addSubview:__emailID];
    
    __userName = [[UITextField alloc] initWithFrame:CGRectMake(xyPadding,132,sWidth-2*xyPadding,40)];
    __userName.placeholder = @"Create Username";
    __userName.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __userName.delegate = self;
    __userName.autocorrectionType = UITextAutocorrectionTypeNo;
    __userName.autocapitalizationType = NO;
    __userName.clearButtonMode = YES;
    [__ContainerView addSubview:__userName];
    
    __password = [[UITextField alloc] initWithFrame:CGRectMake(xyPadding,173,sWidth-2*xyPadding,40)];
    __password.placeholder = @"Create Password";
    __password.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __password.delegate = self;
    __password.autocorrectionType = UITextAutocorrectionTypeNo;
    __password.autocapitalizationType = NO;
    __password.clearButtonMode = YES;
    __password.secureTextEntry = YES;
    [__ContainerView addSubview:__password];
    
    __spinner = [[UIActivityIndicatorView alloc]
                 initWithFrame:CGRectMake((sWidth-20)/2,260,20,20)];
    [__spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    __spinner.color = [UIColor whiteColor];
    __spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [__ContainerView addSubview:__spinner];
    
    __disclaimer = [[UILabel alloc] initWithFrame:CGRectMake(2*xyPadding,220,sWidth-4*xyPadding,40)];
    __disclaimer.text = @"By clicking Join Now, you aggree to iDev's User\n Aggreement, Privacy Policy, and Cookie Policy";
    __disclaimer.font = [UIFont systemFontOfSize:12.0];
    __disclaimer.textAlignment = NSTextAlignmentCenter;
    __disclaimer.textColor = [UIColor whiteColor];
    __disclaimer.lineBreakMode = YES;
    __disclaimer.numberOfLines = 0;
    [__ContainerView addSubview:__disclaimer];
    
    __joinNow = [UIButton buttonWithType:UIButtonTypeSystem];
    __joinNow.frame = CGRectMake(xyPadding,290,sWidth-2*xyPadding,45);
    [__joinNow setBackgroundColor:SIGN_IN_BUTTON_BACKGROUND_COLOR];
    [__joinNow setTitle:JOIN_COMMUNITY_BUTTON_TITLE forState:UIControlStateNormal];
    [__joinNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __joinNow.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    __joinNow.titleLabel.shadowColor = [UIColor blueColor];
    [__joinNow addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [__ContainerView addSubview:__joinNow];
    [self.view addSubview:__ContainerView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
