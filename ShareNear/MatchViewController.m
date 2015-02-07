//
//  MatchViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "MatchViewController.h"

@interface MatchViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *matchedUserImageView;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserImageView;


@property (weak, nonatomic) IBOutlet UIButton *viewChatsButton;
@property (weak, nonatomic) IBOutlet UIButton *keepSearchingButton;



@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            if ([objects count] > 0) {
                PFObject *photo = objects[0];
                PFFile *pictureFile = photo[kPhotoPictureKey];
                [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    self.currentUserImageView.image = [UIImage imageWithData:data];
                    self.matchedUserImageView.image = self.matchedUserImage;
                }];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)viewChatsButtonPressed:(id)sender {
    
    [self.delegate presentMatchesViewController];
    
}

- (IBAction)keepSearchingButtonPressed:(id)sender {
    // use dimiss for modal segue
    // use pop for push segue
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
