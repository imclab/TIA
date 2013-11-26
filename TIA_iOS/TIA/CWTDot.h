//
//  CWTArrow.h
//  Crowsflight
//
//  Created by Che-Wei Wang on 6/16/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWTDot : UIView{
    
    UIImageView * heartImage;
}



@property (nonatomic,strong)  UIColor* dotColor;
@property (nonatomic,strong)  UIColor* lineColor;

@property (nonatomic,assign) float radius;
@property (nonatomic,assign) int start;
@property (nonatomic,assign) int end;
@property (nonatomic,assign) int progress;
@property (nonatomic,assign) int lineWidth;
@property (nonatomic,assign) int animationProgress;
@property (nonatomic,assign) BOOL spinning;

-(void) inflate:(CGFloat)radius;
-(void) progress:(CGFloat)progress;
-(void) pulse : (CGFloat) increaseTo delay:(CGFloat) d;
-(void) spin : (UIViewAnimationOptions) options;
- (void) startSpin ;
- (void) stopSpin;

@end
