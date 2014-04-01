//
//  Tweet.h
//  MapTwitter
//
//  Created by Li Yan on 3/14/13.
//  Copyright (c) 2013 Li Yan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Tweet : NSObject <MKAnnotation>

//Tweets
@property (nonatomic, strong) NSString *id_str;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *handle;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property BOOL pinned;

//Map
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;

//Favorite & Retweet
@property BOOL favorited;
@property BOOL retweeted;

- (Tweet *)initWithJSONDic:(NSDictionary *)tweetDic;

@end
