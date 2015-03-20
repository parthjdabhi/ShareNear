//
//  InfoViewController.h
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewControllerDelegate <NSObject>

-(void)didPressLike;
-(void)didPressDislike;

@end

@interface InfoViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;

@property (weak) id <InfoViewControllerDelegate> delegate;

@end
