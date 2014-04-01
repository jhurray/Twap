//
//  TweetView.m
//  Twap
//
//  Created by Gregoire on 1/19/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "TweetView.h"

#define BTN_SIZE 35

@implementation TweetView

@synthesize id_str, retweet, favorite, pic, text, timeStamp, name, favorited, retweetIds, favoriteIds;


-(UIFont *)fontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"GillSans-Light" size:size];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAlpha:0.9];
        // Initialization code
        [self setBackgroundColor:MAINCOLOR];
        
        // arrays
        retweetIds = [NSMutableArray array];
        favoriteIds = [NSMutableArray array];
        
        //retweet
        retweet = [UIButton buttonWithType:UIButtonTypeCustom];
        [retweet setBackgroundImage:[self changeImage:[UIImage imageNamed:@"retweet.png"] toColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        CGFloat btnOffset = (DEVICEWIDTH/2 - 2*BTN_SIZE)/3;
        [retweet setFrame:CGRectMake(DEVICEWIDTH/2 +btnOffset, TV_HEIGHT-45, BTN_SIZE, BTN_SIZE)];
        [retweet setBackgroundColor:[UIColor clearColor]];
        [retweet.layer setCornerRadius:BTN_SIZE/2];
        [retweet addTarget:self action:@selector(retweetBtnPress) forControlEvents:UIControlEventTouchUpInside];
        retweet.tag = 69;
        //[retweet.layer setBorderWidth:2];
        //[retweet.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        //favorite
        favorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [favorite setBackgroundImage:[self changeImage:[UIImage imageNamed:@"favorite.png"] toColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [favorite setFrame:CGRectMake(DEVICEWIDTH/2+btnOffset*2+BTN_SIZE, TV_HEIGHT-45, BTN_SIZE, BTN_SIZE)];
        [favorite setBackgroundColor:[UIColor clearColor]];
        [favorite.layer setCornerRadius:BTN_SIZE/2];
        [favorite addTarget:self action:@selector(favoriteBtnPress) forControlEvents:UIControlEventTouchUpInside];
        favorite.tag = 69;
        //[favorite.layer setBorderWidth:2];
        //[favorite.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        //pic
        pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, TV_HEIGHT-45, 35, 35)];
        [pic setBackgroundColor:[UIColor whiteColor]];
        [pic.layer setCornerRadius:8];
        pic.layer.masksToBounds = TRUE;
        
        //name
        name = [[UILabel alloc] initWithFrame:CGRectMake(55, TV_HEIGHT-45, 105, 35)];
        name.adjustsFontSizeToFitWidth = YES;
        [name setText:@"Name"];
        [name setTextColor:[UIColor whiteColor]];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setFont:[self fontWithSize:18]];
        
        /*
        //timestamp
        timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(140, self.frame.size.height-45, 90, 35)];
        timeStamp.adjustsFontSizeToFitWidth = YES;
        [timeStamp setText:@"time stamp blah"];
        [timeStamp setTextColor:[UIColor whiteColor]];
        [timeStamp setBackgroundColor:[UIColor clearColor]];
        [timeStamp setFont:[self fontWithSize:18]];
         */
        
        //text
        text = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, DEVICEWIDTH-20, self.frame.size.height-50)];
        text.adjustsFontSizeToFitWidth = YES;
        [text setNumberOfLines:3];
        [text setText:@"This is a tweet with hopefully less than 160 characters cool brah!!!! I bet this will make it be more ok?????"];
        [text setTextColor:[UIColor whiteColor]];
        [text setBackgroundColor:[UIColor clearColor]];
        [text setFont:[self fontWithSize:18]];
        
        favorited = FALSE;
        
        [self addSubview:retweet];
        [self addSubview:favorite];
        [self addSubview:name];
        //[self addSubview:timeStamp];
        [self addSubview:text];
        [self addSubview:pic];
        
        UITapGestureRecognizer *tapText = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTextTapGesture:)];
        [self.text setUserInteractionEnabled:YES];
        [self.text addGestureRecognizer:tapText];
        
        UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNameTapGesture:)];
        UITapGestureRecognizer *tapPic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNameTapGesture:)];
        [self.pic setUserInteractionEnabled:YES];
        [self.pic addGestureRecognizer:tapPic];
        [self.name setUserInteractionEnabled:YES];
        [self.name addGestureRecognizer:tapName];
        
    }
    return self;
}
//twitter://user?screen_name=lorenb


-(void)goToTweet
{
    NSLog(@"going to tweet!!");
    NSString *urlString = [NSString stringWithFormat:@"twitter://status?id=%@", self.tweet.id_str];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(void)goToProfile
{
    NSString *urlString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", self.tweet.handle];
    NSLog(@"going to profile!!\n\n%@\n", urlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


-(void)handleNameTapGesture:(id)sender
{
    if(self.tweet)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure"
                                                        message:@"you want to leave this app to view this users profile?"
                                                       delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag = 2;
        [alert show];
    }
}

-(void)handleTextTapGesture:(id)sender
{
    if(self.tweet)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure"
                                                        message:@"you want to leave this app to view this tweet?"
             
                                                       delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag = 1;
        [alert show];
    }
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
    dispatch_async(background, ^{
        [[[TwitterDataHandler sharedInstance] twitterDeveloper] retweet:id_str];
    });
    [retweetIds addObject:id_str];
    [self hasBeenRetweeted];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    switch (alertView.tag) {
        case 0:
            // FOR RETWEET
            if([title isEqualToString:@"YES"])
            {
                [self finishRetweet];
            }
            else if([title isEqualToString:@"NO"])
            {
                return;
            }
            break;
            
        case 1:
            //FOR VIEWING TWEET
            if([title isEqualToString:@"YES"])
            {
                [self goToTweet];
            }
            else if([title isEqualToString:@"NO"])
            {
                return;
            }
            break;
            
        case 2:
            //FOR VIEWING PROFILE
            if([title isEqualToString:@"YES"])
            {
                [self goToProfile];
            }
            else if([title isEqualToString:@"NO"])
            {
                return;
            }
            break;
            
        default:
            break;
    }
    
}

-(void)retweetBtnPress
{
    if (retweet) {
        return;
    }
    NSLog(@"Retweet pressed\n");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure"
                                                    message:@"you want to retweet this?"
                                                   delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = 0;
    [alert show];
    
}

-(void)favoriteBtnPress
{
     NSLog(@"Favorite pressed\n");
    if(favorited){
        [self hasBeenUnfavorited];
        [[[TwitterDataHandler sharedInstance] twitterDeveloper] favorite:id_str Is_Create:NO];
        favorited = false;
        self.tweet.favorited = false;
        [favoriteIds removeObject:id_str];
    }
    else{
        [self hasBeenFavorited];
        [[[TwitterDataHandler sharedInstance] twitterDeveloper] favorite:id_str Is_Create:YES];
        favorited = true;
        self.tweet.favorited = true;
        [favoriteIds addObject:id_str];
        
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
    self.tweet = tweet;
    id_str = tweet.id_str;
    pic.image = tweet.image;
    [text setText:tweet.text];
    [timeStamp setText:tweet.timeStamp];
    [name setText:tweet.name];
    favorited = tweet.favorited;
    if([retweetIds containsObject:tweet.id_str]){
        [self hasBeenRetweeted];
    }
    else
    {
        [self unhiglightRetweet];
    }
    if([favoriteIds containsObject:tweet.id_str]){
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
    CGFloat components[8] = { 0.7, 0.7, 0.7, 0.55,  // Start color
        0.5, 0.5, 0.5, 0.02 }; // End color
    
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
