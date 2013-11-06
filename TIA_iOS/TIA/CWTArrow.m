//
//  CWTArrow.m
//  Crowsflight
//
//  Created by Che-Wei Wang on 6/16/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import "CWTArrow.h"

#import "CWTAppDelegate.h"

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@implementation CWTArrow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //int thickness=210;
    //int r=100+10+thickness*.5;

    int thickness=1;


    
    CGContextRef context = UIGraphicsGetCurrentContext();

	//arrow
	CGContextSetLineWidth(context,thickness);
    //CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1 green:1 blue:0 alpha:.7].CGColor);
    //CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:.73f blue:1 alpha:1].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0 alpha:1].CGColor);
    //CGContextAddArc(context, x, y, r,_start,_end,0);
    
    CGPoint points[2];
    points[0].x=self.frame.size.width*.5;
    points[0].y=self.frame.size.height*.5;

    points[1].x=self.frame.size.width*.5;
    points[1].y=self.frame.size.height*.5-2000;

    CGContextAddLines(context, points, 2);
    CGContextStrokePath(context);
    
    CGRect ellipse;
    
    
    int w=10;
    int h=10;
    ellipse.origin.x=points[0].x-w*.5;
    ellipse.origin.y=points[0].y-h*.5;

    ellipse.size.width=w;
    ellipse.size.height=h;
    
    
    CGContextAddEllipseInRect(context, ellipse);

    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:1].CGColor);
    CGContextFillPath(context);

    

}


-(void) updateSpread:(CGFloat)newSpread
{
    self.spread = newSpread;
    [self setNeedsDisplay];
}





@end
