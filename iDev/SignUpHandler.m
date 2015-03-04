//
//  SignUpHandler.m
//  iDev
//
//  Created by rnallave on 3/3/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "SignUpHandler.h"
#import "iDev.h"

@interface SignUpHandler ()
@property(nonatomic, retain) UIView *_ContainerView;
@property(nonatomic, retain) UITextField *_firstName;
@property(nonatomic, retain) UITextField *_lastName;
@property(nonatomic, retain) UITextField *_emailID;
@property(nonatomic, retain) UITextField *_password;
@property(nonatomic, retain) UITextField *_confirmPassword;
@property(nonatomic, retain) UIButton *_joinNow;
@property(nonatomic, retain) UIButton *_dismiss;
@property(nonatomic, retain) UIActivityIndicatorView *_spinner;
@property(nonatomic, retain) UIView *_errorContainerView;
@end

@implementation SignUpHandler

- (void)briteValidateUserEmail
{
    NSString *url = [NSString stringWithFormat:@"https://bpi.briteverify.com/emails.json?address=%@&apikey=13e28caa-9517-4241-9077-d283ba46992f",self._emailID.text];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response;
    NSError* error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 200)
    {
        NSDictionary *profile = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error];
        // Did API return valid dataset?
        if (profile != nil && [profile count] != 0)
        {
            NSLog(@"Email id Verification response = %@", profile);
            NSLog(@"Thanks for registering with iDev Community");
        }
        
    }
    else {
#if DEBUG
        NSLog(@"Profile API Error = %@", error);
#endif
    }
}
-(void)dismissErrorView:(id)sender {
    [self._errorContainerView removeFromSuperview];
}
-(UIView *)errorView:(NSString*)errorMessage;
{
    [self._errorContainerView removeFromSuperview];
    self._errorContainerView = [[UIView alloc] initWithFrame:CGRectMake(20,170,280,80)];
    self._errorContainerView.backgroundColor = [UIColor blackColor];
    [self._errorContainerView setAlpha:0.75];
    
    __dismiss = [UIButton buttonWithType:UIButtonTypeSystem];
    __dismiss.frame = CGRectMake(125,10,30,30);
    [__dismiss setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [__dismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __dismiss.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [__dismiss addTarget:self action:@selector(dismissErrorView:) forControlEvents:UIControlEventTouchUpInside];
    [self._errorContainerView addSubview:__dismiss];

    
    UILabel *error = [[UILabel alloc] initWithFrame:CGRectMake(10,40,260,30)];
    error.text = errorMessage;
    error.textColor = [UIColor whiteColor];
    error.textAlignment = NSTextAlignmentCenter;
    [self._errorContainerView addSubview:error];
    return self._errorContainerView;
}
-(BOOL)validateInputs
{
    if (self._firstName.text.length == 0)
    {
        [self.view addSubview:[self errorView:@"Please enter your first name"]];
        return NO;
    }
    else if (self._lastName.text.length == 0)
    {
        [self.view addSubview:[self errorView:@"Please enter your last name"]];
        return NO;
    }
    else if (self._emailID.text.length == 0)
    {
        [self.view addSubview:[self errorView:@"Please enter your email"]];
        return NO;
    }
    else if (self._password.text.length == 0) {
        [self.view addSubview:[self errorView:@"Please enter a password"]];
        return NO;
    }
    return YES;
}
-(void)submit:(id)sender
{
    if ([self validateInputs]) {
        [self._spinner startAnimating];
        // Dispatching the BriteValidate API call as asychronous call to make UI responsive.
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self briteValidateUserEmail];
            dispatch_async( dispatch_get_main_queue(), ^{
                [self._spinner stopAnimating];
            });
        });

    }
}
-(void)dismiss:(id)sender {
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    __ContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    __ContainerView.backgroundColor = SIGN_UP_VIEW_BACKGROUND_COLOR;
    
    __dismiss = [UIButton buttonWithType:UIButtonTypeSystem];
    __dismiss.frame = CGRectMake(280,20,30,30);
    [__dismiss setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [__dismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    __dismiss.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [__dismiss addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [__ContainerView addSubview:__dismiss];
    
    __firstName = [[UITextField alloc] initWithFrame:CGRectMake(10,50,300,40)];
    __firstName.placeholder = @"First Name";
    __firstName.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    [__firstName becomeFirstResponder];
    __firstName.delegate = self;
    __firstName.autocorrectionType = UITextAutocorrectionTypeNo;
    __firstName.clearButtonMode = YES;
    [__ContainerView addSubview:__firstName];
    
    __lastName = [[UITextField alloc] initWithFrame:CGRectMake(10,90,300,40)];
    __lastName.placeholder = @"Last Name";
    __lastName.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __lastName.delegate = self;
    __lastName.autocorrectionType = UITextAutocorrectionTypeNo;
    __lastName.clearButtonMode = YES;
    [__ContainerView addSubview:__lastName];
    
    __emailID = [[UITextField alloc] initWithFrame:CGRectMake(10,130,300,40)];
    __emailID.placeholder = @"Email ID";
    __emailID.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __emailID.delegate = self;
    __emailID.autocorrectionType = UITextAutocorrectionTypeNo;
    __emailID.clearButtonMode = YES;
    [__ContainerView addSubview:__emailID];
    
    __password = [[UITextField alloc] initWithFrame:CGRectMake(10,170,300,40)];
    __password.placeholder = @"Create password";
    __password.backgroundColor = SIGN_UP_TEXT_FEILD_BACKGROUND_COLOR;
    __password.delegate = self;
    __password.autocorrectionType = UITextAutocorrectionTypeNo;
    __password.clearButtonMode = YES;
    [__ContainerView addSubview:__password];
    
    __spinner = [[UIActivityIndicatorView alloc]
                 initWithFrame:CGRectMake(145,240,20,20)];
    [__spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    __spinner.color = [UIColor whiteColor];
    __spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [__ContainerView addSubview:__spinner];
    
    __joinNow = [UIButton buttonWithType:UIButtonTypeSystem];
    __joinNow.frame = CGRectMake(10,290,300,45);
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
