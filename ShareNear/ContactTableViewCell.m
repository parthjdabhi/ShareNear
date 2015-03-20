//
//  ContactTableViewCell.m
//  ShareNear
//
//  Created by Ke Luo on 2/21/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ContactTableViewCell.h"

@interface ContactTableViewCell()

@end

@implementation ContactTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (IBAction)followButtonPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Follow"]){
        [sender setSelected:YES];
        [sender setTitle:@"Followed" forState:UIControlStateNormal];
        [self.delegate followButtonDidPressedForUser:_chatWithUser];
    } else {
        [sender setSelected:NO];
        [sender setTitle:@"Follow" forState:UIControlStateNormal];
        [self.delegate followButtonDidReleasedForUser:_chatWithUser];
    }
    
}

- (IBAction)infoButtonPressed:(id)sender {
    [self.delegate infotButtonDidPressed];
}

- (IBAction)chatButtonPressed:(id)sender {
    [self.delegate chatButtonDidPressedWithUser:_chatWithUser];
}

#pragma mark - Helper Methods

-(void)updateFollowButton:(BOOL)followed{
    NSLog(@"Update follow button method called!");
    if (followed){
        [self updateFollowStatusToParse];
        [_followButton setSelected:YES];
        [_followButton setTitle:@"Followed" forState:UIControlStateNormal];
    } else {
        [self updateFollowStatusToParse];
        [_followButton setSelected:NO];
        [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

-(void)updateFollowStatusToParse{
    if ([_followButton.currentTitle isEqualToString:@"Follow"]){
        
        PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
        [query whereKey:@"follower" equalTo:[[PFUser currentUser] username]];
        [query whereKey:@"following" equalTo:self.usernameLabel.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded){
                            NSLog(@"successfully delete: %@ follow %@", object[@"follower"], object[@"following"]);
                        }
                        
                    }];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    } else{
        PFObject *following =  [PFObject objectWithClassName:@"Followers"];
        following[@"following"] = self.usernameLabel.text;
        following[@"follower"] = [[PFUser currentUser] username];
        
        [following saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded){
                NSLog(@"follow action saved succeffully");
            }
        }];
        
    }
}



@end
