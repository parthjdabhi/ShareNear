//
//  SignUpViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/16/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController () <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)signupButtonPressed:(id)sender {
    NSString *errorMessage = @"";
    
    if ([_usernameTextField.text isEqualToString:@""] || [_passwordTextField.text isEqualToString:@""]){
        errorMessage = @"Please enter valid username and password";
    } else {
        // check duplicate username
    }
    
    
    if (![errorMessage isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else {
        
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        PFUser *user = [PFUser user];
        user.username = _usernameTextField.text;
        user.password = _passwordTextField.text;
        //    user.email = @"email@example.com";
        
        // other fields can be set just like with PFObject
        //    user[@"phone"] = @"415-392-0202";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            if (!error) {
                // Hooray! Let them use the app now.
                NSLog(@"User signed up successfully!");
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                NSString *errorString = [error userInfo][@"error"];
                // Show the errorString somewhere and let the user try again.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
        }];
        
    }

}

#pragma mark - Keyboard Release

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
