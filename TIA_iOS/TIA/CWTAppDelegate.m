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


@interface CWTAppDelegate ()<UIAlertViewDelegate,CLLocationManagerDelegate,UIAppearanceContainer>

@end

@implementation CWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    

    [Crashlytics startWithAPIKey:@"1eb6d15737d50f2df4316cb5b8b073da76a42b67"];
    
    [TestFlight takeOff:@"54ff1c20-dfe4-44df-9cda-bb3c4957749e"];

    //playfulsystems on parse.com
    [Parse setApplicationId:@"yk0JyC64oKQCprmJwXiyJ13JmIS1HyfSvmfMAQ6w"
                  clientKey:@"sFvZ0SLtYB2kxQe4pX7QNtqIDwvaYYwuRqB4o1W5"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    NSLog(@"i am      %@", [UIDevice currentDevice].identifierForVendor.UUIDString);

    

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CWTViewController alloc] init];
    self.window.rootViewController = self.viewController;
    
    [self.viewController.view setFrame:[[UIScreen mainScreen] bounds]];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.navController setNavigationBarHidden:YES animated:NO];

    
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.navController.view];
    
    
//    self.overlay = [MTStatusBarOverlay sharedInstance];
//    self.overlay.animation = MTStatusBarOverlayAnimationShrink;
//    self.overlay.detailViewMode = MTDetailViewModeHistory;
//    self.overlay.delegate = self;
    
    
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

    //[self updateUserLocation];
    
    // Register the app for the Push- and Local-Notifications on iOS5 - else the users will not get the Local-Notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes : UIRemoteNotificationTypeBadge];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes : UIRemoteNotificationTypeAlert];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes : UIRemoteNotificationTypeSound];
    
    deviceAddedToParse=false;

    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation setObject:[UIDevice currentDevice].identifierForVendor.UUIDString forKey:@"vendorUUID"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}


-(void)updateUserLocation{
    

    //send location to parse
    //get parse Class
    PFQuery *query = [PFQuery queryWithClassName:@"TIA_Users"];

    
    //get existing entry of this device
    [query whereKey:@"vendorUUID" equalTo:[UIDevice currentDevice].identifierForVendor.UUIDString];

    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded. entry exists
            //NSLog(@"Successfully retrieved %d objects.", objects.count);
            for (PFObject *object in objects)
            {
                //NSLog(@"%@", object.objectId);
                
                   //update lat lng of user
                object[@"lat"] = [NSNumber numberWithFloat:self.myLat];
                object[@"lng"] = [NSNumber numberWithFloat:self.myLng];
                object[@"speed"] = [NSNumber numberWithFloat:self.speed];
                object[@"altitude"] = [NSNumber numberWithFloat:self.altitude];
                object[@"accuracy"] = [NSNumber numberWithFloat:self.accuracy];

                [object saveInBackground];
                NSLog(@"updated on parse");
    
            }
            
            //user not found. save new entry to database
            if(objects.count==0 && deviceAddedToParse==FALSE){
                NSLog(@"New Device");

                //add user to parse Class
                PFObject *object = [PFObject objectWithClassName:@"TIA_Users"];
                [object setObject:[UIDevice currentDevice].identifierForVendor.UUIDString forKey:@"vendorUUID"];
                [object setObject:[NSNumber numberWithFloat:self.myLat] forKey:@"lat"];
                [object setObject:[NSNumber numberWithFloat:self.myLng] forKey:@"lng"];
                [object setObject:[NSNumber numberWithFloat:self.speed] forKey:@"speed"];
                [object setObject:[NSNumber numberWithFloat:self.altitude] forKey:@"altitude"];
                [object setObject:[NSNumber numberWithFloat:self.accuracy] forKey:@"accuracy"];

                [object saveInBackground];
                deviceAddedToParse=true;
                NSLog(@"added new entry on parse");

            }
            
            if(deviceAddedToParse) self.viewController.locationViewController.mainMessage.text=@"Just added you. We'll connect you to another soon.";

        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);

        }
    }];
    
    


}

