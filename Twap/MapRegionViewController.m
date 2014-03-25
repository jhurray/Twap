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


-(void)performFade{
    
    if ([map.annotations count] == 0) {
        Tweet *blankTweet = [[Tweet alloc] init];
        blankTweet.text = @"No recent tweets for this area :(";
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

-(void)viewDidAppear:(BOOL)animated{
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(performFade) userInfo:nil repeats:YES];
    [timer fire];
}
-(void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    [self removeAnimatedOverlay];
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    [timer invalidate];
    [self addAnimatedOverlayToAnnotation:view.annotation];
    [tweetView fadeOutWithNewTweet:((Tweet *)view.annotation)];
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(performFade) userInfo:nil repeats:YES];
}

-(id)initWithMapRegion:(MKCoordinateRegion)coordRegion andMaster:(id)master{
    
    if(self = [super initWithNibName:nil bundle:nil]){
        self.master = master;
        map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWIDTH, DEVICEHEIGHT-64-TV_HEIGHT)];
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

- (void)addTweet:(Tweet *)tweet
{
    if ([tweetsDictionary objectForKey:tweet.id_str] == nil)
    {
        [tweetsDictionary setObject:tweet forKey:tweet.id_str];
        [map addAnnotation:tweet];
        //[self.tagArray addObject:tweet.id_str];
    }
}

-(void)startRefreshTimer
{
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerSelector) userInfo:nil repeats:NO];
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

-(void)refreshTweets{
    
    self.annotationCount = 0;
    
    __block NSDictionary *tweetsResults = nil;
    [[TwitterDataHandler sharedInstance] fetchTweetsAtCoord:map.centerCoordinate andRange:(0.7*MILES) withBlock:^(NSDictionary *dict) {
        tweetsResults = dict;
        [map removeAnnotations:map.annotations];
        //NSLog(@"\n\ncenter = %f, %f\n\n", map.centerCoordinate.latitude, map.centerCoordinate.longitude);
        for (NSDictionary *subDic in tweetsResults)
        {
            NSString *geoString = [[NSString alloc] initWithFormat:@"%@", [subDic objectForKey:@"geo"]];
            if (![geoString isEqualToString:@"<null>"])
                //Tweets that have "geo"
            {
                //NSLog(@"geostring is %@\n", geoString);
                Tweet *tweet = [[Tweet alloc] initWithJSONDic:subDic];
                [self addTweet:tweet];
            }
        }
        [self performFade];
    }];
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
        
        [annotationView.layer setTransform:CATransform3DMakeRotation(-M_PI/5, 0, 0, 1)];
        
        return annotationView;
    }
    return nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    tweetView = [[TweetView alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT-TV_HEIGHT, DEVICEWIDTH, TV_HEIGHT)];
    [self.view addSubview:tweetView];
    //[self refreshTweets];
	// Do any additional setup after loading the view.
    
    if(!map.centerCoordinate.latitude && !map.centerCoordinate.longitude )
    {
        // this will be called for the current location for a new user.. good place to prompt a new user
        ((MasterViewController *)self.master).userIsNew = TRUE;
        
        [self performSelector:@selector(reloadMap) withObject:self afterDelay:3.5];
    }
    
}

-(void)reloadMap
{
    map.region = MKCoordinateRegionMakeWithDistance([[LocationGetter sharedInstance]getCoord], 1.5*METERS_PER_MILE*MILES, 1.5*METERS_PER_MILE*MILES);
    [self refreshTweets];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
