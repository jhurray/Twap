//
//  AddRegionView.m
//  Twap
//
//  Created by Gregoire on 1/19/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "AddRegionView.h"


@implementation AddRegionView

@synthesize input, instructions, promptView, newCoord, place, cityPicker;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        place = nil;
        CGFloat height = self.frame.size.height;
        [self setBackgroundColor:[UIColor darkGrayColor]];
        
        instructions = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, DEVICEWIDTH-40, height/3.6)];
        [instructions setBackgroundColor:[UIColor clearColor]];
        [instructions setTextAlignment:NSTextAlignmentCenter];
        instructions.adjustsFontSizeToFitWidth = YES;
        [instructions setText:@"Enter a city or zipcode..."];
        [instructions setTextColor:[UIColor whiteColor]];
        [instructions setFont:[UIFont fontWithName:@"GillSans-Light" size:30]];
        
        input = [[UITextField alloc] init];
        [input setBackgroundColor:[UIColor lightGrayColor]];
        [input setFrame:CGRectMake(0,instructions.frame.size.height+10 , DEVICEWIDTH, height/7.2)];
        [input setTextColor:MAINCOLOR];
        [input setText:@""];
        [input setFont:[UIFont fontWithName:@"GillSans-Light" size:24]];
        [input setTextAlignment:NSTextAlignmentCenter];
        [input becomeFirstResponder];
        [input setReturnKeyType:UIReturnKeySearch];
        input.delegate = self;
        [input setAlpha:0];
        [self addSubview:input];
        
        
        CGFloat promptViewDepth = height/1.8;
        promptView = [[UIView alloc] initWithFrame:CGRectMake(0, promptViewDepth, DEVICEWIDTH, height/2.88)];
        [promptView setBackgroundColor:[UIColor clearColor]];
        //yes button
        CGFloat sizeRatio = height/288;
        UIButton *yesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [yesBtn setBackgroundColor:[UIColor clearColor]];
        [yesBtn setFrame:CGRectMake(DEVICEWIDTH-DEVICEWIDTH/5*(1+sizeRatio), 18, DEVICEWIDTH/5*sizeRatio, DEVICEWIDTH/5*sizeRatio)];
        [yesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [yesBtn.titleLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:16]];
        [yesBtn setTitle:@"Yes" forState:UIControlStateNormal];
        [yesBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [yesBtn.layer setBorderWidth:1];
        [yesBtn.layer setCornerRadius:yesBtn.frame.size.width/2];
        [yesBtn addTarget:self action:@selector(yesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [yesBtn addTarget:self action:@selector(highlightBtn:) forControlEvents:UIControlEventTouchDown];
        [yesBtn addTarget:self action:@selector(unHighlightBtn:) forControlEvents:UIControlEventTouchUpInside];
        [yesBtn addTarget:self action:@selector(unHighlightBtn:) forControlEvents:UIControlEventTouchDragOutside];
        // no button
        UIButton *noBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [noBtn setBackgroundColor:[UIColor clearColor]];
        [noBtn setFrame:CGRectMake(DEVICEWIDTH/5, 18, DEVICEWIDTH/5*sizeRatio, DEVICEWIDTH/5*sizeRatio)];
        [noBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [noBtn.titleLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:16]];
        [noBtn setTitle:@"No" forState:UIControlStateNormal];
        [noBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [noBtn.layer setBorderWidth:1];
        [noBtn.layer setCornerRadius:yesBtn.frame.size.width/2];
        [noBtn addTarget:self action:@selector(noBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [noBtn addTarget:self action:@selector(highlightBtn:) forControlEvents:UIControlEventTouchDown];
        [noBtn addTarget:self action:@selector(unHighlightBtn:) forControlEvents:UIControlEventTouchUpInside];
        [noBtn addTarget:self action:@selector(unHighlightBtn:) forControlEvents:UIControlEventTouchDragOutside];
        //prmp view add subviews
        [promptView addSubview:yesBtn];
        [promptView addSubview:noBtn];
        [promptView setAlpha:0];
        
        [self addSubview:instructions];
        self.shown = FALSE;
    }
    return self;
}


-(void)reset
{
    
    [instructions setText:@"Enter a city or zipcode..."];
    
    [input setText:@""];
    [input becomeFirstResponder];
    [input setAlpha:0];
    
    [promptView removeFromSuperview]; //?
    [promptView setAlpha:0];
    
    [cityPicker removeFromSuperview];
    
}


-(void)animateInputBar{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [input setAlpha:1.0];
        
    } completion:^(BOOL finished) {

    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text isEqualToString:@"Too much for the TWAP!!!"]) {
        return NO;
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(place)
    {
        return NO;
    }
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
                [self promptForCorrectPlace];
                place = [(NSArray *)[[mark addressDictionary] objectForKey:@"FormattedAddressLines"] objectAtIndex:0];
                NSLog(@"Place is %@", place);
                newCoord = CLLocationCoordinate2DMake(lat, lng);
                [textField setText:place];
                [textField setTag:69];
            }
            else{
                [instructions setText:@"Invalid input. Please try again."];
                [textField setText:@""];
            }
            
        }
        else{
            [instructions setText:@"Invalid input. Please try again."];
            [textField setText:@""];
        }
    }];
    
    if (textField.tag == 69) {
        return YES;
    }
    
    return NO;
}

