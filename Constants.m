//
//  Constants.m
//  ShareNear
//
//  Created by Ke Luo on 2/5/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - user class

NSString *const kUserProfileKey                     = @"profile";
NSString *const kUserProfileNameKey                 = @"name";
NSString *const kUserProfileFirstNameKey            = @"firstName";
NSString *const kUserProfileLocationKey             = @"location";
NSString *const kUserProfileGenderKey               = @"gender";
NSString *const kUserProfileBirthdayKey             = @"birthday";
NSString *const kUserProfileInterestedInKey         = @"interestedIn";
NSString *const kUserProfilePictureURL              = @"pictureURL";
NSString *const kUserProfileRelationshipStatusKey   = @"relationshipStatus";
NSString *const kUserProfileAgeKey                  = @"age";
NSString *const kUserTagLineKey                     = @"tagLine";

#pragma mark - photo class

NSString *const kPhotoClassKey                      = @"Photo";
NSString *const kPhotoUserKey                       = @"user";
NSString *const kPhotoPictureKey                    = @"image";

#pragma mark - activity class

NSString *const kActivityClassKey                   = @"Activity";
NSString *const kActivityTypeKey                    = @"type";
NSString *const kActivityFromUserKey                = @"fromUser";
NSString *const kActivityToUserKey                  = @"toUser";
NSString *const kActivityPhotoKey                   = @"photo";
NSString *const kActivityTypeLikeKey                = @"like";
NSString *const kActivityTypeDislikeKey             = @"dislike";

#pragma mark - Settings

NSString *const kMenEnableKey                       = @"mem";
NSString *const kWomenEnabledKey                    = @"women";
NSString *const kSingleEnabledKey                   = @"single";
NSString *const kAgeMaxKey                          = @"ageMax";


@end
