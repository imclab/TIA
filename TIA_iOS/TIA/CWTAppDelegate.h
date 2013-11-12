//
//  CWTAppDelegate.h
//  Crowsflight
//
//  Created by Che-Wei Wang on 5/4/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TestFlight.h"



@class CWTViewController;

@interface CWTAppDelegate : UIResponder <UIApplicationDelegate>{
    //MTStatusBarOverlay *overlay;

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CWTViewController *viewController;
@property (nonatomic, strong) NSMutableArray *locationDictionaryArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *units;// m = 0, km = 1
@property (nonatomic) float myLat;
@property (nonatomic) float myLng;
@property (nonatomic) float heading;
@property (nonatomic) float headingAccuracy;
@property (nonatomic) float lastHeadingAccuracy;
@property (nonatomic) float speed;
@property (nonatomic) float altitude;
@property (nonatomic) float altitudeAccuracy;


@property (nonatomic) float accuracy;
@property (nonatomic,strong) UINavigationController *navController;

- (void)lookUP: (NSString *)title;


@property (nonatomic) BOOL hasInternet;


@end
