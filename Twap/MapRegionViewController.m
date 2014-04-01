//
//  MapRegionViewController.m
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MapRegionViewController.h"
#import "MasterViewController.h"

@interface MapRegionViewController ()

@end

@implementation MapRegionViewController
@synthesize map, index;
@synthesize tweetsDictionary;
@synthesize mapDist;
@synthesize tweetView;
@synthesize timer;
@synthesize cityName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.visible = FALSE;
        self.annotationCount = 0;
    }
    return self;
}


-(id)initWithMapRegion:(MKCoordinateRegion)coordRegion andMaster:(id)master{
    
    if(self = [super initWithNibName:nil bundle:nil]){
        self.master = master;
        map = [[MKMapView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT+STATUSBARHEIGHT, DEVICEWIDTH, DEVICEHEIGHT-64-TV_HEIGHT)];
        [map setScrollEnabled:NO];
        [map setRotateEnabled:NO];
        [map setZoomEnabled:NO];
        [map setRegion:coordRegion];
        map.delegate = self;
        [self.view addSubview:map];
        MKMapRect mapRect = map.visibleMapRect;
        MKMapPoint eastPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
        MKMapPoint westPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
        mapDist = MKMetersBetweenMapPoints(eastPoint, westPoint);
        [self refreshTweets];
    }
    
    return self;
}

//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * VIEW DELEGATE * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tweetView = [[TweetView alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT-TV_HEIGHT, DEVICEWIDTH, TV_HEIGHT)];
    [self.view addSubview:tweetView];
    //[self refreshTweets];
	// Do any additional setup after loading the view.
    
    
    // only for the current view...
    if(!map.centerCoordinate.latitude && !map.centerCoordinate.longitude )
    {
        // this will be called for the current location for a new user.. good place to prompt a new user
        ((MasterViewController *)self.master).userIsNew = TRUE;
        [self performSelector:@selector(reloadMap) withObject:self afterDelay:1.5];
    }
    
}



-(void)viewDidAppear:(BOOL)animated{
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(performFade) userInfo:nil repeats:YES];
    [timer fire];
}
-(void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    [self removeAnimatedOverlay];
    
}

//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * MAP DELEGATE * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


-(void)jumpAnimationForAnnotationView:(MKAnnotationView *)view
{
    CABasicAnimation *jump = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [jump setAutoreverses:YES];
    [jump setDuration:0.5];
    //[jump setRepeatCount:5];
    [jump setFromValue:[NSNumber numberWithFloat:1.0]];
    [jump setToValue:[NSNumber numberWithFloat:1.3]];
    [view.layer addAnimation:jump forKey:@"jump"];

}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    [timer invalidate];
    [self addAnimatedOverlayToAnnotation:view.annotation];
    [tweetView fadeOutWithNewTweet:((Tweet *)view.annotation)];
    
    // animate selection
    [self jumpAnimationForAnnotationView:view];
     
    timer = [NSTimer scheduledTimerWithTimeInterval:TWEETDURATION target:self selector:@selector(performFade) userInfo:nil repeats:YES];
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self removeAnimatedOverlay];
    [view.layer removeAllAnimations];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"MapPin";
    if([annotation isKindOfClass:[Tweet class]])
    {
        MKAnnotationView *annotationView = (MKAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else
        {
            [annotationView setAnnotation:annotation];
        }
        
        // Image and two labels
        UIImageView *imageView = [[UIImageView alloc] initWithImage:((Tweet *)annotation).image];
        [imageView setFrame:CGRectMake(0,0,23,23)];
        [imageView.layer setCornerRadius:23.0/2.0];
        annotationView.leftCalloutAccessoryView = imageView;
        UIImage *bird = [UIImage imageNamed:@"bird.png"];
        [annotationView setImage:bird];
        [annotationView setEnabled:YES];
        // rotate birdy
        [annotationView.layer setTransform:CATransform3DMakeRotation(-M_PI/5, 0, 0.3, 1)];
        
        return annotationView;
    }
    return nil;
}

//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * SELECTORS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-(void)refreshTweets{
    
    self.annotationCount = 0;
    
    [[TwitterDataHandler sharedInstance] fetchTweetsAtCoord:map.centerCoordinate andRange:(0.7*MILES) withBlock:^(NSArray *tweets)
     {
         NSLog(@"\nrefreshing tweets for %@\n", cityName);
        [map removeAnnotations:map.annotations];
         for (Tweet *t in tweets) {
             [map addAnnotation:t];
         }
         NSLog(@"\n annotation count is %lu\n", (unsigned long)[map.annotations count]);
        [self performFade];
    }];
}


- (void)addTweet:(Tweet *)tweet
{
    if ([tweetsDictionary objectForKey:tweet.id_str] == nil)
    {
        [tweetsDictionary setObject:tweet forKey:tweet.id_str];
        [map addAnnotation:tweet];
        //[self.tagArray addObject:tweet.id_str];
    }
}


-(void)reloadMap
{
    map.region = MKCoordinateRegionMakeWithDistance([[LocationGetter sharedInstance]getCoord], 1.5*METERS_PER_MILE*MILES, 1.5*METERS_PER_MILE*MILES);
    [self refreshTweets];
}

-(void)performFade{
    
    if ([map.annotations count] == 0) {
        Tweet *blankTweet = [[Tweet alloc] init];
        blankTweet.text = @"No recent tweets for this area :-(";
        blankTweet.favorited = NO;
        blankTweet.retweeted = NO;
        [tweetView fadeOutWithNewTweet:blankTweet];
        return;
    }
    if (self.annotationCount == map.annotations.count) {
        self.annotationCount = 0;
    }
    Tweet *tweet = (Tweet *)[map.annotations objectAtIndex:self.annotationCount];
    self.annotationCount++;
    [self addAnimatedOverlayToAnnotation:tweet];
    [tweetView fadeOutWithNewTweet:tweet];
    
}

-(void)startRefreshTimer
{
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:TWEETDURATION target:self selector:@selector(timerSelector) userInfo:nil repeats:NO];
}

-(void)timerSelector{
    NSLog(@"\n\nBOOM %@!!!!!\n\n", cityName);
    [self refreshTweets];
}

-(void)stopTimer
{
    NSLog(@"\n\nInvalidating %@!!!!!\n\n", cityName);
    [self.refreshTimer invalidate];
}




//* * * * * * * * * * * * * * * * * * * * * * * * * * * * ANIMATED OVERLAY * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


static AnimatedOverlay *animatedOverlay;

-(void)removeAnimatedOverlay{
    if(animatedOverlay){
        [animatedOverlay stopAnimating];
        [animatedOverlay removeFromSuperview];
    }
}

-(void)addAnimatedOverlayToAnnotation:(id<MKAnnotation>)annotation{
    //get a frame around the annotation
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, mapDist/5, mapDist/5);
    CGRect rect = [map convertRegion:region toRectToView:map];
    //set up the animated overlay
    if(!animatedOverlay){
        animatedOverlay = [[AnimatedOverlay alloc] initWithFrame:rect];
    }
    else{
        [animatedOverlay setFrame:rect];
    }
    //add to the map and start the animation
    [map addSubview:animatedOverlay];
    [animatedOverlay startAnimatingWithColor:MAINCOLOR andFrame:rect];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
