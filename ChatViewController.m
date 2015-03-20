//
//  ChatViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableDictionary *downloadedPhotos;


@property (strong, nonatomic) UIImage *imageToSave;
@property (strong, nonatomic) JSQMessage *message;
@property (nonatomic) BOOL imageIsTooBig;

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
    
    self.downloadedPhotos = [[NSMutableDictionary alloc]init];
    // Do any additional setup after loading the view
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNewMessageFromUserNotification:)
                                                 name:@"DidReceiveNewMessageFromUser"
                                               object:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties
-(void)setChatRoom:(PFObject *)chatRoom{
    _chatRoom = chatRoom;
    [self checkForNewChats];
}

-(void)setWithUser:(PFUser *)withUser{
    _withUser = withUser;
    self.currentUser = [PFUser currentUser];
    self.navigationItem.title = self.withUser[@"username"];
    self.initialLoadComplete = NO;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chats count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    //    NSLog(@"[cellForItemAtIndexPath]chat at index %li is %@", (long)indexPath.row, _chats[indexPath.row][@"text"]);
    
    
    //    JSQMessage *msg = [self.chatsJSQ objectAtIndex:indexPath.row];
    
 /*   JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:[self.chats[indexPath.row][kChatFromUserKey] objectId]
                                         senderDisplayName:[self.chats[indexPath.row][kChatFromUserKey] username]
                                                      date:[self.chats[indexPath.row] createdAt]
                                                      text:self.chats[indexPath.row][kChatTextKey]];*/
    
    if (!self.chats[indexPath.row][kChatImageKey]) {
        
        if ([[self.chats[indexPath.row][kChatFromUserKey] objectId] isEqualToString:[self senderId]]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


#pragma mark - JSQMessage CollectionView DataSource

- (NSString *)senderDisplayName{
    return _currentUser.username;
}

- (NSString *)senderId{
    return _currentUser.objectId;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.imageToSave){
        JSQPhotoMediaItem *chatPhoto = [[JSQPhotoMediaItem alloc] initWithImage:self.imageToSave];
        self.message = [[JSQMessage alloc] initWithSenderId:[self.chats[indexPath.row][kChatFromUserKey] objectId]
                                          senderDisplayName:[self.chats[indexPath.row][kChatFromUserKey] username]
                                                       date:[self.chats[indexPath.row] createdAt]
                                                      media:chatPhoto];
        // set image to save to nil
        self.imageToSave = nil;
        
    }
    else if(self.chats[indexPath.row][kChatImageKey]){
        JSQPhotoMediaItem *chatPhoto = [[JSQPhotoMediaItem alloc] initWithImage:[self.downloadedPhotos objectForKey:[self.chats[indexPath.row] objectId]]];
        self.message = [[JSQMessage alloc] initWithSenderId:[self.chats[indexPath.row][kChatFromUserKey] objectId]
                                          senderDisplayName:[self.chats[indexPath.row][kChatFromUserKey] username]
                                                       date:[self.chats[indexPath.row] createdAt]
                                                      media:chatPhoto];
        
    }
    else {
        self.message = [[JSQMessage alloc] initWithSenderId:[self.chats[indexPath.row][kChatFromUserKey] objectId]
                                     senderDisplayName:[self.chats[indexPath.row][kChatFromUserKey] username]
                                                  date:[self.chats[indexPath.row] createdAt]
                                                  text:self.chats[indexPath.row][kChatTextKey]];
    }
    
    return self.message;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kChatFromUserKey];
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc]init];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    else {
        return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark - JSQMessages Method Override

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    if (text.length != 0){
        
        PFObject *chat = [PFObject objectWithClassName:kChatClassKey];
        [chat setObject:self.chatRoom forKey:kChatChatRoomKey];
        [chat setObject:self.currentUser forKey:kChatFromUserKey];
        [chat setObject:self.withUser forKey:kChatToUserKey];
        [chat setObject:text forKey:kChatTextKey];
        
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self.collectionView reloadData];
            [self finishSendingMessageAnimated:YES];
            
            
            PFQuery *installationQuery = [PFInstallation query];
            [installationQuery whereKey:kInstallationUserKey equalTo:self.withUser];
            
            NSDictionary *dict = @{kChatFromUserKey : [PFUser currentUser]};            
            [PFPush sendPushDataToQueryInBackground:installationQuery withData:dict];
            
        }];
        
    }
}

-(void)didPressAccessoryButton:(UIButton *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Media Message" message:@"Choose Media Type" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // take photo action here
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose From Existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // send photo action here
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // cancel action here
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}


#pragma mark - Helper Methods

