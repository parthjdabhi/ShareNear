//
//  ChatViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation ChatViewController

-(NSMutableArray *)chats{
    if (!_chats){
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.delegate = self;
//    self.data
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[@"user1"];
    if ([testUser1.objectId isEqual:self.currentUser.objectId]){
        self.withUser = self.chatRoom[@"user2"];
    }
    else {
        self.withUser = self.chatRoom[@"user1"];
    }
    self.title = self.withUser[@"profile"][@"firstName"];
    self.initialLoadComplete = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chats count];
}

//- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    /**
//     *  Override point for customizing cells
//     */
//    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
//    
//    /**
//     *  Configure almost *anything* on the cell
//     *
//     *  Text colors, label text, label colors, etc.
//     *
//     *
//     *  DO NOT set `cell.textView.font` !
//     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
//     *
//     *
//     *  DO NOT manipulate cell layout information!
//     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
//     */
//    
//    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
//    
//    if (!msg.isMediaMessage) {
//        
//        if ([msg.senderId isEqualToString:self.senderId]) {
//            cell.textView.textColor = [UIColor blackColor];
//        }
//        else {
//            cell.textView.textColor = [UIColor whiteColor];
//        }
//        
//        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
//                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
//    }
//    
//    return cell;
//}

#pragma mark - JSQMessages Method Override

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    if (text.length != 0){
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        [chat setObject:self.chatRoom forKey:@"chatroom"];
        [chat setObject:self.currentUser forKey:@"fromUser"];
        [chat setObject:self.withUser forKey:@"toUser"];
        [chat setObject:text forKey:@"text"];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            

        }];
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
