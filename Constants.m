//
//  Constants.m
//  ShareNear
//
//  Created by Ke Luo on 2/5/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - Global Key

NSString *const kObjectIdKey                        = @"objectId";
NSString *const kCreatedAtKey                       = @"createdAt";

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
NSString *const kUserProfileFriendsKey              = @"userFriends";
NSString *const kUserProfilePublishActionsKey        = @"publishActions";

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

NSString *const kMenEnableKey                       = @"men";
NSString *const kWomenEnabledKey                    = @"women";
NSString *const kSingleEnabledKey                   = @"single";
NSString *const kAgeMaxKey                          = @"ageMax";

#pragma mark - ChatRoom

NSString *const kChatRoomClassKey                   = @"ChatRoom";
NSString *const kChatRoomUser1Key                   = @"user1";
NSString *const kChatRoomUser2Key                   = @"user2";

#pragma mark - Chat

NSString *const kChatClassKey                       = @"Chat";
NSString *const kChatChatRoomKey                    = @"chatroom";
NSString *const kChatFromUserKey                    = @"fromUser";
NSString *const kChatToUserKey                      = @"toUser";
NSString *const kChatTextKey                        = @"text";
NSString *const kChatImageKey                       = @"image";

#pragma mark - Installation

NSString *const kInstallationUserKey                = @"user";

#pragma mark - Followers

NSString *const kFollowersClassKey                  = @"Followers";
NSString *const kFollowersFollowerKey               = @"follower";
NSString *const kFollowersFollowingKey              = @"following";














@end
