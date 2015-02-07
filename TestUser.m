//
//  TestUser.m
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

+(void)saveTestUserToParse{
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error){
            NSDictionary *profile = @{@"age" : @28,
                                      @"birthday" : @"11/22/1985",
                                      @"firstName" : @"Julie",
                                      @"gender" : @"female",
                                      @"location" : @"Berlin, Germany",
                                      @"name" : @"Julie Adams"};
            [newUser setObject:profile forKey:@"profile"];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    UIImage *profileImage = [UIImage imageNamed:@"picture-wallpaper.jpg"];
                    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                    PFFile *photoFile = [PFFile fileWithData:imageData];
                    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded){
                            PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
                            [photo setObject:newUser forKey:kPhotoUserKey];
                            [photo setObject:photoFile forKey:kPhotoPictureKey];
                            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                NSLog(@"photo saved successfully for new user");
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

@end