-(void) sendBackgroundLocationToServer:(CLLocation *)newLocation
{
    NSLog(@"ping in background");

    
    // REMEMBER. We are running in the background if this is being executed.
    // We can't assume normal network access.
    // bgTask is defined as an instance variable of type UIBackgroundTaskIdentifier
    
    // Note that the expiration handler block simply ends the task. It is important that we always
    // end tasks that we have started.
    
    bgTask = [[UIApplication sharedApplication]
              beginBackgroundTaskWithExpirationHandler:
              ^{
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                   }];
                  
                  // ANY CODE WE PUT HERE IS OUR BACKGROUND TASK
    
    // update parse

    self.speed = newLocation.speed;
    self.altitude= newLocation.altitude;
    self.altitudeAccuracy= newLocation.verticalAccuracy;
    self.myLat=newLocation.coordinate.latitude;
    self.myLng=newLocation.coordinate.longitude;
    [self updateUserLocation];

    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"enable_push_background_location"]){
        
           [self.viewController.locationViewController getFriendPosition:nil];
           
           //get message about me for other and push
            NSString *url = [NSString stringWithFormat:@"http://tia-poems.herokuapp.com/%f,%f,%i", self.myLat, self.myLng, 2];
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

            [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if(!error){
                    NSString *mainMess = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"background push message: %@",mainMess);

                        //send push
                   PFQuery *pushQuery = [PFInstallation query];
                   [pushQuery whereKey:@"vendorUUID" equalTo:[self.viewController.locationViewController otherUserVendorIDString]];
                   // Send push notification to query
                   PFPush *push = [[PFPush alloc] init];
                   [push setQuery:pushQuery]; // Set our Installation query
                   [push setMessage:mainMess];
                   [push sendPushInBackground];
                }
           
              }];
    }


    
    

  // AFTER ALL THE UPDATES, close the task

  if (bgTask != UIBackgroundTaskInvalid)
  {
      [[UIApplication sharedApplication] endBackgroundTask:bgTask];
       bgTask = UIBackgroundTaskInvalid;
  }

}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    NSLog(@"location update");

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        NSLog(@"location update in background");

        [self sendBackgroundLocationToServer:newLocation];

    }
    else
    {
 
        NSLog(@"location update in foreground");

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
            
            [self updateUserLocation];
     
        }
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //if(self.headingAccuracy<0)return;
    
    
    self.heading=newHeading.trueHeading; //heading in degress
    self.headingAccuracy=newHeading.headingAccuracy;

    [(CWTViewController*)self.window.rootViewController updateViewControllersWithHeading:[[NSUserDefaults standardUserDefaults] integerForKey:@"currentDestinationN"]];
    
    /*
    if(self.lastHeadingAccuracy!=self.headingAccuracy){
        if( (self.headingAccuracy <=22 && self.headingAccuracy>-1) || self.headingAccuracy==-2)
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
    */
    

    
    
}






- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"resign active");
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.locationManager startMonitoringSignificantLocationChanges];
    NSLog(@"entered background, start monitoring significant changes");


}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"will enter foreground");

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"did become active");

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //self.heading=999;
    //self.headingAccuracy=-2;
    //self.lastHeadingAccuracy=-3;


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
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    //for background cell tower position changes
    //[self.locationManager startMonitoringSignificantLocationChanges];

    
    //heading
    // check if the hardware has a compass
    if ([CLLocationManager headingAvailable] == NO) {
        // No compass is available. This application cannot function without a compass,
        self.locationManager = nil;
        UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass" message:@"This device does not have a compass." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noCompassAlert show];
    } else {
        // heading service configuration
        self.locationManager.headingFilter = kCLHeadingFilterNone;
        [self.locationManager startUpdatingHeading];
    }
    
    self.viewController.locationViewController.numPhrases=3;
    //[[NSUserDefaults standardUserDefaults] setInteger:100 forKey:@"image_scale"];
    [self.viewController.locationViewController getFriendPosition:nil];

    

    [UIApplication sharedApplication].applicationIconBadgeNumber=0;


}

#pragma mark background notifications
- (void)registerForBackgroundNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}




- (void)alert: (NSString *)title{
    
    
    //if app is in foreground.
    if([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive){
        UIAlertView *alarm=[[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alarm show];
    }
    else{
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        NSDate *now = [NSDate date];
        
        localNotification.fireDate = now;
        localNotification.alertBody = title;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 1; // increment
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        
        
    }
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
