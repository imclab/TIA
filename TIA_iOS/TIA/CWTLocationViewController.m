//
//  cfLocationViewController.m
//  Crowsflight
//
//  Created by Che-Wei Wang on 5/4/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import "CWTLocationViewController.h"
#import "CWTAppDelegate.h"
#import "CWTViewController.h"
#define EARTH_RAD_M 3956.0
#define EARTH_RAD_KM 6367.0
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DISTANCE_TEXT_TAG 1

@interface CWTLocationViewController ()

@end

@implementation CWTLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.progress=1;
    
    dele = [[UIApplication sharedApplication] delegate];
    CGRect screen = [[UIScreen mainScreen] applicationFrame];
    
    
    //scrollview for pull to refresh
    self.scrollView=[[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled=YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.frame=CGRectMake(0,-50, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds)+50);
    self.scrollView.contentSize = screen.size;

    self.mainView=[[UIView alloc] init];
    self.mainView.frame=CGRectMake(0,50, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds));
    //self.mainView.backgroundColor=[UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    
    [self.scrollView addSubview:self.mainView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width , self.view.frame.size.height+55);

    
    //add down arrow
    self.dnArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.dnArrow.center=CGPointMake(screen.size.width*.5,80);
    [self.dnArrow setImage:[UIImage imageNamed:@"arrow-dn.png"]];
    //[self.dnArrow  setAlpha:.5];
    [self.mainView addSubview: self.dnArrow];
 
    
    
    
    //main arrow
    self.arrow=[[CWTArrow alloc] initWithFrame:CGRectMake(0,0, 10,screen.size.height*2)];
    [self.arrow setCenter:CGPointMake(screen.size.width*.5, screen.size.height*.5+250)];
    self.arrow.backgroundColor=[UIColor clearColor];
    [self.arrow setHidden:TRUE];
    [self.scrollView addSubview:self.arrow];

    
    int moreYpos=50;
    
    //stats
    self.displayText=[[UILabel alloc] initWithFrame:CGRectMake(20, screen.size.height-moreYpos-44+20, 200, 90)];
    self.displayText.numberOfLines=10;
    self.displayText.backgroundColor=[UIColor clearColor];
    self.displayText.textColor=[UIColor colorWithWhite:.3 alpha:1];
    [self.displayText setFont:[UIFont fontWithName:@"Andale Mono" size:7.0]];
    [self.mainView addSubview:self.displayText];
    

    
    //add satSearchImage
    self.satSearchImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.satSearchImage.center=CGPointMake(screen.size.width*.95,80);
    self.satSearchImage.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"satellite_0003.png"],
                                           [UIImage imageNamed:@"satellite_0002.png"],
                                           [UIImage imageNamed:@"satellite_0001.png"],
                                           [UIImage imageNamed:@"satellite_0000.png"], nil];
    self.satSearchImage.animationDuration = 2.0f;
    self.satSearchImage.animationRepeatCount = 0;
    [self.satSearchImage startAnimating];
    [self.scrollView addSubview: self.satSearchImage];
    self.satSearchImage.hidden=TRUE;
    
    [self updateHeading];
    

    //time from launch
    self.time=[[UILabel alloc] initWithFrame:CGRectMake(0, screen.size.height*.5, screen.size.width, 20)];
    self.time.numberOfLines=10;
    self.time.textColor=[UIColor colorWithWhite:.3 alpha:1];
    [self.time setFont:[UIFont fontWithName:@"Andale Mono" size:20.0]];
    [self.time setTextAlignment:NSTextAlignmentCenter];

    [self.mainView addSubview:self.time];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];


    
    //refresh on a timer
    //NSTimer* timer = [NSTimer timerWithTimeInterval:20.0f target:self selector:@selector(getFriendPosition) userInfo:nil repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getFriendPosition:)forControlEvents:UIControlEventValueChanged];
    [self.mainView addSubview:refreshControl];

}


-(void)viewWillDisappear:(BOOL)animated{
    [self.arrow setAlpha:0.0];
    [self.arrow setHidden:TRUE];
}


-(void)viewDidDisappear:(BOOL)animated{
    [self.arrow setAlpha:0.0];
    [self.arrow setHidden:TRUE];
}


-(void)viewWillAppear:(BOOL)animated{
    [self loadLocation];
    [self.arrow setAlpha:0.0];
    [self.arrow setHidden:FALSE];
    [self showHideInfo:0];

}

