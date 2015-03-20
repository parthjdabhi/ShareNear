//
//  Constants.h
//  ShareNear
//
//  Created by Ke Luo on 2/5/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - Global Key

extern NSString *const kObjectIdKey;
extern NSString *const kCreatedAtKey;

#pragma mark - User Class

extern NSString *const kUserProfileKey;
extern NSString *const kUserProfileNameKey;
extern NSString *const kUserProfileFirstNameKey;
extern NSString *const kUserProfileLocationKey;
extern NSString *const kUserProfileGenderKey;
extern NSString *const kUserProfileBirthdayKey;
extern NSString *const kUserProfileInterestedInKey;
extern NSString *const kUserProfilePictureURL;
extern NSString *const kUserProfileRelationshipStatusKey;
extern NSString *const kUserProfileAgeKey;
extern NSString *const kUserTagLineKey;
extern NSString *const kUserProfileFriendsKey;
extern NSString *const kUserProfilePublishActionsKey;

#pragma mark - Photo Class

extern NSString *const kPhotoClassKey;
extern NSString *const kPhotoUserKey;
extern NSString *const kPhotoPictureKey;

#pragma mark - Activity Class

extern NSString *const kActivityClassKey;
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityFromUserKey;
extern NSString *const kActivityToUserKey;
extern NSString *const kActivityPhotoKey;
extern NSString *const kActivityTypeLikeKey;
extern NSString *const kActivityTypeDislikeKey;

#pragma mark - Settings 

extern NSString *const kMenEnableKey;
extern NSString *const kWomenEnabledKey;
extern NSString *const kSingleEnabledKey;
extern NSString *const kAgeMaxKey;

#pragma mark - ChatRoom

extern NSString *const kChatRoomClassKey;
extern NSString *const kChatRoomUser1Key;
extern NSString *const kChatRoomUser2Key;

#pragma mark - Chat

extern NSString *const kChatClassKey;
extern NSString *const kChatChatRoomKey;
extern NSString *const kChatFromUserKey;
extern NSString *const kChatToUserKey;
extern NSString *const kChatTextKey;
extern NSString *const kChatImageKey;

#pragma mark - Installation

extern NSString *const kInstallationUserKey;

#pragma mark - Followers

extern NSString *const kFollowersClassKey;
extern NSString *const kFollowersFollowerKey;
extern NSString *const kFollowersFollowingKey;




@end

















