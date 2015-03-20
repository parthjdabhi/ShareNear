//
//  ContactsViewController.h
//  ShareNear
//
//  Created by Ke Luo on 2/21/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol ContactsViewControllerDelegate;


@interface ContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *userTableView;
//@property (weak, nonatomic) id<ContactsViewControllerDelegate> delegate;

@end


//@protocol ContactsViewControllerDelegate <NSObject>
//
//-(void)updateFollowStates:(BOOL)followed;
//
//@end