-(void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"show page %i",[[NSUserDefaults standardUserDefaults] integerForKey:@"currentDestinationN"]);
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.page forKey:@"currentDestinationN"];


    [UIView animateWithDuration:0.4f
                          delay:0.2f
                        options: UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^(void){
                         [self.arrow setAlpha:1.0f];

                     }
                     completion: ^(BOOL finished){
                         //[self.arrow setHidden:FALSE];
                     }];
    //[self spinArc];
    
    
    
}

-(void)viewDidLayoutSubviews{
    //self.arrow.center=CGPointMake(self.distanceText.center.x, self.distanceText.center.y);
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrolling");

    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
//    if(scrollView.contentOffset.y>-30){
//        NSLog(@"refresh");
//        
//    }
}



-(void)loadLocation{
    //[self calculateMaxDist];
    [self getFriendPosition:nil];
    
    [self updateDistanceWithLatLng:0];
    //[self getBearing];
}


-(void)updateDistanceWithLatLng: (float)duration{
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:dele.myLat longitude:dele.myLng];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:self.dlat longitude:self.dlng];
    //distance in meters
    self.distance = [locA distanceFromLocation:locB];
    self.locBearing=[self getBearing];
    [self getBearingAccuracy];
    
    

    
    
    //near destination
    if( self.distance<= 20.0 && self.distance>=0 && dele.accuracy>0){
        self.satSearchImage.hidden=TRUE;
        //self.accuracyText.text=  @"ARRIVED" ;
        [self rotateArc:duration degrees:self.locBearing-dele.heading];

        self.spinning=FALSE;
    }
    
    //positioning
    else if( (self.distance<= dele.accuracy*.5 && dele.accuracy > 20.0) || dele.accuracy<=0){
        self.accuracyText.text=@"";
        self.satSearchImage.hidden=FALSE;
        if(self.spinning==FALSE) {
            [self spinArc];
            self.spinning=TRUE;
        }
    }
    
    //normal pointing state
    else{
        //arc max set to 10km
        //self.progress = self.distance / 10000.0  * [self.arcProgressView maxArc];
        self.satSearchImage.hidden=TRUE;
        [self rotateArc:duration degrees:self.locBearing-dele.heading];
        self.spinning=FALSE;
        
        
        if([dele.units isEqual:@"m"]){
            self.accuracyText.text=[NSString stringWithFormat:@"± %i'",(int)(dele.accuracy*3.2808399) ];
        }
        else {
            self.accuracyText.text=[NSString stringWithFormat:@"± %im",(int)dele.accuracy ];
        }
        
        
    }
    
    
    //always update distance
    if([dele.units isEqual:@"m"]){
        
        if(self.distance<402.336){ //.25 miles in meters
            self.distanceText.text= [NSString stringWithFormat:@"%i",(int)(self.distance*3.28084)];
            self.unitText.text=@"FEET";
            
        }else{
            self.distanceText.text= [NSString stringWithFormat:@"%.2f",self.distance*0.000621371];
            self.unitText.text=@"MILES";
        }
        
    }
    else {
        if(self.distance<1000){
            self.distanceText.text= [NSString stringWithFormat:@"%i",(int)self.distance];
            self.unitText.text=@"METERS";
            
            
        }else{
            self.distanceText.text= [NSString stringWithFormat:@"%.2f",self.distance/1000];
            self.unitText.text=@"KM";
            
        }
    }
    
    //if(self.maxDistance<0) [self calculateMaxDist];
    
    //NSLog(@"%.2f",RADIANS_TO_DEGREES([self getBearing]));
}


- (void)timerTick:(NSTimer *)tick {
    
    //NSDate date is in GMT
    NSDate *now = [NSDate date];
    
    //launch time pulled from parse is in GMT
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.launchTime];
    self.time.text=[self stringFromTimeInterval:timeInterval];
   // [self.time setCenter:CGPointMake(self.view.frame.size.width*.5, self.view.frame.size.height-44-150)];

 }

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600) % 24;
    NSInteger years = (ti / 86400) % 365;

    return [NSString stringWithFormat:@"%04i:%02i:%02i:%02i",years, hours, minutes, seconds];
}


