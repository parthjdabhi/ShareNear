//
//  LoginViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/4/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"

@interface LoginViewController () <UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityIndicator.hidden = YES;
    
}

- (void) viewDidAppear:(BOOL)animated{
    animated = NO;
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
            [self updateUserInformation];
            
            [self saveUserToInstallation];
            
            [self performSegueWithIdentifier:@"LoginToTab"
                                      sender:self];
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)loginWithFacebookButton:(UIButton *)sender {
    
    self.activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    NSArray *permissions = @[ @"user_about_me", @"user_interests",@"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details", @"user_friends", @"publish_actions", @"read_stream"];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden = YES;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
            
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            [self updateUserInformation];
            [self saveUserToInstallation];
            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
        } else {
            NSLog(@"User logged in through Facebook!");
            [self updateUserInformation];
            [self saveUserToInstallation];
            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
        }
    }];
    
}

- (IBAction)signUpButtonPressed:(UIButton *)sender {
    
    NSLog(@"Forward to sign up page");
    
}

- (IBAction)loginButtonPressed:(id)sender {
    NSLog(@"Login button pressed");
    
    self.activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [PFUser logInWithUsernameInBackground:_usernameTextField.text  password:_passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        
                                        [_activityIndicator stopAnimating];
                                        _activityIndicator.hidden = YES;
                                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                        
                                        if (user) {
                                            // Do stuff after successful login.
                                            NSLog(@"Successfully logged in using ShareNear account!");
                                            [self saveUserToInstallation];
                                            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
                                        } else {
                                            // The login failed. Check error to see why.
                                            if (error){
                                                NSLog(@"Loggin failed with error: %@", error.description);
                                            } else{
                                                NSLog(@"loggin failed without error info.");
                                            }
                                        }
                                    }];
    
}



#pragma mark - Helper Method

-(void)updateUserInformation{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
   //     NSLog(@"RESULT:\n%@", result);
        
        if (!error){
    //        NSLog(@"Result: \n%@", result);
            
            NSDictionary *userDictionary = (NSDictionary *)result;
            // create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",facebookID]];
            
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
            if ([pictureURL absoluteString]){
                userProfile[kUserProfilePictureURL] = [pictureURL absoluteString];
            }
            if (userDictionary[@"name"]){
                userProfile[kUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]){
                userProfile[kUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            // embbed dictionary
            if (userDictionary[@"location"][@"name"]){
                userProfile[kUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]){
                userProfile[kUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]){
                userProfile[kUserProfileBirthdayKey] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                userProfile[kUserProfileAgeKey] = @(age);
            }
            if (userDictionary[@"interested_in"]){
                userProfile[kUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            if (userDictionary[@"relationship_status"]){
                userProfile[kUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            if (userDictionary[@"public_actions"]){
                userProfile[kUserProfilePublishActionsKey] = userDictionary[@"publish_actions"];
            }
            if (userDictionary[@"read_stream"]){
                userProfile[@"readStream"] = userDictionary[@"read_stream"];
            }
            
            
            
            [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
            
            
            // request Facebook Friend List
            [self requestFacebookFriendList];
            
            
            
        }
        else {
            NSLog(@"ERROR in Facebook request: %@", error);
        }
    }];
}

- (void)uploadPFFileToParse:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData){
        NSLog(@"imageData was not found");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kPhotoUserKey];
            [photo setObject:photoFile forKey:kPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    NSLog(@"Photo saved successfully");
                }
                else{
                    NSLog(@"error: %@", [error description]);
                }
            }];
        }
    }];
}

-(void)requestImage{
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0){
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc]init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kUserProfileKey][kUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
            if (!urlConnection){
                NSLog(@"Failed to Download Picture");
            }
        }
    }];
}

-(void)requestFacebookFriendList{
    FBRequest *friendListRequest = [FBRequest requestForMyFriends];
    [friendListRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error){
      //      NSLog(@"friend request result: \n%@", result[@"data"]);
            
            
            
        }
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

-(void)saveUserToInstallation{
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser]
                                             forKey:@"user"];
    [[PFInstallation currentInstallation] saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded){
      //      NSLog(@"Successfully save user to installation");
        }
    }];
}

#pragma mark - Keyboard Releasing

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextFeildDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    }
    
}
*/

@end


