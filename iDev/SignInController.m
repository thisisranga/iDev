//
//  SignInController.m
//  iDev
//
//  Created by rnallave on 3/5/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "SignInController.h"
#import <Parse/Parse.h>
#import "iDev.h"

@interface SignInController ()
@property(nonatomic, retain) UIView *_ContainerView;
@property(nonatomic, retain) UITextField *_emailID;
@property(nonatomic, retain) UITextField *_password;
@property(nonatomic, retain) UIButton *_SignIn;
@property(nonatomic, retain) UIButton *_dismiss;
@property(nonatomic, retain) UIActivityIndicatorView *_spinner;
@property(nonatomic, retain) UIView *_errorContainerView;
@end

@implementation SignInController

-(void)dismiss:(id)sender {
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
   if (self._emailID.text.length == 0 || !isEmailIdValid)
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
    
    self._errorContainerView = [[UIView alloc] initWithFrame:CGRectMake(xyPadding,100,sWidth-2*xyPadding,80)];
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
-(void)checkUserExistence
{
    PFQuery *query = [PFQuery queryWithClassName:@"ProfileInfo"];
    [query whereKey:@"emailId" equalTo:self._emailID.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            if (objects.count == 0)
            {
               [self.view addSubview:[self errorView:@"Invalid email id or password"]];
            }
            else
            {
                NSLog(@"Parse object Id = %@", [objects.lastObject objectForKey:@"password"]);
                NSString *currentPassword = [objects.lastObject objectForKey:@"password"];
                if ([currentPassword isEqualToString:self._password.text]) {
                    [self.view addSubview:[self errorView:@"Sign In Valid"]];
                }
                else
                {
                    [self.view addSubview:[self errorView:@"Invalid email id or password"]];
                }
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.view addSubview:[self errorView:@"We are experiencing some problems, please try again later"]];
        }
    }];
}

-(void)submit:(id)sender
{
    if ([self validateInputs])
    {
        [self._spinner startAnimating];
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self checkUserExistence];
            dispatch_async( dispatch_get_main_queue(), ^{
                nil;
            });
        });
        
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float sWidth = screenRect.size.width;
    float xyPadding = 10;
    
    // Do any additional setup after loading the view, typically from a nib.
    __ContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    __ContainerView.backgroundColor = SIGN_UP_VIEW_BACKGROUND_COLOR;
    
    __dismiss = [UIButton buttonWithType:UIButtonTypeSystem];
    __dismiss.frame = CGRectMake(sWidth-40,20,30,30);
    [__dismiss setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [__dismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __dismiss.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [__dismiss addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [__ContainerView addSubview:__dismiss];

    
    __emailID = [[UITextField alloc] initWithFrame:CGRectMake(xyPadding,60,sWidth-2*xyPadding,40)];
    __emailID.placeholder = @"Email ID";
    __emailID.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __emailID.delegate = self;
    __emailID.autocorrectionType = UITextAutocorrectionTypeNo;
    __emailID.clearButtonMode = YES;
    [__emailID becomeFirstResponder];
    [__ContainerView addSubview:__emailID];
    
    __password = [[UITextField alloc] initWithFrame:CGRectMake(xyPadding,100,sWidth-2*xyPadding,40)];
    __password.placeholder = @"Enter Password";
    __password.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __password.delegate = self;
    __password.autocorrectionType = UITextAutocorrectionTypeNo;
    __password.clearButtonMode = YES;
    __password.secureTextEntry = YES;
    [__ContainerView addSubview:__password];
    
    __spinner = [[UIActivityIndicatorView alloc]
                 initWithFrame:CGRectMake((sWidth-20)/2,150,20,20)];
    [__spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    __spinner.color = [UIColor whiteColor];
    __spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [__ContainerView addSubview:__spinner];
    
    __SignIn = [UIButton buttonWithType:UIButtonTypeSystem];
    __SignIn.frame = CGRectMake(xyPadding,180,sWidth-2*xyPadding,45);
    [__SignIn setBackgroundColor:SIGN_IN_BUTTON_BACKGROUND_COLOR];
    [__SignIn setTitle:SIGN_IN_BUTTON_TITLE forState:UIControlStateNormal];
    [__SignIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __SignIn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    __SignIn.titleLabel.shadowColor = [UIColor blueColor];
    [__SignIn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [__ContainerView addSubview:__SignIn];
    [self.view addSubview:__ContainerView];
    
    [self.view addSubview:__ContainerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
