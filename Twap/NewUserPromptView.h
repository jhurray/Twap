//
//  NewUserPromptView.h
//  Twap
//
//  Created by Gregoire on 2/26/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewUserDelegate <NSObject>

-(void)finishedTutorial;

@end

@interface NewUserPromptView : UIView

@property (nonatomic, weak) id<NewUserDelegate> delegate;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *prompt1;
@property (nonatomic, strong) UILabel *prompt2;
@property (nonatomic, strong) UILabel *prompt3;
@property (nonatomic, strong) UIButton *btn;


@end
