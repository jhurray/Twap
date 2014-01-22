//
//  AddRegionView.m
//  Twap
//
//  Created by Gregoire on 1/19/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "AddRegionView.h"

@implementation AddRegionView

@synthesize input, resign, instructions;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor darkGrayColor]];
        input = [[UITextField alloc] init];
        [input setBackgroundColor:[UIColor lightGrayColor]];
        [input setFrame:CGRectMake(0, 100, 320, 40)];
        [input setTextColor:MAINCOLOR];
        [input setText:@""];
        [input setFont:[UIFont fontWithName:@"GillSans-Light" size:24]];
        [input setTextAlignment:NSTextAlignmentCenter];
        [input becomeFirstResponder];
        [input setReturnKeyType:UIReturnKeySearch];
        input.delegate = self;
        [input setAlpha:0];
        [self addSubview:input];
        
        resign = [UIButton buttonWithType:UIButtonTypeCustom];
        [resign setBackgroundColor:MAINCOLOR];
        [resign setFrame:CGRectMake(280, 80, 40, 40)];
        [resign.layer setCornerRadius:20];
        [resign setTitle:@"X" forState:UIControlStateNormal];
        [resign addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        resign.alpha = 0;
        [self addSubview:resign];
        
        instructions = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, DEVICEWIDTH-40, 80)];
        [instructions setBackgroundColor:[UIColor clearColor]];
        [instructions setTextAlignment:NSTextAlignmentCenter];
        instructions.adjustsFontSizeToFitWidth = YES;
        [instructions setText:@"Enter a city or zipcode..."];
        
        [instructions setTextColor:[UIColor whiteColor]];
        [instructions setFont:[UIFont fontWithName:@"GillSans-Light" size:30]];
        [self addSubview:instructions];
        self.shown = FALSE;
    }
    return self;
}

-(void)animateInputBar{
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [input setAlpha:1.0];
        [resign setAlpha:1.0];
        
    } completion:^(BOOL finished) {

    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
        [instructions setText:@"Searching..."];
        CLGeocoder* gc = [[CLGeocoder alloc] init];
    [gc geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if(!error){
            
            if (placemarks.count > 0) {
                CLPlacemark* mark = (CLPlacemark*)[placemarks objectAtIndex:0];
                double lat = mark.location.coordinate.latitude;
                double lng = mark.location.coordinate.longitude;
                NSLog(@"lat and long for new region are %f, %f", lat, lng);
                [self.delegate addRegionWithCoordinate:CLLocationCoordinate2DMake(lat, lng) andText:textField.text];
                [self cancel];
                [textField resignFirstResponder];
                [textField setTag:69];
            }
            else{
                [instructions setText:@"Invalid input. Please try again."];
            }
            
        }
        else{
            [instructions setText:@"Invalid input. Please try again."];
        }
    }];
    
    if (textField.tag == 69) {
        return YES;
    }
    
    return NO;
}


-(void)cancel{
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0.0];
    }];
    [self removeFromSuperview];
    self.shown = FALSE;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