-(void)getFriendPosition:(id)sender{

    //get connection data
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(user1 = %@ OR user2 = %@)",[UIDevice currentDevice].identifierForVendor.UUIDString,[UIDevice currentDevice].identifierForVendor.UUIDString];
    PFQuery *query = [PFQuery queryWithClassName:@"TIA_Connection" predicate:predicate];
    
    [query orderByDescending:@"updatedAt"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {

            
                NSLog(@"objectId  %@", object.objectId);
                NSLog(@"created   %@", object.updatedAt);
                
                self.launchTime = object.updatedAt;

                NSLog(@"user 1    %@", object[@"user1"]);
                NSLog(@"user 2    %@", object[@"user2"]);
                NSLog(@"i am      %@", [UIDevice currentDevice].identifierForVendor.UUIDString);

                //check if user1 is myself
                if([object[@"user1"] isEqualToString: [UIDevice currentDevice].identifierForVendor.UUIDString]){
                    self.otherUserVendorIDString=object[@"user2"];
                }else{
                    self.otherUserVendorIDString=object[@"user1"];
                }
                
                
                NSLog(@"retrieving %@", self.otherUserVendorIDString);

                //retrieve otheruser's location
                PFQuery *query = [PFQuery queryWithClassName:@"TIA_Users"];
                [query whereKey:@"vendorUUID" equalTo:self.otherUserVendorIDString ];
                [query orderByDescending:@"updatedAt"];
                
                
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if (!object) {
                        NSLog(@"The getFirstObject request failed.");
                    } else {
                        // The find succeeded.
                        NSLog(@"Successfully retrieved the object.");
                        self.dlat= [[object objectForKey:@"lat"] floatValue];
                        self.dlng= [[object objectForKey:@"lng"] floatValue];
                        
                        

                        NSLog(@"pointing: %@",[object objectForKey:@"vendorUUID"] );
                    }
                    
                }];
            
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            //I don't exist in the connection database! yet...
            
            
            
        }
    }];

    

    //end refresh animation
    [(UIRefreshControl *)sender endRefreshing];
    
}

-(void)calculateMaxDist{
    if( self.page < [dele.locationDictionaryArray count] ) {
        NSMutableDictionary * dictionary = [dele.locationDictionaryArray objectAtIndex:self.page];
        //NSLog(@"%@", dictionary);
        self.dlat=[[dictionary valueForKey:@"lat"] floatValue];
        self.dlng=[[dictionary valueForKey:@"lng"] floatValue];
  
        
    }
    
    if(self.dlat!=0){
        //CLLocation *locA = [[CLLocation alloc] initWithLatitude:dele.myLat longitude:dele.myLng];
        // CLLocation *locB = [[CLLocation alloc] initWithLatitude:self.dlat longitude:self.dlng];
        //distance in meters
        //self.maxDistance= [locA distanceFromLocation:locB];
        self.maxDistance= 100;
    }else{
        
        self.maxDistance=-1;
    }
    
    
}


- (int) getBearing
{
    
    float _lat1 = dele.myLat;
    float _lng1 = dele.myLng;
    float _lat2 = self.dlat;
    float _lng2 = self.dlng;
    
    double lat1 = DEGREES_TO_RADIANS(_lat1);
    double lat2 = DEGREES_TO_RADIANS(_lat2);
    double dLon = DEGREES_TO_RADIANS(_lng2) - DEGREES_TO_RADIANS(_lng1);
	
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
	double brng = atan2(y, x);
    return (int)(RADIANS_TO_DEGREES(brng) + 360) % 360;
    
}



-(void) getBearingAccuracy{
    
    float bearing=self.locBearing;
    float offset=bearing+90;
    
    float xMeters=cosf(DEGREES_TO_RADIANS(offset))*dele.accuracy;
    float yMeters=sinf(DEGREES_TO_RADIANS(offset))*dele.accuracy;
    
    //111111 meters / degree (approximate) +- 10m
    float olat1 = dele.myLat+xMeters/111111.0;
    float olng1 = dele.myLng+yMeters/111111.0;
    
    
    float _lat1 = olat1;
    float _lng1 = olng1;
    float _lat2 = self.dlat;
    float _lng2 = self.dlng;
    
    double lat1 = DEGREES_TO_RADIANS(_lat1);
    double lat2 = DEGREES_TO_RADIANS(_lat2);
    double dLon = DEGREES_TO_RADIANS(_lng2) - DEGREES_TO_RADIANS(_lng1);
	
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
	double brng = atan2(y, x);
    
    int altBearing= (int)(RADIANS_TO_DEGREES(brng) + 360) % 360;
    
    float accuracy=bearing-altBearing;
    
    accuracy= (int)(accuracy + 360) % 360;
    
    bearingAccuracy= accuracy;
    
    //NSLog(@"%f,%i,=%f",bearing,altBearing,accuracy);
}



