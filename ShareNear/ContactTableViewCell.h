//
//  ContactTableViewCell.h
//  ShareNear
//
//  Created by Ke Luo on 2/21/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactTableViewCellDelegate;

@interface ContactTableViewCell : UITableViewCell 

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) id <ContactTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (nonatomic, strong) PFUser *chatWithUser;

-(void)updateFollowButton:(BOOL)followed;

@end

@protocol ContactTableViewCellDelegate <NSObject>
-(void)followButtonDidPressedForUser:(PFUser*)user;
-(void)followButtonDidReleasedForUser:(PFUser*)user;
-(void)infotButtonDidPressed;
-(void)chatButtonDidPressedWithUser:(PFUser*)user;
@end



