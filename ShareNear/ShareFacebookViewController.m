//
//  ShareFacebookViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/14/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ShareFacebookViewController.h"

@interface ShareFacebookViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareUsingAPICallButton;
@property (weak, nonatomic) IBOutlet UIButton *updateStatusUsingAPICallButton;
@property (weak, nonatomic) IBOutlet UIButton *requestImageUploadButton;
@property (weak, nonatomic) IBOutlet UIButton *sharePhotoUsingOpenGraphButton;



@end

@implementation ShareFacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions



- (IBAction)shareUsingAPIButtonPressed:(id)sender {
    NSMutableDictionary *feedParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sharing Some Shit", @"name",
                                       @"iOS facebook SDK test", @"caption",
                                       @"Share using feed", @"description",
                               //        @"http://www.nba.com",@"link",
                                       @"http://i.imgur.com/IjiGurO.jpg",@"picture",
                                       nil];
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:feedParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                              } else {
                                  
                                  NSLog(@"%@", error.description);
                              }
                          }];
}



- (IBAction)updateStatusUsingAPICallButtonPressed:(id)sender {
    
    [FBRequestConnection startForPostStatusUpdate:@"User-generated status update."
                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                    if (!error) {
                                        // Status update posted successfully to Facebook
                                        NSLog(@"result: %@", result);
                                    } else {
                                        // An error occurred, we need to handle the error
                                        // See: https://developers.facebook.com/docs/ios/errors
                                        NSLog(@"%@", error.description);
                                    }
                                }];
}

- (IBAction)requestImageUploadButtonPressed:(id)sender {
    
   
    
    

}

- (IBAction)sharePhotoUsingOpenGraphButtonPressed:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)viewFacebookFeed:(id)sender {
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                              } else {
                                  
                                  NSLog(@"%@", error.description);
                              }
                          }];
}

- (IBAction)viewFacebookNewsfeed:(id)sender {
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/home"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"We get %lu of entries returned.", (unsigned long)[result[@"data"] count]);
                            //      NSLog(@"result: %@", result);
                                  
                                  
                                  [self showAlertWithTitle:@"Request Done" errorMessage:@"We got the news feed data"];
                                  
                              } else {
                                  
                                  NSLog(@"%@", error.description);
                              }
                          }];

}


# pragma mark - Helper Methods

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(void)showAlertWithTitle: (NSString *)title errorMessage: (NSString *) error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Dismiss", nil];
    
    [alert show];
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Get the image
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Dismiss the image picker off the screen
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // stage an image
    [FBRequestConnection startForUploadStagingResourceWithImage:image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            // Log the uri of the staged image
            NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
            
            // Further code to post the OG story goes here
            
        } else {
            // An error occurred
            NSLog(@"Error staging an image: %@", error);
        }
    }]; 
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
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
