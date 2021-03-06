//
//  AppDelegate.m
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "AppDelegate.h"
#import "MapRegionViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //start location manager
    [[LocationGetter sharedInstance] startUpdates];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSArray *cities = [[NSUserDefaults standardUserDefaults] objectForKey:@"Cities"];
    if (!cities) {
        cities = [NSArray arrayWithObjects: @"San Francisco", @"Boston", @"Seattle", nil];
    }
    self.masterVC = [[MasterViewController alloc] initWithCities:cities];
    [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:self.masterVC]];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    for (MapRegionViewController *m in self.masterVC.viewControllers) {
        [m removeAnimatedOverlay];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    for (MapRegionViewController *m in self.masterVC.viewControllers) {
        [m removeAnimatedOverlay];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setObject:self.masterVC.cities forKey:@"Cities"];

}

@end
