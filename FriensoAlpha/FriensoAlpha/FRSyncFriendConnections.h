//
//  FRSyncFriendConnections.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/14/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSyncFriendConnections : NSObject

//@property (readonly) NSInteger *count;
//@property (nonatomic,strong) NSDictionary   *watchingOverDic;

- (id) init;
- (void) syncUWatchToCoreFriends;
@end
