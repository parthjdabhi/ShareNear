//
//  MatchUpViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "MatchUpViewController.h"
#import "TestUser.h"
#import "InfoViewController.h"
#import "MatchViewController.h"

@interface MatchUpViewController () <MatchViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation MatchUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set right bar item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Chat" style:UIBarButtonItemStylePlain target:self action:@selector(chatButtonPressed)];
    
    //[TestUser saveTestUserToParse];
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:kPhotoUserKey notEqualTo:[PFUser currentUser]]; // not include current user
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
            [self updateView];
        }
        else {
            NSLog(@"ERROR: %@", error);
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)dislikeButtonPressed:(id)sender {
    [self checkDislike];
}


- (IBAction)infoButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showInfo" sender:nil];
}


- (IBAction)likeButtonPressed:(id)sender {
    [self checkLike];
}

- (IBAction)settingsButtonPressed:(id)sender {
}



-(void)chatButtonPressed{
    NSLog(@"OK");
}


#pragma mark - Helper Methods

-(void)queryForCurrentPhotoIndex{
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[@"image"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error){
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
            } else {
                NSLog(@"ERROR: %@", error);
            }
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:@"Activity"];
        [queryForLike whereKey:@"type" equalTo:@"like"];
        [queryForLike whereKey:@"photo" equalTo:self.photo];
        [queryForLike whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:@"Activity"];
        [queryForDislike whereKey:@"type" equalTo:@"dislike"];
        [queryForDislike whereKey:@"photo" equalTo:self.photo];
        [queryForDislike whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0){
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                } else {
                    PFObject *activity = self.activities[0];
                    if ([activity[@"type"] isEqualToString:@"like"]){
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[@"type"] isEqualToString:@"dislike"]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    else{
                        
                    }
                }
                
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
            else{
                NSLog(@"ERROR: %@", error);
            }
        }];
    }
}

-(void)updateView{
    self.firstNameLabel.text = self.photo[@"user"][@"profile"][@"firstName"];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[@"user"][@"profile"][@"age"]];
    self.tagLineLabel.text = self.photo[@"user"][@"profile"][@"tagLine"];
}

-(void)setupNextPhoto{
    if (self.currentPhotoIndex + 1 < self.photos.count){
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check Back Later for more people!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)saveLike{
    PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
    [likeActivity setObject:@"like" forKey:@"type"];
    [likeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [likeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [likeActivity setObject:self.photo forKey:@"photo"];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}

-(void)saveDislike{
    PFObject *dislikeActivity = [PFObject objectWithClassName:@"Activity"];
    [dislikeActivity setObject:@"dislike" forKey:@"type"];
    [dislikeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [dislikeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [dislikeActivity setObject:self.photo forKey:@"photo"];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

-(void)checkLike{
    if (self.isLikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else {
        [self saveLike];
    }
}

-(void)checkDislike{
    if (self.isDislikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

-(void)checkForPhotoUserLikes{
    PFQuery *query = [PFQuery queryWithClassName:kActivityClassKey];
    [query whereKey:kActivityFromUserKey equalTo:self.photo[kPhotoUserKey]];
    [query whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            // create chatroom
            [self createChatRoom];
        }
    }];
}

-(void)createChatRoom{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:self.photo[kPhotoUserKey]];
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user1" equalTo:self.photo[kPhotoUserKey]];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error ) {
            if ([objects count] == 0){
                PFObject *chatroom = [PFObject objectWithClassName:@"ChatRoom"];
                [chatroom setObject:[PFUser currentUser] forKey:@"user1"];
                [chatroom setObject:self.photo[kPhotoUserKey] forKey:@"user2"];
                [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        [self performSegueWithIdentifier:@"showMatch" sender:nil];
                    }
                }];
            }
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showInfo"]){
        InfoViewController *infoVC = segue.destinationViewController;
        infoVC.photo = self.photo;
    }
    else if ([segue.identifier isEqualToString:@"showMatch"]){
        MatchViewController *matchVC = segue.destinationViewController;
        matchVC.matchedUserImage = self.photoImageView.image;
        matchVC.delegate = self;
    }
}

#pragma mark - MatchViewControllerDelegate

-(void)presentMatchesViewController{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"showMatches" sender:nil];
    }];
}


@end










