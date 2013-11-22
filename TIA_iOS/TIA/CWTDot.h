//
//  CWTArrow.h
//  Crowsflight
//
//  Created by Che-Wei Wang on 6/16/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWTDot : UIView



@property (nonatomic,strong)  UIColor* dotColor;
@property (nonatomic,strong)  UIColor* lineColor;

@property (nonatomic,assign) float radius;
@property (nonatomic,assign) float start;
@property (nonatomic,assign) float end;
@property (nonatomic,assign) float progress;
@property (nonatomic,assign) int lineWidth;
@property (nonatomic,assign) int animationProgress;

-(void) inflate:(CGFloat)radius;
-(void) progress:(CGFloat)progress;
-(void) loadingAnimation;
@end
