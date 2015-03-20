//
//  ProfileViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/5/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UITextView *tagLineTextView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tagLineTextView.delegate = self;
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed)];
    
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"ERROR OCCURED DURING FIND OBJECTS:\n%@",error);
        }
        else if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
    
    self.tagLineTextView.text = [[PFUser currentUser] objectForKey:kUserTagLineKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

/*-(void)saveButtonPressed{
    [[PFUser currentUser] setObject:self.tagLineTextView.text forKey:kUserTagLineKey];
    [[PFUser currentUser] saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
}*/


#pragma mark - textViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self.tagLineTextView resignFirstResponder];
        [[PFUser currentUser] setObject:self.tagLineTextView.text forKey:kUserTagLineKey];
        [[PFUser currentUser] saveInBackground];
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    else {
        return YES;
    }
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