-(void)spinArc{
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(self.spin));

    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^(void){
                         //[self rotateArc:0 degrees:self.spin];
                         self.arrow.transform = transform;

                     }
                     completion: ^(BOOL finished){
                         if(finished){
                             self.spin+=90.0f;
                             self.spin=(int)self.spin%360;
                             if(self.spinning==TRUE) [self spinArc];
                             else return;
                             //NSLog(@"spin");
                         }
                         
                     }];


}

- (void)rotateArc:(NSTimeInterval)duration  degrees:(CGFloat)degrees
{
	CGAffineTransform transformRing = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^(void){
                         // The transform matrix
                         self.arrow.transform = transformRing;
                     }
                     completion: ^(BOOL finished){
                     }
     ];
}

- (void)updateHeading{
    //rotate arc if arrow is showing
    if(self.spinning==FALSE) {
        self.angle=self.locBearing-dele.heading;
        
        if(self.lastAngle!=self.angle){
            [self rotateArc:0.3f degrees:self.angle];
            self.lastAngle=self.angle;
        }

    }

    //self.spread=dele.headingAccuracy+bearingAccuracy;
    self.spread=3.0;

    if(self.spread!=self.lastSpread){
        //NSLog(@"%i/%i",self.spread,self.lastSpread);
        
//        [UIView animateWithDuration:.3f
//                              delay:0.0f
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
                             [self.arrow updateSpread:self.spread];

//                         }
//                         completion:nil];
        
        
        self.lastSpread=self.spread;
    }
    
    [self updateAccuracyText];
}


-(void)showHideInfo: (float)duration{
    BOOL info=[[NSUserDefaults standardUserDefaults] boolForKey:@"showInfo"];

    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(!info) {
                             [self.displayText setAlpha: 0.0f];
                             [self.pageNText setAlpha: 0.0f];
                             [self.accuracyText setAlpha: 0.0f];
                             //[self.arrow showExtras: FALSE];
                         }
                         else {
                             [self.displayText setAlpha: 1.0f];
                             [self.pageNText setAlpha: 1.0f];
                             [self.accuracyText setAlpha: 1.0f];
                             //[self.arrow showExtras: TRUE];
                         }
                     }
                     completion:nil];
}

-(void)updateAccuracyText{
    NSString *statusString;
    float speed=dele.speed*3.6;
    if(speed<0)speed=0;
    float headingAccuracy=dele.headingAccuracy;
    
    NSString *speedString;
    NSString *altitudeString;
    NSString *currentString;

    if([dele.units isEqual:@"m"]){
        speedString=[NSString stringWithFormat:@"%.2fmph",speed*.621371f];
        altitudeString=[NSString stringWithFormat:@"%.2fft ±%.2f",dele.altitude*3.28084,dele.altitudeAccuracy*3.28084];
        currentString=[NSString stringWithFormat:@"%f,%f ±%.2fft",dele.myLat,dele.myLng, (int)dele.accuracy*3.28084];
        
    }else{
        
        speedString=[NSString stringWithFormat:@"%.2fkph",speed];
        altitudeString=[NSString stringWithFormat:@"%.2fm ±%.2f",dele.altitude,dele.altitudeAccuracy];
        currentString=[NSString stringWithFormat:@"%f,%f ±%im",dele.myLat,dele.myLng, (int)dele.accuracy];
    }

    
    if(headingAccuracy<0)headingAccuracy=0;
    statusString= [NSString stringWithFormat:@
                   "speed   : %@ \n"
                   "heading : %i° ±%i°\n"
                   "bearing : %i° ±%i°\n"
                   "altitude: %@\n"
                   "current : %@\n"
                   "target  : %f,%f \n"
                   "atUUID  : %@\n"
                   "myUUID  : %@\n"

                   ,
                   speedString,
                   (int)dele.heading,(int)headingAccuracy,
                   (int)self.locBearing,(int)bearingAccuracy,
                   altitudeString,
                   currentString,
                   self.dlat , self.dlng,
                   self.otherUserVendorIDString,
                   [UIDevice currentDevice].identifierForVendor.UUIDString
                   ];
    
    self.displayText.text=statusString;
}


- (void) pickUnits{
    //NSLog(@"switch Units");
    if([dele.units isEqual:@"m"])dele.units=@"km";
    else dele.units=@"m";
    [[NSUserDefaults standardUserDefaults] setObject:dele.units forKey:@"units"];
    [self updateDistanceWithLatLng:0];
    

}



-(void) hideArrow:(BOOL) state
{
    self.arrow.hidden=state;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
