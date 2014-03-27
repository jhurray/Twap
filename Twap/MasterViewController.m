//
//  MasterViewController.m
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MasterViewController.h"
#import <dispatch/dispatch.h>


@interface MasterViewController ()

@end

@implementation MasterViewController

@synthesize pageController, viewControllers, currentMapController;
@synthesize fadeView, navBarTitle, cities, addRegion, userIsNew, getTwapping;


-(id)initWithCities:(NSArray *)cityArray
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        
        viewControllers = [NSMutableArray array];
        
        cities = [NSMutableArray arrayWithArray:cityArray];
        
        addRegion = [[AddRegionView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWIDTH, DEVICEHEIGHT-64-KEYBOARDHEIGHT)];
        
    }
    return self;
}


//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * VIEW DELEGATES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, DEVICEWIDTH-80, 44)];
    navBarTitle.backgroundColor = [UIColor clearColor];
    navBarTitle.textAlignment = NSTextAlignmentCenter;
    navBarTitle.textColor = [UIColor whiteColor];
    [navBarTitle setAdjustsFontSizeToFitWidth:YES];
    navBarTitle.font = [UIFont fontWithName:@"GillSans-Light" size:24];
    navBarTitle.text = @"Current Location";
    [self.navigationItem setTitleView:navBarTitle];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshCurrentView)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[self changeImage:[UIImage imageNamed:@"addButton.png"] toColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTintColor:[UIColor whiteColor]];
    [btn setFrame:BARBUTTONFRAME];
    [btn addTarget:self action:@selector(addRegionToPages) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIView *navCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWIDTH, 44)];
    [navCover setAlpha:0.8];
    [navCover setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:navCover];
    
    UIView *backgroundSheet = [[UIView alloc] initWithFrame:self.view.frame];
    [backgroundSheet setBackgroundColor:MAINCOLOR];
    [backgroundSheet setAlpha:0.7];
    UILabel *twap = [[UILabel alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT/2-150, DEVICEWIDTH, 200)];
    [twap setText:@"Twap"];
    [twap setTextAlignment:NSTextAlignmentCenter];
    [twap setTextColor:[UIColor whiteColor]];
    [twap setFont:[UIFont fontWithName:@"GillSans-Light" size:45]];
    [backgroundSheet addSubview:twap];
    [self.view addSubview:backgroundSheet];
    
    [self.view sendSubviewToBack:backgroundSheet];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [[LocationGetter sharedInstance] getLatitude];
    zoomLocation.longitude = [[LocationGetter sharedInstance] getLongitude];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1.5*MILES*METERS_PER_MILE,1.5*MILES*METERS_PER_MILE);
    MapRegionViewController *currentLocationMapRegion;
    currentLocationMapRegion = [[MapRegionViewController alloc] initWithMapRegion:viewRegion andMaster:self];
    currentLocationMapRegion.cityName = @"Current Location";
    currentLocationMapRegion.index = [viewControllers count];
    [self.viewControllers addObject:currentLocationMapRegion];
    
    
    //adding the page view controller
    pageController = [[UIPageViewController alloc ] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageController.delegate = self;
    [pageController setDataSource:self];
    [pageController setTransitioningDelegate:self];
    [pageController.view setFrame:CGRectMake(0, 0, DEVICEWIDTH, DEVICEHEIGHT+PAGEVIEWOFFSET)];
    NSArray *vcs = [NSArray arrayWithObject:viewControllers[0]];
    [pageController setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        //any completion code???
    }];
    
    [self addChildViewController:pageController];
    [self.view addSubview:pageController.view];
    [pageController didMoveToParentViewController:self];
    
    fadeView = [[UIView alloc] initWithFrame:self.view.frame];
    [fadeView setBackgroundColor:MAINCOLOR];
    
    getTwapping = [[UILabel alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT/2-100, 320, 200)];
    [getTwapping setText:@"Get Ready..."];
    [getTwapping setTextColor:[UIColor whiteColor]];
    [getTwapping setTextAlignment:NSTextAlignmentCenter];
    [getTwapping setFont:[UIFont fontWithName:@"GillSans-Light" size:45]];
    [fadeView addSubview:getTwapping];
    [self.view addSubview:fadeView];
	// Do any additional setup after setting the fade view.
    
    [self loadCities];

}

//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * FIRST TIME USE * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


