//
//  NewUserPromptView.m
//  Twap
//
//  Created by Gregoire on 2/26/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "NewUserPromptView.h"

@implementation NewUserPromptView

@synthesize prompt1, prompt2, prompt3, title, btn, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:MAINCOLOR];
        [self setAlpha:1];
        [self setUserInteractionEnabled:YES];
        //prompts and titles
        CGFloat promptXOffset = 20;
        //title
        title = [[UILabel alloc] initWithFrame:CGRectMake(15, 95, DEVICEWIDTH-30, 50)];
        [title setText:@"Welcome to the TWAP"];
        [title setFont:[UIFont fontWithName:@"GillSans-Light" size:36]];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [title setAdjustsFontSizeToFitWidth:YES];
        [title setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:title];
        //prompt
        prompt1 = [[UILabel alloc] initWithFrame:CGRectMake(promptXOffset, DEVICEHEIGHT*2/6-5, DEVICEWIDTH-2*promptXOffset, 30)];
        [prompt1 setText:@"The live Twitter Map"];
        [prompt1 setFont:[UIFont fontWithName:@"GillSans-Light" size:24]];
        [prompt1 setBackgroundColor:[UIColor clearColor]];
        [prompt1 setTextColor:[UIColor whiteColor]];
        [prompt1 setAdjustsFontSizeToFitWidth:YES];
        [prompt1 setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:prompt1];
        
        prompt2 = [[UILabel alloc] initWithFrame:CGRectMake(promptXOffset, DEVICEHEIGHT*3/6, DEVICEWIDTH-2*promptXOffset, 30)];
        [prompt2 setText:@"Swipe to navigate"];
        [prompt2 setFont:[UIFont fontWithName:@"GillSans-Light" size:24]];
        [prompt2 setBackgroundColor:[UIColor clearColor]];
        [prompt2 setTextColor:[UIColor whiteColor]];
        [prompt2 setAdjustsFontSizeToFitWidth:YES];
        [prompt2 setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:prompt2];
        
        prompt3 = [[UILabel alloc] initWithFrame:CGRectMake(promptXOffset, DEVICEHEIGHT*4/6, DEVICEWIDTH-2*promptXOffset, 30)];
        [prompt3 setCenter:CGPointMake(DEVICEWIDTH/2+50, prompt3.center.y)];
        [prompt3 setText:@"<==   or   ==>"];
        [prompt3 setFont:[UIFont fontWithName:@"GillSans-Light" size:24]];
        [prompt3 setBackgroundColor:[UIColor clearColor]];
        [prompt3 setTextColor:[UIColor whiteColor]];
        [prompt3 setAdjustsFontSizeToFitWidth:YES];
        [prompt3 setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:prompt3];
        
        CGFloat btnSize = 50;
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setFrame:CGRectMake(-2, DEVICEHEIGHT*5/6, DEVICEWIDTH+4, btnSize)];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:24]];
        [btn setTitle:@"Get Twapping!" forState:UIControlStateNormal];
        [btn.titleLabel setFrame:btn.frame];
        [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [btn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [btn.layer setBorderWidth:1];
        [btn addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(highlightBtn:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(unHighlightBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(unHighlightBtn:) forControlEvents:UIControlEventTouchDragOutside];
        [btn setAlpha:0];
        [self addSubview:btn];
        //animations
        [self arrowAnimation];
        [self buttonAnimation];
    }
    
    return self;
}

-(void)arrowAnimation
{
    [UIView animateWithDuration:0.8
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                         animations:^{
                            
                             [prompt3 setCenter:CGPointMake(DEVICEWIDTH/2-50, prompt3.center.y)];
                             
        } completion:^(BOOL finished) {

        }];
}

-(void)buttonAnimation
{
    [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [btn setAlpha:1];
    } completion:nil];
}

-(void)buttonPressed
{
    
    [self.delegate finishedTutorial];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)highlightBtn:(UIButton *)sender
{
    [sender setBackgroundColor:[UIColor whiteColor]];
    [sender setAlpha:0.8];
}

-(void)unHighlightBtn:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [sender setBackgroundColor:[UIColor clearColor]];
        [sender setAlpha:1.0];
    } completion:nil];
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
