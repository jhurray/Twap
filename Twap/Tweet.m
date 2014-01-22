//
//  Tweet.m
//  MapTwitter
//
//  Created by Li Yan on 3/14/13.
//  Copyright (c) 2013 Li Yan. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

@synthesize id_str;
@synthesize name;
@synthesize text;
@synthesize timeStamp;
@synthesize imageURL;
@synthesize image;
@synthesize title;
@synthesize coordinate;
@synthesize pinned;
@synthesize favorited;
@synthesize retweeted;

- (Tweet *)initWithJSONDic:(NSDictionary *)tweetDic {
    self = [super init];
    
    NSDictionary *subDic = nil;
    [self setId_str:[[NSString alloc] initWithFormat:@"%@", [tweetDic objectForKey:@"id_str"]]];
    [self setTimeStamp:[tweetDic objectForKey:@"created_at"]];
    subDic = [tweetDic objectForKey:@"user"];
    [self setName:[[NSString alloc] initWithFormat:@"%@", [subDic objectForKey:@"name"]]];
    [self setImageURL:[[NSString alloc] initWithFormat:@"%@", [subDic objectForKey:@"profile_image_url"]]];
    [self setText:[[NSString alloc] initWithFormat:@"%@", [tweetDic objectForKey:@"text"]]];
    NSURL* url = [NSURL URLWithString:self.imageURL];
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:url];
    [self setImage:[[UIImage alloc] initWithData:imageData]];
    
    [self setTitle:[[NSString alloc] initWithFormat:@"%@", self.name]];
    subDic = [tweetDic objectForKey:@"geo"];
    NSArray *array = [subDic objectForKey:@"coordinates"];
    CLLocationCoordinate2D tweetCoordinate;
    tweetCoordinate.latitude = [[array objectAtIndex:0] doubleValue];
    tweetCoordinate.longitude = [[array objectAtIndex:1] doubleValue];
    [self setCoordinate:tweetCoordinate];
    [self setPinned:false];
    
    [self setFavorited:[[[NSString alloc] initWithFormat:@"%@", [tweetDic objectForKey:@"favorited"]] boolValue]];
    //NSLog(@"%@", [tweetDic objectForKey:@"favorited"]);
    if (self.favorited)
    {
        NSLog(@"%@", self.name);
    }
    [self setRetweeted:[[[NSString alloc] initWithFormat:@"%@", [tweetDic objectForKey:@"retweeted"]] boolValue]];
    
    return self;
}

@end