-(void)promptNewUser
{
    NewUserPromptView *prompt = [[NewUserPromptView alloc] initWithFrame:self.view.frame];
    [prompt setDelegate:self];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view addSubview:prompt];
    } completion:nil];
    [navBarTitle setText:@"How to TWAP"];
    userIsNew = FALSE;
}

-(void)finishedTutorial
{
    MapRegionViewController *currLocVC = viewControllers[0];
    [pageController setViewControllers:[NSArray arrayWithObject:currLocVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        
    }];
    [currLocVC reloadMap];
    [navBarTitle setText:currLocVC.cityName];
    [self removeFadeView];
}


//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INITIALIZING * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


-(void)loadCities{
    
    CLGeocoder* gc = [[CLGeocoder alloc] init];
    [gc geocodeAddressString:cities[viewControllers.count-1] completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] != 0)
        {
            // get the first one
            CLPlacemark* mark = (CLPlacemark*)[placemarks objectAtIndex:0];
            double lat = mark.location.coordinate.latitude;
            double lng = mark.location.coordinate.longitude;
            NSLog(@"lat and long are %f, %f", lat, lng);
            
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat, lng), 1.5*MILES*METERS_PER_MILE,1.5*MILES*METERS_PER_MILE);
            MapRegionViewController *currentLocationMapRegion = [[MapRegionViewController alloc] initWithMapRegion:viewRegion andMaster:nil];
            currentLocationMapRegion.cityName = cities[viewControllers.count-1]
            ;
            currentLocationMapRegion.index = [viewControllers count];
            [self.viewControllers addObject:currentLocationMapRegion];
        }
        else{
            NSLog(@"\n\nBAD!!!\n\n");
        }
        if(cities.count+1 > viewControllers.count){
            [self loadCities];
            NSLog(@"%lu, %lu", (unsigned long)cities.count, (unsigned long)viewControllers.count);
        }
        else
        {
            NSLog(@"\n\nFinished loading cities\n\n");
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [getTwapping setAlpha:0.0];
                
            } completion:^(BOOL finished){
                [getTwapping setText:@"Get Set..."];
                [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    [getTwapping setAlpha:1.0];
                    
                } completion:^(BOOL finished){
                
                }];
            }];
            [self performSelector:@selector(loadUpMapViews) withObject:self afterDelay:1.5];
        }
    }];
}


-(void)loadUpMapViews
{
    for (MapRegionViewController *m in viewControllers) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            NSArray *vcs = [NSArray arrayWithObject:m];
            [pageController setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                //any completion code???
            }];
        } completion:^(BOOL finished){
            
        }];
    }
    
    __weak MasterViewController *me = self;
    __block UILabel *b_label = getTwapping;
    NSArray *vcs = [NSArray arrayWithObject:viewControllers[0]];
    [pageController setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        [me performSelector:@selector(removeFadeView) withObject:nil afterDelay:2.0];
        NSLog(@"\n\nFinished loading map views\n\n");
        
        [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [b_label setAlpha:0.0];
            
        } completion:^(BOOL finished){
            [b_label setText:@"Get Twapping!!!"];
            [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [b_label setAlpha:1.0];
                
            } completion:^(BOOL finished){
                if (me.userIsNew) {
                    [me promptNewUser];
                }
            }];
        }];
        
    }];
}



//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * SELECTORS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-(void)removeFadeView{
    
    if(![self.view.subviews containsObject:fadeView]){
        return;
    }
    
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [fadeView setAlpha:0];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    } completion:^(BOOL finished){
        
        [fadeView removeFromSuperview];
    }];
    
}

//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * REFRESHERS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-(void)refreshCurrentView{
    
    
    [fadeView setAlpha:1];
    for (UILabel *l in fadeView.subviews) {
        [l setText:@"Refreshing..."];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view addSubview:fadeView];
    [self performSelector:@selector(removeFadeView) withObject:self afterDelay:3];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [currentMapController refreshTweets];
        [currentMapController removeAnimatedOverlay];
    });
    
}


