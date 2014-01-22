//
//  TweetView.h
//  Twap
//
//  Created by Gregoire on 1/19/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//
#import "Tweet.h"
#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>

#define TV_HEIGHT 150

@interface TweetView : UIView <UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *pic;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *text;
@property (nonatomic, strong) UILabel *timeStamp;
@property (nonatomic, strong) NSString *id_str;
@property (nonatomic, strong) UIButton *retweet;
@property (nonatomic, strong) UIButton *favorite;
@property (nonatomic, strong) Tweet *tweet;

@property BOOL favorited;

-(void)setNewTweet:(Tweet *)tweet;
-(void)fadeOutWithNewTweet:(Tweet *)tweet;
-(void)fadeIn;

@end
