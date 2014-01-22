//
//  AddRegionView.h
//  Twap
//
//  Created by Gregoire on 1/19/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddRegionDelegate <NSObject>

-(void)addRegionWithCoordinate:(CLLocationCoordinate2D)coord andText:(NSString *)text;

@end

@interface AddRegionView : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id <AddRegionDelegate> delegate;
@property (nonatomic, strong) UITextField *input;
@property (nonatomic, strong) UIButton *resign;
@property (nonatomic) CLLocationCoordinate2D coord;
@property (nonatomic, strong) UILabel *instructions;
@property BOOL shown;

-(void)animateInputBar;

@end
