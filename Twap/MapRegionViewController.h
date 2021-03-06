//
//  MapRegionViewController.h
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetView.h"
#import "AnimatedOverlay.h"
#import "NewUserPromptView.h"

@interface MapRegionViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, weak) id master;
@property (assign, nonatomic) NSInteger index;
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) NSMutableDictionary *tweetsDictionary;
@property (nonatomic, strong) TweetView *tweetView;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property BOOL visible;
@property double mapDist;
@property NSUInteger annotationCount;

-(id) initWithMapRegion:(MKCoordinateRegion)coordRegion andMaster:(id)master;
-(void) refreshTweets;
-(void)removeAnimatedOverlay;
-(void) startRefreshTimer;
-(void)stopTimer;
-(void)reloadMap;

@end
