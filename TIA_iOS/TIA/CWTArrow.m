//
//  CWTArrow.m
//  Crowsflight
//
//  Created by Che-Wei Wang on 6/16/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import "CWTArrow.h"


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
    NSLog(@"Draw Arrow");


    int thickness=1;
    CGContextRef context = UIGraphicsGetCurrentContext();

	//first line
	CGContextSetLineWidth(context,thickness);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.4 alpha:1].CGColor);
    
    CGPoint points[2];
    points[0].x=self.frame.size.width*.5;
    points[0].y=self.frame.size.height*.5;

    points[1].x=self.frame.size.width*.5;
    points[1].y=self.frame.size.height*.5-2500;

    CGContextAddLines(context, points, 2);
    CGContextStrokePath(context);
    
    
    
    //draw dot
    CGRect ellipse;
    int w=8;
    int h=8;
    ellipse.origin.x=points[0].x-w*.5;
    ellipse.origin.y=points[0].y-h*.5;
    
    ellipse.size.width=w;
    ellipse.size.height=h;
    
    
    CGContextAddEllipseInRect(context, ellipse);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.4 alpha:1].CGColor);
    CGContextFillPath(context);
    

}





@end
