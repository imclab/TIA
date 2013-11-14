//
//  CWTViewController.h
//  Crowsflight
//
//  Created by Che-Wei Wang on 5/4/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWTLocationViewController.h"
#import <MapKit/MapKit.h>
#import "CWTAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

#import <Parse/Parse.h>

@interface CWTViewController : UIViewController <UITextFieldDelegate>{
    CWTAppDelegate* dele;
    UIButton *moreInfo;
    SystemSoundID audioCreate;


}
-(void)updateViewControllersWithName;
-(void)updateViewControllersWithLatLng: (int)_page;
-(void)updateViewControllersWithHeading: (int)_page;


@property (nonatomic,strong) UIPageViewController *pageView;
@property (nonatomic,strong) CWTLocationViewController* locationViewController;


@property (nonatomic,assign) BOOL showInfo;



@end

