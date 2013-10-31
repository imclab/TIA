//
//  CWTAppDelegate.m
//  Crowsflight
//
//  Created by Che-Wei Wang on 5/4/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//
#import <Crashlytics/Crashlytics.h>

#import "CWTAppDelegate.h"
#import "CWTViewController.h"
#import "Reachability.h"
#import "QuartzCore/CALayer.h"
#import <Parse/Parse.h>


@interface CWTAppDelegate ()<UIAlertViewDelegate,CLLocationManagerDelegate,UIAppearanceContainer,MTStatusBarOverlayDelegate>

@end

@implementation CWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Crashlytics startWithAPIKey:@"1eb6d15737d50f2df4316cb5b8b073da76a42b67"];
    
    [TestFlight takeOff:@"54ff1c20-dfe4-44df-9cda-bb3c4957749e"];

    [Parse setApplicationId:@"oQcxap8X48yinv2iH3VqXZnztrNGZjDpytGdfobc"
                  clientKey:@"cQrK85aVhZ1YzeqSDeeKrTRcQ6lQ52dQTYvysJJy"];
    


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CWTViewController alloc] init];
    self.window.rootViewController = self.viewController;
    
    
    [self.viewController.view setFrame:[[UIScreen mainScreen] bounds]];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.navController setNavigationBarHidden:YES animated:NO];

    
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.navController.view];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        NSLog(@"Running in IOS-7");

        CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
        self.window.frame=[[UIScreen mainScreen] applicationFrame];
        self.viewController.view.frame=[[UIScreen mainScreen] applicationFrame];

        UIView* status=[[UIView alloc] initWithFrame:CGRectMake(0, -20, screenBounds.size.width, 20)];
        status.backgroundColor=[UIColor whiteColor];
        [self.window addSubview:status];
    }
    
    self.overlay = [MTStatusBarOverlay sharedInstance];
    self.overlay.animation = MTStatusBarOverlayAnimationShrink;
    self.overlay.detailViewMode = MTDetailViewModeHistory;
    self.overlay.delegate = self;
    self.headingAccuracy=-2;
    
    
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"REACHABLE!");
        self.hasInternet=TRUE;
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
        self.hasInternet=FALSE;

    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];

    return YES;
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return; //5 seconds
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    self.accuracy=newLocation.horizontalAccuracy;
    if (self.accuracy < 0) return;
    
    self.speed = newLocation.speed;
    self.altitude= newLocation.altitude;
    self.altitudeAccuracy= newLocation.verticalAccuracy;

    // update the display with the new location data
    
    if(self.myLat!=newLocation.coordinate.latitude){
        
        self.myLat=newLocation.coordinate.latitude;
        self.myLng=newLocation.coordinate.longitude;

        [(CWTViewController*)self.window.rootViewController updateViewControllersWithLatLng: [[NSUserDefaults standardUserDefaults] integerForKey:@"currentDestinationN"]];
        
        
        //send location to parse
        PFObject *pObject = [PFObject objectWithClassName:@"userlocation"];
        [pObject setObject:[UIDevice currentDevice].identifierForVendor.UUIDString forKey:@"userid"];
        [pObject setObject:[NSNumber numberWithFloat:self.myLat] forKey:@"lat"];
        [pObject setObject:[NSNumber numberWithFloat:self.myLng] forKey:@"lng"];
        [pObject saveInBackground];
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //if(self.headingAccuracy<0)return;
    
    
    self.heading=newHeading.trueHeading; //heading in degress
    self.headingAccuracy=newHeading.headingAccuracy;

    [(CWTViewController*)self.window.rootViewController updateViewControllersWithHeading:[[NSUserDefaults standardUserDefaults] integerForKey:@"currentDestinationN"]];
    
    
    if(self.lastHeadingAccuracy!=self.headingAccuracy){
        if( (self.headingAccuracy <=22 && self.headingAccuracy>-1) || self.headingAccuracy==-2)
            
        //testing
         //   if( (self.headingAccuracy <=5 && self.headingAccuracy>-1) || self.headingAccuracy==-2)

        {
            [self.overlay hideTemporary];
        }
        else
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shrink) object:nil];
            [self.overlay show];
            if(self.overlay.isShrinked==YES) [self.overlay setShrinked:NO animated:YES ];
            [self.overlay postImmediateMessage:[NSString stringWithFormat:@"Compass Accuracy: ±%i°",(int)(self.headingAccuracy)]  duration:3.0 ];
            [self.overlay postErrorMessage:@"move away from interference" duration:3.0 ];
            [self.overlay postErrorMessage:@"wave in ∞ motion to calibrate compass" duration:0];
            
            //[overlay setShrinked:YES animated:YES];
            if(self.overlay.isShrinked==NO) [self performSelector:@selector(shrink) withObject:nil afterDelay:12.0];
        }
        self.lastHeadingAccuracy=self.headingAccuracy;
    }
    
    

    
    
}


-(void) shrink{
        [self.overlay setShrinked:YES animated:YES];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.heading=999;
    self.headingAccuracy=-2;
    self.lastHeadingAccuracy=-3;


    // Create the manager object
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.locationManager.activityType=CLActivityTypeFitness;
    
    // This is the most important property to set for the manager. It ultimately determines how the manager will
    // attempt to acquire location and thus, the amount of power that will be consumed.
    //self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    // When "tracking" the user, the distance filter can be used to control the frequency with which location measurements
    // are delivered by the manager. If the change in distance is less than the filter, a location will not be delivered.
    //self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.distanceFilter = 1.0f;

    // Once configured, the location manager must be "started".
    [self.locationManager startUpdatingLocation];
    
    //for background cell tower position changes
    [self.locationManager startMonitoringSignificantLocationChanges];

    
    //heading
    self.locationManager.headingFilter = kCLHeadingFilterNone;
    [self.locationManager startUpdatingHeading];
    

}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end