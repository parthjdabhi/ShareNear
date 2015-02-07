//
//  ShareViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/4/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "ShareViewController.h"
#import "UIButton+Bootstrap.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    
    
    // set buttons style
    [_shareCameraButton primaryStyle];
    [_shareCameraButton addAwesomeIcon:FAIconBookmark beforeTitle:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)shareCamera:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    
    
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