//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ADD REGION FUNCS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-(void)addRegionToPages{
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotate setRemovedOnCompletion:NO];
    [rotate setFillMode:kCAFillModeForwards];
    
    if(addRegion.shown)
    {
        [rotate setFromValue:[NSNumber numberWithFloat:-M_PI/4]];
        [rotate setToValue:[NSNumber numberWithFloat:0]];
        [rotate setDuration:0.6];
        [self.navigationItem.rightBarButtonItem.customView.layer addAnimation:rotate forKey:@"toAddRotation"];
        [addRegion cancel];
        return;
    }
    
    [rotate setFromValue:[NSNumber numberWithFloat:0]];
    [rotate setToValue:[NSNumber numberWithFloat:-M_PI/4]];
    [rotate setDuration:0.6];
    [self.navigationItem.rightBarButtonItem.customView.layer addAnimation:rotate forKey:@"toCancelRotation"];
    
    addRegion.delegate = self;
    addRegion.shown = TRUE;
    [addRegion.input setSelected:YES];
    [addRegion.input becomeFirstResponder];
    [addRegion setAlpha:0.0];
    [addRegion.input setText:@""];
    [self.view addSubview:addRegion];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [addRegion setAlpha:0.9];
    } completion:^(BOOL finished) {
        
        [addRegion animateInputBar];
    }];
    
}


-(NSArray *)askForCities
{
    return cities;
}

-(void)addRegionWithCoordinate:(CLLocationCoordinate2D)coord andText:(NSString *)text andReplacement:(NSUInteger)index{
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotate setRemovedOnCompletion:NO];
    [rotate setFillMode:kCAFillModeForwards];
    
    [rotate setFromValue:[NSNumber numberWithFloat:-M_PI/4]];
    [rotate setToValue:[NSNumber numberWithFloat:0]];
    [rotate setDuration:0.6];
    [self.navigationItem.rightBarButtonItem.customView.layer addAnimation:rotate forKey:@"toAddRotation"];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 1.5*MILES*METERS_PER_MILE,1.5*MILES*METERS_PER_MILE);
    MapRegionViewController *currentLocationMapRegion = [[MapRegionViewController alloc] initWithMapRegion:viewRegion andMaster:nil];
    NSLog(@"%@", cities);
    if(cities.count == CITYLIMIT){
        [cities removeObject:[cities objectAtIndex:index]];
        [viewControllers removeObject:[viewControllers objectAtIndex:index+1]];
        NSLog(@"Citys = %ui, vcs = %ui", (unsigned int)cities.count, (unsigned int)viewControllers.count);
        assert(cities.count == viewControllers.count-1);
        for (int i = 0; i < CITYLIMIT; ++i) {
            ((MapRegionViewController *)[viewControllers objectAtIndex:i]).index = i;
        }
    }
    currentLocationMapRegion.cityName = text;
    [cities addObject:text];
    currentLocationMapRegion.index = [viewControllers count];
    [viewControllers addObject:currentLocationMapRegion];
    
    __block UILabel *blockNavTitle = navBarTitle;
    [pageController setViewControllers:[NSArray arrayWithObject:currentLocationMapRegion] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        [blockNavTitle setText:text];
    }];
    
}


//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * PAGE VIEW CONTROLLER * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    //return [[TwitterDataSource sharedInstance] numRegions];
    return [viewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(MapRegionViewController *)viewController index];
    currentMapController = (MapRegionViewController *)viewController;
    NSLog(@"Current city is: %@\n", currentMapController.cityName);
    
    if (index == 0) {
        return [self viewControllerAtIndex:([viewControllers count]-1)];
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(MapRegionViewController *)viewController index];
    currentMapController = (MapRegionViewController *)viewController;
    index++;
    
    if (index == [viewControllers count]) {
        return [self viewControllerAtIndex:0];
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (MapRegionViewController *)viewControllerAtIndex:(NSUInteger)index {
    

    return [viewControllers objectAtIndex:index];
    
}

static NSString *cityName;
// Sent when a gesture-initiated transition begins.
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [navBarTitle setAlpha:0];
    
    cityName = ((MapRegionViewController *)pendingViewControllers[0]).cityName;
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [navBarTitle setAlpha:1];
    if(completed){
        ((MapRegionViewController *)previousViewControllers[0]).visible = FALSE;
        ((MapRegionViewController *)pageViewController.viewControllers[0]).visible = FALSE;
        [((MapRegionViewController *)previousViewControllers[0]) startRefreshTimer];
        [((MapRegionViewController *)pageViewController.viewControllers[0]) stopTimer];
        [navBarTitle setText:cityName];
    }
}

// Delegate may specify a different spine location for after the interface orientation change. Only sent for transition style 'UIPageViewControllerTransitionStylePageCurl'.
// Delegate may set new view controllers or update double-sided state within this method's implementation as well.
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [pageController setDoubleSided:YES];
    return UIPageViewControllerSpineLocationMid;
}

-(UIImage *)changeImage:(UIImage *)image toColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 200, 200);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    return flippedImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
