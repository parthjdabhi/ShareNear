//
//  ChatViewController.h
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import <JSQSystemSoundPlayer/JSQSystemSoundPlayer.h>


@interface ChatViewController : JSQMessagesViewController <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewCellDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end