-(void)checkForNewChats{
    PFQuery *queryForChats = [PFQuery queryWithClassName:kChatClassKey];
    if (self.chatRoom!=nil){        
        [queryForChats whereKey:kChatChatRoomKey equalTo:self.chatRoom];
        [queryForChats orderByAscending:kCreatedAtKey];
        [queryForChats includeKey:kChatFromUserKey];
        [queryForChats includeKey:kChatImageKey];
        [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                [self.chats removeAllObjects];
                self.chats = [objects mutableCopy];
                

                for (PFObject *chat in self.chats){
                    if (chat[kChatImageKey] && ![self.downloadedPhotos objectForKey:[chat objectId]]){
                        UIImage *defaultPhoto = [UIImage imageNamed:@"circle-loading-animation.gif"];
                        [self.downloadedPhotos setObject:defaultPhoto forKey:[chat objectId]];
                        PFFile *pictureFile = chat[kChatImageKey][kPhotoPictureKey];
                        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            UIImage *photo = [UIImage imageWithData:data];
                            [self.downloadedPhotos setObject:photo forKey:[chat objectId]];
                            [self.collectionView reloadData];
                        }];
                    }
                }
                
                if (self.initialLoadComplete == YES){
                    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                }
                self.initialLoadComplete = YES;
                [self finishReceivingMessage];
            }
        }];
    }
}

-(void)didReceiveNewMessageFromUserNotification: (NSNotification *) notification {
    
    PFUser *fromUser = [[notification userInfo] objectForKey:@"fromUser"];
    if ([fromUser[@"objectId"] isEqualToString:self.withUser.objectId]){
        [self checkForNewChats];
    }
}

-(CGFloat)testImage:(UIImage*)image withCompression:(CGFloat)comp{
    
    NSData *imageData = UIImageJPEGRepresentation(image, comp);
    if (comp == 1 && imageData.length>10485760){
        self.imageIsTooBig = YES;
        return comp;
    } else if (imageData.length>10485760){
        return [self testImage:image withCompression:comp+0.1];
    } else {
        self.imageIsTooBig = NO;
        return comp;
    }
}

-(void)showAlertWithTitle: (NSString *)title errorMessage: (NSString *) error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Dismiss", nil];
    
    [alert show];
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    //    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    //    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
    //        return 0.0f;
    //    }
    //
    //    if (indexPath.item - 1 > 0) {
    //        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
    //        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
    //            return 0.0f;
    //        }
    //    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}


#pragma mark - UICollectionViewCellDelegate

/**
 *  Tells the delegate that the avatarImageView of the cell has been tapped.
 *
 *  @param cell The cell that received the tap touch event.
 */
- (void)messagesCollectionViewCellDidTapAvatar:(JSQMessagesCollectionViewCell *)cell{
    
}

/**
 *  Tells the delegate that the message bubble of the cell has been tapped.
 *
 *  @param cell The cell that received the tap touch event.
 */
- (void)messagesCollectionViewCellDidTapMessageBubble:(JSQMessagesCollectionViewCell *)cell{
    
}

/**
 *  Tells the delegate that the cell has been tapped at the point specified by position.
 *
 *  @param cell The cell that received the tap touch event.
 *  @param position The location of the received touch in the cell's coordinate system.
 *
 *  @discussion This method is *only* called if position is *not* within the bounds of the cell's
 *  avatar image view or message bubble image view. In other words, this method is *not* called when the cell's
 *  avatar or message bubble are tapped.
 *
 *  @see `messagesCollectionViewCellDidTapAvatar:`
 *  @see `messagesCollectionViewCellDidTapMessageBubble:`
 */
- (void)messagesCollectionViewCellDidTapCell:(JSQMessagesCollectionViewCell *)cell atPosition:(CGPoint)position{
    
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageIsTooBig = NO;
    
    NSData *imageData = UIImagePNGRepresentation(self.imageToSave);
    if (imageData.length>10485760){
        self.imageIsTooBig = YES;
        imageData = UIImageJPEGRepresentation(self.imageToSave, [self testImage:self.imageToSave withCompression:0]);
    }
    
    if (self.imageIsTooBig){
        [self showAlertWithTitle:@"Failed To Send Image" errorMessage:@"Image Size Too Big!"];
    } else {
        PFFile *photoFile = [PFFile fileWithData:imageData];
        
        [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded){
                PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
                [photo setObject:[PFUser currentUser] forKey:kPhotoUserKey];
                [photo setObject:photoFile forKey:kPhotoPictureKey];
                [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        NSLog(@"Photo saved successfully");
                        
                        PFObject *chat = [PFObject objectWithClassName:kChatClassKey];
                        [chat setObject:self.chatRoom forKey:kChatChatRoomKey];
                        [chat setObject:self.currentUser forKey:kChatFromUserKey];
                        [chat setObject:self.withUser forKey:kChatToUserKey];
                        [chat setObject:photo forKey:kChatImageKey];
                        
                        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [self.chats addObject:chat];
                            [JSQSystemSoundPlayer jsq_playMessageSentSound];
                            [self finishSendingMessageAnimated:YES];
                        }];
                    }
                    else{
                        NSLog(@"error: %@", [error description]);
                    }
                }];
            }
        }];

    }
    
    
    
    
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
