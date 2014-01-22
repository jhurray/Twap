//
//  TweetView.m
//  Twap
//
//  Created by Gregoire on 1/19/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "TweetView.h"

#define BTN_SIZE 45

@implementation TweetView

@synthesize id_str, retweet, favorite, pic, text, timeStamp, name, favorited;


-(UIFont *)fontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"GillSans-Light" size:size];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:MAINCOLOR];
        //retweet
        retweet = [UIButton buttonWithType:UIButtonTypeCustom];
        [retweet setBackgroundImage:[self changeImage:[UIImage imageNamed:@"retweet.png"] toColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [retweet setFrame:CGRectMake(DEVICEWIDTH-BTN_SIZE-10, 20, BTN_SIZE, BTN_SIZE)];
        [retweet setBackgroundColor:[UIColor clearColor]];
        [retweet.layer setCornerRadius:BTN_SIZE/2];
        [retweet addTarget:self action:@selector(retweetBtnPress) forControlEvents:UIControlEventTouchUpInside];
        retweet.tag = 69;
        //[retweet.layer setBorderWidth:2];
        //[retweet.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        //favorite
        favorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [favorite setBackgroundImage:[self changeImage:[UIImage imageNamed:@"favorite.png"] toColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [favorite setFrame:CGRectMake(DEVICEWIDTH-BTN_SIZE-10, BTN_SIZE+40, BTN_SIZE, BTN_SIZE)];
        [favorite setBackgroundColor:[UIColor clearColor]];
        [favorite.layer setCornerRadius:BTN_SIZE/2];
        [favorite addTarget:self action:@selector(favoriteBtnPress) forControlEvents:UIControlEventTouchUpInside];
        favorite.tag = 69;
        //[favorite.layer setBorderWidth:2];
        //[favorite.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        //pic
        pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.frame.size.height-45, 35, 35)];
        [pic setBackgroundColor:[UIColor whiteColor]];
        [pic.layer setCornerRadius:7];
        
        //name
        name = [[UILabel alloc] initWithFrame:CGRectMake(60, self.frame.size.height-45, 70, 35)];
        name.adjustsFontSizeToFitWidth = YES;
        [name setText:@"Name"];
        [name setTextColor:[UIColor whiteColor]];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setFont:[self fontWithSize:18]];
        
        //timestamp
        timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(140, self.frame.size.height-45, 90, 35)];
        timeStamp.adjustsFontSizeToFitWidth = YES;
        [timeStamp setText:@"time stamp blah"];
        [timeStamp setTextColor:[UIColor whiteColor]];
        [timeStamp setBackgroundColor:[UIColor clearColor]];
        [timeStamp setFont:[self fontWithSize:18]];
        
        //text
        text = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, DEVICEWIDTH-BTN_SIZE-30, self.frame.size.height-50)];
        text.adjustsFontSizeToFitWidth = YES;
        [text setNumberOfLines:3];
        [text setText:@"This is a tweet with hopefullt less than 160 characters cool brah!!!! i bet this will make it be more ok?????"];
        [text setTextColor:[UIColor whiteColor]];
        [text setBackgroundColor:[UIColor clearColor]];
        [text setFont:[self fontWithSize:18]];
        
        favorited = FALSE;
        
        [self addSubview:retweet];
        [self addSubview:favorite];
        [self addSubview:name];
        [self addSubview:timeStamp];
        [self addSubview:text];
        [self addSubview:pic];
        
    }
    return self;
}

-(UIImage *)changeImage:(UIImage *)img toColor:(UIColor *)clr{
    
    CGRect rect = CGRectMake(0, 0, BTN_SIZE, BTN_SIZE);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextSetFillColorWithColor(context, [clr CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:image.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    return flippedImage;
    
}

-(void)finishRetweet{
    
    dispatch_queue_t background = dispatch_queue_create("background", NULL);
    dispatch_barrier_async(background, ^{
        //[[[TwitterDataHandler sharedInstance] twitterDeveloper] retweet:id_str];
    });
    
    [self hasBeenRetweeted];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"YES"])
    {
        [self finishRetweet];
    }
    else if([title isEqualToString:@"NO"])
    {
        return;
    }
    
}

-(void)retweetBtnPress
{
    NSLog(@"Retweet pressed\n");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure"
                                                    message:@"you want to retweet this?"
                                                   delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    
}

-(void)favoriteBtnPress
{
     NSLog(@"Favorite pressed\n");
    dispatch_queue_t background2 = dispatch_queue_create("background2", NULL);
    dispatch_barrier_async(background2, ^{
        //[[[TwitterDataHandler sharedInstance] twitterDeveloper] favorite:id_str Is_Create:(!favorited)];
    });
    if(favorited){
        [self hasBeenUnfavorited];
        favorited = false;
    }
    else{
        [self hasBeenFavorited];
        favorited = true;
    }
}

-(void)hasBeenFavorited{
    [favorite setBackgroundImage:[self changeImage:[UIImage imageNamed:@"favorite.png"] toColor:MAINCOLOR] forState:UIControlStateNormal];
    [favorite setBackgroundColor:[UIColor whiteColor]];
    self.tweet.favorited = TRUE;
}

-(void)hasBeenUnfavorited{
    [favorite setBackgroundImage:[self changeImage:[UIImage imageNamed:@"favorite.png"] toColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [favorite setBackgroundColor:[UIColor clearColor]];
    self.tweet.favorited = FALSE;
}

-(void)hasBeenRetweeted{
    [retweet setBackgroundImage:[self changeImage:[UIImage imageNamed:@"retweet.png"] toColor:MAINCOLOR] forState:UIControlStateNormal];
    [retweet setBackgroundColor:[UIColor whiteColor]];
}

-(void)unhiglightRetweet{
    [retweet setBackgroundImage:[self changeImage:[UIImage imageNamed:@"retweet.png"] toColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [retweet setBackgroundColor:[UIColor clearColor]];
}


-(void)setNewTweet:(Tweet *)tweet{
    [self hasBeenUnfavorited];
    id_str = tweet.id_str;
    pic.image = tweet.image;
    [text setText:tweet.text];
    [timeStamp setText:tweet.timeStamp];
    [name setText:tweet.name];
    favorited = tweet.favorited;
    if(tweet.retweeted){
        [self hasBeenRetweeted];
    }
    if(tweet.favorited){
        [self hasBeenFavorited];
    }
    
}


-(void)fadeOutWithNewTweet:(Tweet *)tweet{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        for (UIView *view in self.subviews) {
            
            if(view.tag !=  69){
                [view setAlpha:0];
            }
        }
        
    } completion:^(BOOL finished){
        [self setNewTweet:tweet];
        [self fadeIn];
    }];
}

-(void)fadeIn{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        for (UIView *view in self.subviews) {
            [view setAlpha:1];
        }
    } completion:^(BOOL finished){
        
    }];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35,  // Start color
        1.0, 1.0, 1.0, 0.06 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}


@end
