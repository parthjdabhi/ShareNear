//
//  LoginViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/4/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

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
            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - IBActions

- (IBAction)loginWithFacebookButton:(UIButton *)sender {
    
    self.activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    
    NSArray *permissions = @[ @"user_about_me", @"user_interests",@"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden = YES;
        
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
            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
        } else {
            NSLog(@"User logged in through Facebook!");
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
        }
    }];
    
}

#pragma mark - Helper Method

-(void)updateUserInformation{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
   //     NSLog(@"RESULT:\n%@", result);
        
        if (!error){
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
            
            
            
            [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

//- (void)_presentUserDetailsViewControllerAnimated:(BOOL)animated {
//    UserDetailsViewController *detailsViewController = [[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    [self.navigationController pushViewController:detailsViewController animated:animated];
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    }
    
}
*/

@end


