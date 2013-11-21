//
//  CWTArrow.m
//  Crowsflight
//
//  Created by Che-Wei Wang on 6/16/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import "CWTDot.h"
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)


@implementation CWTDot

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.start=-90;
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
	CGContextSetLineWidth(context, 16);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0 alpha:1.0f].CGColor);
    if(_progress>=359.99) _progress=359.99;
    //if(_progress<=5 ) _progress=5;
    _end=_start+360-_progress;
    
    CGContextAddArc(context, ellipse.origin.x+self.radius*.5, ellipse.origin.y+self.radius*.5, self.radius*.5+8, DEGREES_TO_RADIANS(_start),DEGREES_TO_RADIANS(_end),1);
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



@end
