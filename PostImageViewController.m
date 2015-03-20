//
//  PostImageViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/17/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "PostImageViewController.h"

@interface PostImageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property BOOL photoSelected;

@end

@implementation PostImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // reset post page
    _photoSelected = NO;
    _postImageView.image = [UIImage imageNamed:@"User_Image"];
    _inputTextField.text = @"Say something...";
    
    _inputTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction)chooseFromExistingButtonPressed:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)postButtonPressed:(id)sender {
    
    NSString *error = @"";
    
    if (_photoSelected == NO){
        error = @"Please select an image to post";
    } else if ([_inputTextField.text isEqualToString:@""]){
        error = @"Please enter a message";
    }
    
    if (![error isEqualToString:@""]){
        [self showAlertWithTitle:@"Error During Post Image" errorMessage:error];
    } else {
        
        [self uploadPFFileToParseAndPost:_postImageView.image];
    }
    
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_sync(dispatch_get_global_queue(0, 0),^{
        _postImageView.image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        _photoSelected = YES;
    });
    
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Helper Methods

-(void)showAlertWithTitle: (NSString *)title errorMessage: (NSString *) error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Dismiss", nil];
    
    [alert show];
}

- (void)uploadPFFileToParseAndPost:(UIImage *)image{
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
                    
                    
                    PFObject *post = [PFObject objectWithClassName:@"Post"];
                    post[@"user"] = [PFUser currentUser];
                    post[@"text"] = _inputTextField.text;
                    post[@"image"] = photo[kPhotoPictureKey];
                    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded){
                            NSLog(@"Post saved successfully!");
                            [self showAlertWithTitle:@"Image Posted!" errorMessage:@"Your image has been posted successfully!"];
                            
                            // reset post page
                            _photoSelected = NO;
                            _postImageView.image = [UIImage imageNamed:@"User_Image"];
                            _inputTextField.text = @"Say something...";
                        }
                    }];
                }
                else{
                    NSLog(@"error: %@", [error description]);
                }
            }];
            
        }
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextFeildDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_inputTextField resignFirstResponder];
    
    return false;
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
