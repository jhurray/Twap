//
//  TwitterDataSource.m
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "TwitterDataHandler.h"

@implementation TwitterDataHandler

@synthesize leftTweets, rightTweets, centerTweets;
@synthesize numRegions, currentIndex;
@synthesize twitterDeveloper;
@synthesize delegate;

static TwitterDataHandler *sharedClient;
+(id)sharedInstance{
    
    if (sharedClient == nil) {
        sharedClient = [[TwitterDataHandler alloc] init];
        sharedClient.numRegions = 1;
        sharedClient.leftTweets = [NSMutableDictionary dictionary];
        sharedClient.rightTweets = [NSMutableDictionary dictionary];
        sharedClient.centerTweets = [NSMutableDictionary dictionary];
        sharedClient.twitterDeveloper = [[TwitterDeveloper alloc] initAsDeveloper];
        sharedClient.numRegions = 1;
        sharedClient.currentIndex = 0;
    }
    
    return sharedClient;
}

- (void)fetchTweetsAtCoord:(CLLocationCoordinate2D)coord andRange:(double)range withBlock:(void (^) (NSDictionary * dict))block
{
    NSString *tweetsSearchURL = @"https://api.twitter.com/1.1/search/tweets.json?";
    [twitterDeveloper tweetsSearch:tweetsSearchURL GeoLocation:coord Range:range withBlock:^(NSData *data) {
        NSError *error = nil;
        NSDictionary *tweetsDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
        tweetsDic = [tweetsDic objectForKey:@"statuses"];
        NSLog(@"\nFetching tweets...%lu\n", (unsigned long)[tweetsDic count]);
        block(tweetsDic);
    }];
}

@end
