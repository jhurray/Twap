//
//  MasterViewController.h
//  Twap
//
//  Created by Gregoire on 1/18/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//
#import "AddRegionView.h"
#import "MapRegionViewController.h"
#import <UIKit/UIKit.h>

@interface MasterViewController : UIViewController <UIPageViewControllerDataSource, TwitterDataDelegate, UIPageViewControllerDelegate, AddRegionDelegate, NewUserDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) MapRegionViewController *currentMapController;
@property (nonatomic, strong) UIView *fadeView;
@property (nonatomic, strong) UILabel *navBarTitle;
@property (nonatomic, strong) NSMutableArray *cities;
@property (nonatomic, strong) AddRegionView *addRegion;
@property (nonatomic, strong) UILabel *getTwapping;
@property BOOL userIsNew;

-(id)initWithCities:(NSArray *)cityArray;
-(void)promptNewUser;
@end