-(void)noBtnPressed
{
    [promptView removeFromSuperview];
    [promptView setAlpha:0];
    [instructions setText:@"Enter a city or zipcode..."];
    [input setText:@""];
    place = nil;
}

-(void)yesButtonPressed
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        promptView.alpha = 0;
    } completion:^(BOOL finished) {
        [promptView removeFromSuperview];
    }];
    // check to see if one needs deleting
    NSArray *cities = [self.delegate askForCities];
    if(cities.count >= CITYLIMIT){
        [instructions setText:@"Choose a location to delete..."];
        [input setText:@"Too much for the TWAP!!!"];
        
        cityPicker = [[UISegmentedControl alloc] initWithItems:cities];
        [cityPicker setFrame:CGRectMake(20, promptView.frame.origin.y+30, DEVICEWIDTH-40, 50)];
        [cityPicker setBackgroundColor:MAINCOLOR];
        [cityPicker setTintColor:[UIColor whiteColor]];
        [cityPicker setAlpha:0.9];
        UIFont *font = [UIFont fontWithName:@"GillSans-Light" size:14.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        [cityPicker setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [cityPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
        [cityPicker.layer setCornerRadius:0];
        [cityPicker.layer setBorderColor:[UIColor whiteColor].CGColor];
        [cityPicker.layer setBorderWidth:0.5];        [self addSubview:cityPicker];
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [cityPicker setAlpha:0.9];
        } completion:nil];
    }
    else{
        [input resignFirstResponder];
        [self.delegate addRegionWithCoordinate:newCoord andText:place andReplacement:0];
        [self cancel];
    }
}

-(void)pickerChanged:(UISegmentedControl *)picker
{
    NSArray *cities = [self.delegate askForCities];
    NSString *msg = [NSString stringWithFormat:@"you want to replace %@ with %@?",[cities objectAtIndex: [picker selectedSegmentIndex]], place];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure..."]
                                                    message:msg
                                                   delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
    alert.tag = [picker selectedSegmentIndex];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"YES"])
    {
        [input resignFirstResponder];
        [self.delegate addRegionWithCoordinate:newCoord andText:place andReplacement:alertView.tag];
        [self cancel];
    }
    else if([title isEqualToString:@"NO"])
    {
        
        return;
    }
}

-(void)highlightBtn:(UIButton *)sender
{
    [sender setBackgroundColor:MAINCOLOR];
    [sender setAlpha:0.8];
}

-(void)unHighlightBtn:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [sender setBackgroundColor:[UIColor clearColor]];
        [sender setAlpha:1.0];
    } completion:nil];
}

-(void)promptForCorrectPlace
{
    [instructions setText:@"Is this correct?"];
    [self addSubview:promptView];
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [promptView setAlpha:0.8];
    } completion:nil];
}

-(void)cancel{
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0.0];
    }];
    [self removeFromSuperview];
    [input setAlpha:0];
    self.shown = FALSE;
    place = nil;
    [self reset];
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
