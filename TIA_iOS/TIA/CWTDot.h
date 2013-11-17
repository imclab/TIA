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
@property (nonatomic,assign) float radius;
@property (nonatomic,assign) float start;
@property (nonatomic,assign) float end;
@property (nonatomic,assign) float progress;

-(void) inflate:(CGFloat)radius;
-(void) progress:(CGFloat)progress;

@end
