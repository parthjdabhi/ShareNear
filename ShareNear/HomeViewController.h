//
//  ShareViewController.h
//  ShareNear
//
//  Created by Ke Luo on 2/4/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *sharePhotosButton;
@property (weak, nonatomic) IBOutlet UIButton *shareMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *shareVideosButton;



@end
