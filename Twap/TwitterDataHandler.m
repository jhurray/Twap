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

- (NSDictionary *)fetchTweetsAtCoord:(CLLocationCoordinate2D)coord andRange:(double)range
{
    NSString *tweetsSearchURL = @"https://api.twitter.com/1.1/search/tweets.json?";
    NSData *tweetsData = [twitterDeveloper tweetsSearch:tweetsSearchURL GeoLocation:coord Range:range];
    NSError *error = nil;
    NSDictionary *tweetsDic = [NSJSONSerialization JSONObjectWithData:tweetsData options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
    tweetsDic = [tweetsDic objectForKey:@"statuses"];
    NSLog(@"\nFetching tweets...%lu\n", [tweetsDic count]);
    return tweetsDic;
}

@end
