//
//  TwitterDataHandler
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"
#import "TwitterDeveloper.h"

@protocol TwitterDataDelegate <NSObject>

//-(void)addTweet:(Tweet *)tweet;

@end

@interface TwitterDataHandler : NSObject

@property (nonatomic, weak) id<TwitterDataDelegate> delegate;
@property (nonatomic) NSUInteger numRegions;
@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic, strong) TwitterDeveloper *twitterDeveloper;

+(id) sharedInstance;

- (void)fetchTweetsAtCoord:(CLLocationCoordinate2D)coord andRange:(double)range withBlock:(void (^) (NSArray * tweets))block;

@end
