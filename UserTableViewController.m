//
//  UserTableViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/16/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "UserTableViewController.h"

@interface UserTableViewController ()

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *followings;
@property (strong, nonatomic) UIRefreshControl *refresher;

@end

@implementation UserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Users";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(postImage)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _users = [[NSMutableArray alloc] init];
    
    
    _followings = [[NSMutableArray alloc]initWithCapacity:10];
    
    [self updateUsersTable];
    
    _refresher = [[UIRefreshControl alloc]init];
    _refresher.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull to Refresh"];
    [_refresher addTarget:self action:@selector(refreshScreen) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refresher];
    

    
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
    return _users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *username = [_users objectAtIndex:indexPath.row];
    
    for (NSString *following in _followings){
        if ([following isEqualToString: username]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
        
    
    
    
    cell.textLabel.text = username;
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
        [query whereKey:@"follower" equalTo:[[PFUser currentUser] username]];
        [query whereKey:@"following" equalTo:cell.textLabel.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded){
                            NSLog(@"successfully delete object: %@", object);
                        }
                        
                    }];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    } else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        PFObject *following =  [PFObject objectWithClassName:@"Followers"];
        following[@"following"] = cell.textLabel.text;
        following[@"follower"] = [[PFUser currentUser] username];
        
        [following saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded){
                NSLog(@"follow action saved succeffully");
            }
        }];
    }
    
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



# pragma mark - Helper Methods

-(void)updateUsersTable{
    
    [self getUserFollowList];
    
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [_users removeAllObjects];
        
        for (PFUser *user in objects){
            
            
            if (![user.username isEqualToString:[[PFUser currentUser] username]]){
                [_users addObject: user.username];
            }
        }
        
        [self.tableView reloadData];
        [_refresher endRefreshing];
    }];
}

-(void)getUserFollowList{
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    [query whereKey:@"follower" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
       //         NSLog(@"%@ is following %@", [[PFUser currentUser] username], object[@"following"]);
                [_followings addObject:object[@"following"]];
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)refreshScreen{
    [self updateUsersTable];
}


-(void)postImage{
    [self performSegueWithIdentifier:@"postImage" sender:self];
    
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
