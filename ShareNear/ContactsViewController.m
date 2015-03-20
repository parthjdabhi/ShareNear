//
//  ContactsViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/21/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactTableViewCell.h"
#import "ChatViewController.h"
#import "MBProgressHUD.h"

@interface ContactsViewController () <ContactTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *followings;
@property (strong, nonatomic) UIRefreshControl *refresher;
@property (strong, nonatomic) NSString *chatWith;
@property (strong, nonatomic) PFUser *chatWithUser;
@property (strong, nonatomic) PFObject *inChatRoom;




@end


@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.users = [[NSMutableArray alloc]init];
    self.followings = [[NSMutableArray alloc]init];
    
    [self updateUsersTable];
    
    self.refresher = [[UIRefreshControl alloc]init];
    self.refresher.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull to Refresh"];
    [self.refresher addTarget:self action:@selector(refreshScreen) forControlEvents:UIControlEventValueChanged];
    [self.userTableView addSubview:_refresher];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.delegate = self;
    
    if (indexPath.row % 2 == 0){
        cell.backgroundColor = [UIColor grayColor];
    } else {
      //  cell.backgroundColor = [UIColor orangeColor];
    }
    
    PFUser *user = [_users objectAtIndex:indexPath.row];
    
    for (NSString *following in _followings){
        if ([following isEqualToString: user.username]){
            [cell updateFollowButton:YES];
        }
    }
    
    cell.chatWithUser = user;
    cell.usernameLabel.text = user.username;
    
    // Configure the cell...
    
    return cell;
}


# pragma mark - Helper Methods

-(void)updateUsersTable{
    
    [self getUserFollowList];
    
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            [self.users removeAllObjects];
            
            for (PFUser *user in objects){
                if (![user.username isEqualToString:[[PFUser currentUser] username]]){
                    [self.users addObject: user];
                }
            }
            
            [self.userTableView reloadData];
            [self.refresher endRefreshing];
        }else{
            [self showAlertWithTitle:@"ERROR WHEN FINDING FOR USERS" errorMessage:[error description]];
        }
        
    }];
}

-(void)getUserFollowList{
    PFQuery *query = [PFQuery queryWithClassName:kFollowersClassKey];
    [query whereKey:kFollowersFollowerKey equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.followings addObject:object[kFollowersFollowingKey]];
            }
            [self.userTableView reloadData];
        } else {
            [self showAlertWithTitle:@"ERROR WHEN FINDING FOLLOWERS" errorMessage:[error description]];
        }
    }];
}

-(void)refreshScreen{
    [self updateUsersTable];
}

-(void)createChatRoom{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kChatRoomClassKey];
    [queryForChatRoom whereKey:kChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kChatRoomUser2Key equalTo:self.chatWithUser];
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kChatRoomUser1Key equalTo:self.chatWithUser];
    [queryForChatRoomInverse whereKey:kChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSArray *chatrooms = objects;
            if ([chatrooms count] > 0){
                self.inChatRoom = [chatrooms objectAtIndex:0];
                [self performSegueWithIdentifier:@"contactToChat" sender:self];
            } else{
                PFObject *chatroom = [PFObject objectWithClassName:kChatClassKey];
                [chatroom setObject:[PFUser currentUser] forKey:kChatRoomUser1Key];
                [chatroom setObject:self.chatWithUser forKey:kChatRoomUser2Key];
                [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        if (succeeded){
                            self.inChatRoom = chatroom;
                            [self performSegueWithIdentifier:@"contactToChat" sender:self];
                        }
                    } else {
                        [self showAlertWithTitle:@"ERROR WHEN CREATING FOR CHATROOMS" errorMessage:[error description]];
                    }
                }];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showAlertWithTitle:@"ERROR WHEN QUERYING FOR CHATROOMS" errorMessage:[error description]];
        }
    }];
}


#pragma mark - Helper Methods

-(void)showAlertWithTitle: (NSString *)title errorMessage: (NSString *) error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Dismiss", nil];
    
    [alert show];
}

-(void)followButtonDidPressedForUser:(PFUser*)user{
    PFObject *following =  [PFObject objectWithClassName:kFollowersClassKey];
    following[kFollowersFollowerKey] = user.username;
    following[kFollowersFollowingKey] = [[PFUser currentUser] username];
    
    [following saveInBackground];
}

-(void)followButtonDidReleasedForUser:(PFUser*)user{
    PFQuery *query = [PFQuery queryWithClassName:kFollowersClassKey];
    [query whereKey:kFollowersFollowerKey equalTo:[[PFUser currentUser] username]];
    [query whereKey:kFollowersFollowingKey equalTo:user.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [object deleteInBackground];
            }
        } else {
            [self showAlertWithTitle:@"ERROR WHEN FINDING FOLLOWERS" errorMessage:[error description]];
        }
    }];
}

-(void)infotButtonDidPressed{
    NSLog(@"Info Button did pressed!");
}

-(void)chatButtonDidPressedWithUser:(PFUser*)user{
    self.chatWithUser = user;
    [self createChatRoom];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"contactToChat"]){
        ChatViewController *chatVC = segue.destinationViewController;
        chatVC.withUser = _chatWithUser;
        chatVC.chatRoom = _inChatRoom;
    }
}


@end
