//
//  CWTArrow.h
//  Crowsflight
//
//  Created by Che-Wei Wang on 6/16/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWTArrow : UIView

@property (nonatomic,assign) float spread;
@property (nonatomic,assign) float start;
@property (nonatomic,assign) float end;

@property (nonatomic,assign) BOOL showExtras;

-(void) updateSpread:(CGFloat)newSpread;

@end
