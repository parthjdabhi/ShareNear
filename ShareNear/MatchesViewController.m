//
//  MatchesViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "MatchesViewController.h"
#import "ChatViewController.h"

@interface MatchesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableChatRooms;

@end

@implementation MatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Matches!";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.availableChatRooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *chatroom = [self.availableChatRooms objectAtIndex:indexPath.row];
    
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatroom[@"user1"];
    if([testUser1.objectId isEqual:currentUser.objectId]){
        likedUser = [chatroom objectForKey:@"user2"];
    }
    else {
        likedUser = [chatroom objectForKey:@"user1"];
    }
    
    cell.textLabel.text = likedUser[@"profile"][@"firstName"];
    
    // place holder image
    cell.imageView.image = [UIImage imageNamed:@"avatar.png"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForPhoto = [[PFQuery alloc] initWithClassName:@"Photo"];
    [queryForPhoto whereKey:@"user" equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            if ([objects count] > 0) {
                PFObject *photo = objects[0];
                PFFile *pictureFile = photo[kPhotoPictureKey];
                [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if  (!error){
                        cell.imageView.image = [UIImage imageWithData:data];
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }];
            }
        }
    }];
    return cell;
}



#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"showChat" sender:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
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
