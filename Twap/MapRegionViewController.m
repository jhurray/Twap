//
//  MapRegionViewController.m
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MapRegionViewController.h"

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
    NSUInteger rand = arc4random()%[map.annotations count];
    Tweet *tweet = (Tweet *)[map.annotations objectAtIndex:rand];
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

-(id)initWithMapRegion:(MKCoordinateRegion)coordRegion{
    
    if(self = [super initWithNibName:nil bundle:nil]){
        map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWIDTH, DEVICEHEIGHT-64-TV_HEIGHT)];
        [map setScrollEnabled:NO];
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

-(void)refreshTweets{
    
    [map removeAnnotations:map.annotations];
    NSDictionary *tweetsResults = [[TwitterDataHandler sharedInstance] fetchTweetsAtCoord:map.centerCoordinate andRange:(0.7*MILES)];
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
        // Button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button setFrame:CGRectMake(0, 0, 23, 23)];
        //[button setTag:[self.tagArray indexOfObject:((Tweet *)annotation).id_str]];
        //[button addTarget:self action:@selector(tweetDetail:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = button;
        
        // Image and two labels
        UIImageView *imageView = [[UIImageView alloc] initWithImage:((Tweet *)annotation).image];
        [imageView setFrame:CGRectMake(0,0,23,23)];
        [imageView.layer setCornerRadius:23.0/2.0];
        annotationView.leftCalloutAccessoryView = imageView;
        UIImage *bird = [UIImage imageNamed:@"bird.png"];
        [annotationView setImage:bird];
        [annotationView setEnabled:YES];
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
