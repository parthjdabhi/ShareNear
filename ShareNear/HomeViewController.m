//
//  ShareViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/4/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *shareOnFacebookButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    
    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)sharePhotos:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Where Would You Want to Share" message:@"Destination type" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Share To All Available" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Share some shit to all available bitches");
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"P2P Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSLog(@"P2P share");
        [self performSegueWithIdentifier:@"showP2PShare" sender:nil];        
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Share On Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Share some shit on facebook");
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Share On Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Share some shit on twitter");
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Share On Instagram" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Share some shit on Instagram");
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // cancel action here
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)shareOnFacebookButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showFacebook" sender:nil];
}

#pragma mark - UImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
