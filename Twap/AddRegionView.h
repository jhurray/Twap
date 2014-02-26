//
//  AddRegionView.h
//  Twap
//
//  Created by Gregoire on 1/19/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddRegionDelegate <NSObject>

-(void)addRegionWithCoordinate:(CLLocationCoordinate2D)coord andText:(NSString *)text andReplacement:(NSUInteger)index;
-(NSArray *)askForCities;

@end

@interface AddRegionView : UIView <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id <AddRegionDelegate> delegate;
@property (nonatomic, strong) UITextField *input;
@property (nonatomic, strong) UIButton *resign;
@property (nonatomic) CLLocationCoordinate2D coord;
@property (nonatomic, strong) UILabel *instructions;
@property (nonatomic, strong) UIView *promptView;
@property (nonatomic, strong) NSString *place;
@property CLLocationCoordinate2D newCoord;
@property BOOL shown;

-(void)animateInputBar;

@end
