//
//  ChatViewController.h
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "JSQMessagesViewController.h"

@protocol ChatViewControllerDelegate;

@interface ChatViewController : JSQMessagesViewController <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewCellDelegate>

@property (strong, nonatomic) PFObject *chatRoom;
@property (strong, nonatomic) PFUser *withUser;

@end

@protocol ChatViewControllerDelegate <NSObject>


@end
