//
//  TwitterDataSource.m
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "TwitterDataHandler.h"

@implementation TwitterDataHandler

@synthesize numRegions, currentIndex;
@synthesize twitterDeveloper;
@synthesize delegate;

static TwitterDataHandler *sharedClient;
+(id)sharedInstance{
    
    if (sharedClient == nil) {
        sharedClient = [[TwitterDataHandler alloc] init];
        sharedClient.numRegions = 1;
        sharedClient.twitterDeveloper = [[TwitterDeveloper alloc] initAsDeveloper];
        sharedClient.numRegions = 1;
        sharedClient.currentIndex = 0;
    }
    
    return sharedClient;
}

- (void)fetchTweetsAtCoord:(CLLocationCoordinate2D)coord andRange:(double)range withBlock:(void (^) (NSArray * tweets))block
{
    NSString *tweetsSearchURL = @"https://api.twitter.com/1.1/search/tweets.json?";
    [twitterDeveloper tweetsSearch:tweetsSearchURL GeoLocation:coord Range:range withBlock:^(NSArray *geoTweets) {
        
        block([NSArray arrayWithArray:geoTweets]);
    }];
    
}

/*
 
 CODE FOR FUTURE USE
 
 
 NSError *error = nil;
 NSDictionary *tweetsDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
 tweetsDic = [tweetsDic objectForKey:@"statuses"];
 NSLog(@"\nFetching tweets...%lu\n", (unsigned long)[tweetsDic count]);
 
 NSMutableArray *geoTweets = [NSMutableArray array];
 for (NSDictionary *subDic in tweetsDic)
 {
 NSString *geoString = [[NSString alloc] initWithFormat:@"%@", [subDic objectForKey:@"geo"]];
 if (![geoString isEqualToString:@"<null>"])
 //Tweets that have "geo"
 {
 //NSLog(@"geostring is %@\n", geoString);
 Tweet *tweet = [[Tweet alloc] initWithJSONDic:subDic];
 [geoTweets addObject:tweet];
 
 }
 }
 */


@end
