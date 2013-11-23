//
//  CWTArrow.m
//  Crowsflight
//
//  Created by Che-Wei Wang on 6/16/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import "CWTDot.h"
#import <QuartzCore/QuartzCore.h>
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)


@implementation CWTDot

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.start=-90;
        self.lineWidth=16;
        self.animationProgress=0;
        self.lineColor=[UIColor colorWithWhite:0 alpha:1.0f];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

 - (void)drawRect:(CGRect)rect
{
    //NSLog(@"Draw Dot");
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGPoint point;
    point.x=self.frame.size.width*.5;
    point.y=self.frame.size.height*.5;

    //draw dot
    CGRect ellipse;

    ellipse.origin.x=point.x-self.radius*.5;
    ellipse.origin.y=point.y-self.radius*.5;
    
    ellipse.size.width=self.radius;
    ellipse.size.height=self.radius;
    
    
    CGContextAddEllipseInRect(context, ellipse);
    CGContextSetFillColorWithColor(context, self.dotColor.CGColor);
    CGContextFillPath(context);
    
    
    
    //progress arc
	CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    if(_progress>=359.99) _progress=359.99;
    else if(_progress<=1 ) _progress=1;
    _end=_start+360-_progress;
    
    if(_progress>1){
        CGContextAddArc(context, ellipse.origin.x+self.radius*.5, ellipse.origin.y+self.radius*.5, self.radius*.5+self.lineWidth*.5, DEGREES_TO_RADIANS(_start),DEGREES_TO_RADIANS(_end),TRUE);
    }
	CGContextStrokePath(context);
    
    

    
    
    
    
}

-(void) progress:(CGFloat)progress
{
    self.progress = progress;
    [self setNeedsDisplay];
}



-(void) inflate:(CGFloat)radius
{
    self.radius = radius;
    [self setNeedsDisplay];
}

-(void) spin : (UIViewAnimationOptions) options
{
    //[self setAlpha:1];
    
    [self progress:60];
    
    
    [UIView animateWithDuration: 0.4f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.transform = CGAffineTransformRotate(self.transform, M_PI / 2);
                         
                         if (options == UIViewAnimationOptionCurveEaseIn){
                             [self setAlpha:1];
                             [self.layer displayIfNeeded];
                         }
                          else if (options == UIViewAnimationOptionCurveEaseOut){
                              [self setAlpha:0];
                              [self.layer displayIfNeeded];
                          }
                         
                         
                         
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (self.spinning) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spin: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spin: UIViewAnimationOptionCurveEaseOut];
                             }
                             
                             else if (options == UIViewAnimationOptionCurveEaseOut){
                                  [self setAlpha:1.0f];
                                  [self progress:0];
                             }
                         }
                     }];
    


}


- (void) startSpin {
    if (!self.spinning) {
        self.spinning = YES;
        [self setAlpha:0];
        [self spin: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.spinning = NO;
}



-(void) pulse : (CGFloat) a delay:(CGFloat) d
{
    //[self setAlpha:0];
    [self setAlpha:0];

    [self progress:360];

    [UIView animateWithDuration:.4f
                          delay:d
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
                         [self setAlpha:a];
                         [self.layer displayIfNeeded];
                     }
     completion:^(BOOL finished) {
         [self setAlpha:1.0f];

     }];

}


@end
