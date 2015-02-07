//
//  MatchViewController.h
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface MatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak) id <MatchViewControllerDelegate> delegate;

@end
