//
//  ChatTabViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/7/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ChatTabViewController.h"
#import "ChatViewController.h"

@interface ChatTabViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (strong, nonatomic) NSMutableArray *availableChatRooms;

@end

@implementation ChatTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    [self updateAvailableChatRooms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy instantiation

-(NSMutableArray *)availableChatRooms{
    if (!_availableChatRooms){
        _availableChatRooms = [[NSMutableArray alloc]init];
    }
    return _availableChatRooms;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.availableChatRooms count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFObject *chatroom = [self.availableChatRooms objectAtIndex:indexPath.row];
    
    PFUser *withUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatroom[@"user1"];
    if([testUser1.objectId isEqual:currentUser.objectId]){
        withUser = [chatroom objectForKey:@"user2"];
    }
    else {
        withUser = [chatroom objectForKey:@"user1"];
    }
    
    cell.textLabel.text = withUser[@"username"];
    
    // place holder image
    cell.imageView.image = [UIImage imageNamed:@"avatar.png"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForPhoto = [[PFQuery alloc] initWithClassName:@"Photo"];
    [queryForPhoto whereKey:@"user" equalTo:withUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            if ([objects count] > 0) {
                NSLog(@"Photo found");
                PFObject *photo = objects[0];
                PFFile *pictureFile = photo[kPhotoPictureKey];
                [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if  (!error){
                        cell.imageView.image = [UIImage imageWithData:data];
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }];
            } else {
                NSLog(@"No photo found!");
            }
        }
    }];
    
    return cell;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"chatTabToChat" sender:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

#pragma mark - Helper Methods

-(void)updateAvailableChatRooms{
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    
    // include key to download not only chatroom object, but also objects that include
    [queryCombined includeKey:@"chat"];
    [queryCombined includeKey:@"user1"];
    [queryCombined includeKey:@"user2"];
    
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            [self.availableChatRooms removeAllObjects];
            self.availableChatRooms = [objects mutableCopy];
            [self.chatTableView reloadData];
        }
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    ChatViewController *chatVC = segue.destinationViewController;
    
    NSIndexPath *indexPath = sender;
    
    chatVC.chatRoom = [self.availableChatRooms objectAtIndex:indexPath.row];
}


@end
