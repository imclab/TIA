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
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>


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
    self.scrollView.pagingEnabled=NO;
    self.scrollView.directionalLockEnabled=YES;

    [self.view addSubview:self.scrollView];
    self.scrollView.frame=CGRectMake(0,-50, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds)+50);
    self.scrollView.contentSize = screen.size;
//    CGSize scrollableSize = CGSizeMake(320, 900);
//    [self.scrollView setContentSize:scrollableSize];
    
    self.mainView=[[UIView alloc] init];
    self.mainView.frame=CGRectMake(0,50, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds));
    //self.mainView.backgroundColor=[UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    
    [self.scrollView addSubview:self.mainView];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width , self.view.frame.size.height+55);

    
    
     //add down arrow
    self.dnArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.dnArrow.center=CGPointMake(screen.size.width*.5,80);
    [self.dnArrow setImage:[UIImage imageNamed:@"arrow-dn.png"]];
    
    if( [[NSUserDefaults standardUserDefaults] boolForKey:@"pull_to_refresh"]){
        [self.mainView addSubview: self.dnArrow];
    }
    
    
    
    self.backgroundImage = [[UIImageView alloc] init];
    //    [self.backgroundImage setImage:[UIImage imageNamed:@"arrow-dn.png"]];
    [self.scrollView addSubview: self.backgroundImage];
    
    
    
    
    
    
    //stats
    self.displayText=[[UILabel alloc] initWithFrame:CGRectMake(20, screen.size.height+120, 320, 100)];
    self.displayText.numberOfLines=15;
    self.displayText.backgroundColor=[UIColor clearColor];
    self.displayText.textColor=[UIColor colorWithWhite:0 alpha:1];
    [self.displayText setFont:[UIFont fontWithName:@"Andale Mono" size:8.0]];
    [self.mainView addSubview:self.displayText];
    

    
    //add satSearchImage
    self.satSearchImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.satSearchImage.center=CGPointMake(screen.size.width*.95,40);
    self.satSearchImage.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"satellite_0003.png"],
                                           [UIImage imageNamed:@"satellite_0002.png"],
                                           [UIImage imageNamed:@"satellite_0001.png"],
                                           [UIImage imageNamed:@"satellite_0000.png"], nil];
    self.satSearchImage.animationDuration = 2.0f;
    self.satSearchImage.animationRepeatCount = 0;
    [self.satSearchImage startAnimating];
    [self.view addSubview: self.satSearchImage];
    self.satSearchImage.hidden=TRUE;
    
    //main arrow
    self.arrow=[[CWTArrow alloc] initWithFrame:CGRectMake(0, 0, 9,1200)];
    self.arrow.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.arrow];
    [self.arrow setCenter:CGPointMake(screen.size.width*.5, screen.size.height*.5)];
    
    //main arrow hack
    self.arrowImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.arrow.frame.size.width ,self.arrow.frame.size.height)];
    [self.arrowImage setImage:[UIImage imageNamed:@"dotarrow.png"]];
    [self.arrow addSubview:self.arrowImage];
    //self.arrowImage.center=self.arrow.center;
    
    
    //add north arrow
    self.north = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16*.25, 263*.25)];
    [self.north setImage:[UIImage imageNamed:@"north.png"]];
    [self.view addSubview: self.north];
    
    self.north.center=self.arrow.center;
    
    
    //pushnotification dot
    self.pushProgress=[[CWTDot alloc] initWithFrame:CGRectMake(0, 0, 200,200)];
    self.pushProgress.backgroundColor=[UIColor clearColor];
    self.pushProgress.dotColor=[UIColor clearColor];
    self.pushProgress.lineColor=[UIColor colorWithWhite:.1 alpha:.5];
    [self.pushProgress inflate:10];
    self.pushProgress.lineWidth=200;
    [self.pushProgress setCenter:CGPointMake(screen.size.width*.5, screen.size.height-40)];
    [self.mainView addSubview:self.pushProgress];

    
    // Create  mask layer
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0,0,self.pushProgress.frame.size.width,self.pushProgress.frame.size.height);
    maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"heartMask.png"] CGImage];
    // Apply the mask to  uiview layer
    self.pushProgress.layer.mask = maskLayer;

    
    self.heart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.heart setImage:[UIImage imageNamed:@"heartMask.png"] forState:UIControlStateNormal];
    self.heart.frame = CGRectMake(screen.size.width*.5-150, screen.size.height-40-150,300,300);
    //[self.mainView addSubview:self.heart];

 
   
    //refresh arc
    self.refreshProgress=[[CWTDot alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.refreshProgress.backgroundColor=[UIColor clearColor];
    //self.refreshProgress.dotColor=[UIColor colorWithWhite:.2 alpha:.5];
    self.refreshProgress.dotColor=[UIColor clearColor];
    self.refreshProgress.lineWidth=4;
    [self.refreshProgress inflate:25];
    [self.refreshProgress setCenter:CGPointMake(screen.size.width*.5, self.dnArrow.center.y+self.refreshProgress.frame.size.height*.5)];

    
    [self.scrollView addSubview:self.refreshProgress];
    
    
    //distance
    self.distanceText=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 0,0)];
    self.distanceText.numberOfLines=1;
    self.distanceText.textColor=[UIColor colorWithWhite:0 alpha:1];
    [self.distanceText setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
    [self.distanceText setTextAlignment:NSTextAlignmentCenter];
    self.distanceText.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    //self.distanceText.backgroundColor=[UIColor colorWithWhite:.95 alpha:1];
    self.distanceText.text=@"000";
   // self.distanceText.frame=CGRectMake(0,0, screen.size.width*.2, 20);
    //[self.distanceText setCenter:CGPointMake(self.arrow.frame.size.width*.5, self.arrow.center.y+screen.size.width*.7)];
    //[self.distanceText setCenter:CGPointMake(-4, self.arrow.center.y+screen.size.width*.6)];
    [self.distanceText setCenter:CGPointMake(10, self.arrow.center.y+screen.size.width*.6)];

    [self.arrow addSubview:self.distanceText];
    
    

    
    //main message
    self.mainMessage=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screen.size.width, 120)];
    [self.mainMessage setCenter:CGPointMake(screen.size.width*.5, screen.size.height-40)];
    self.mainMessage.numberOfLines=10;
    self.mainMessage.textAlignment=NSTextAlignmentCenter;
    
    [self.mainMessage setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]];
    //self.mainMessage.adjustsFontSizeToFitWidth = YES;
    //self.mainMessage.backgroundColor=[UIColor clearColor];
    //self.mainMessage.backgroundColor=[UIColor colorWithWhite:1 alpha:1];
    //self.mainMessage.backgroundColor=[UIColor colorWithRed:1 green:0 blue:0 alpha:1];

    [self.mainView addSubview:self.mainMessage];
    self.mainMessage.text=@"...";
    
    

    
    
    //refresh on a timer
    //NSTimer* timer = [NSTimer timerWithTimeInterval:20.0f target:self selector:@selector(getFriendPosition) userInfo:nil repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    //pull to refresh
    //UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    //[refreshControl addTarget:self action:@selector(getFriendPosition:)forControlEvents:UIControlEventValueChanged];
    //[self.mainView addSubview:refreshControl];
    
    //time from launch
    self.time=[[UILabel alloc] initWithFrame:CGRectMake(0, screen.size.height+240, screen.size.width, 40)];
    self.time.numberOfLines=3;
    self.time.textColor=[UIColor colorWithWhite:.3 alpha:1];
    [self.time setFont:[UIFont fontWithName:@"Andale Mono" size:9.0]];
    [self.time setTextAlignment:NSTextAlignmentCenter];
    [self.mainView addSubview:self.time];
    //[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    
    //pushmessage
    self.pushMessage=[[UILabel alloc] initWithFrame:CGRectMake(0, screen.size.height+180, screen.size.width, 20)];
    self.pushMessage.numberOfLines=10;
    self.pushMessage.textColor=[UIColor colorWithWhite:.3 alpha:1];
    [self.pushMessage setFont:[UIFont fontWithName:@"Andale Mono" size:12.0]];
    [self.pushMessage setTextAlignment:NSTextAlignmentCenter];
    [self.pushMessage setTextAlignment:NSTextAlignmentCenter];

    //[self.mainView addSubview:self.pushMessage];
 
    
    //add heart
    self.heart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.heart addTarget:self
                   action:@selector(heartPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.heart setImage:NULL forState:UIControlStateNormal];
    [self.heart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateSelected];

    self.heart.frame = CGRectMake(0,0, 12, 12);
    [self.heart setCenter:CGPointMake(screen.size.width-22, screen.size.height+55-6)];
    [self.scrollView addSubview:self.heart];
    
    
    //get two phrases on launch
    self.numPhrases=3;
    
    [self updateHeading];
    [self startBTLE];
}


/*
-(IBAction)heartPressed:(id)sender{
        if ([sender isSelected]) {
            //[sender setImage:unselectedImage forState:UIControlStateNormal];
            [sender setSelected:NO];
        } else {
            //[sender setImage:selectedImage forState:UIControlStateSelected];
            [sender setSelected:YES];
        }
    
    
}
*/

-(void)getFlickrImage
{
    NSString *FLICKR_KEY=@"b0a198db96a6a9854ee27e04909bd940";

    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&content_type=1&geo_context=2&lat=%f&lon=%f&per_page=1&page=1&format=json&nojsoncallback=1", FLICKR_KEY, self.dlat,self.dlng];
   /*
    geo_context (Optional)
    
    0, not defined.
    1, indoors.
    2, outdoors.
    
    content_type (Optional)
    1 for photos only.
    2 for screenshots only.
    3 for 'other' only.
    4 for photos and screenshots.
    5 for screenshots and 'other'.
    6 for photos and 'other'.
    7 for photos, screenshots, and 'other' (all).
    */
    
    
    
    //async url request for flickr images
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // 2. Get URLResponse string & parse JSON to Foundation objects.
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        // 3. Pick thru results and build our arrays
        NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
        for (NSDictionary *photo in photos) {
            // 3.b Construct URL for e/ photo.
            NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_q.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]]];
            
            CGRect screen = [[UIScreen mainScreen] applicationFrame];
            //int bleed=320;
            int imageSize=screen.size.height+100;
            UIImage *scaledImage = [self imageWithImage:image scaledToSize:CGSizeMake(imageSize,imageSize)];
            CGRect backgroundFrame=CGRectMake(-imageSize*.5+screen.size.width*.5,0,imageSize,imageSize);
            
            
            
            //Blur the UIImage with a CIFilter
            CIImage *imageToBlur = [CIImage imageWithCGImage:scaledImage.CGImage];
            CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
            [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
            [gaussianBlurFilter setValue:[NSNumber numberWithFloat: [[NSUserDefaults standardUserDefaults] integerForKey:@"blur_radius"] ] forKey: @"inputRadius"];
            CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
            UIImage *endImage = [[UIImage alloc] initWithCIImage:resultImage];

            [self.backgroundImage setImage:endImage];
            [self.backgroundImage setFrame:backgroundFrame];
            [self.scrollView sendSubviewToBack:self.backgroundImage];
            
            NSLog(@"image Loaded: %@", photoURLString);

        }
    }];
    
}


-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}




-(void)startBTLE
{
    //check user number
    //get connection data
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(user1 = %@ OR user2 = %@)",[UIDevice currentDevice].identifierForVendor.UUIDString,[UIDevice currentDevice].identifierForVendor.UUIDString];
    PFQuery *query = [PFQuery queryWithClassName:@"TIA_Connection" predicate:predicate];
    
    [query orderByDescending:@"updatedAt"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
                NSLog(@"user 1    %@", object[@"user1"]);
                NSLog(@"user 2    %@", object[@"user2"]);
                NSLog(@"i am      %@", [UIDevice currentDevice].identifierForVendor.UUIDString);
                
                //check if user1 is myself
                if([object[@"user1"] isEqualToString: [UIDevice currentDevice].identifierForVendor.UUIDString]){
                    //if user1
                    self.BTLECentral=[[BTLECentralViewController alloc] init];
                    [self.mainView addSubview:self.BTLECentral.view];
                    NSLog(@"launch BTLE Central for user 1");
                }
                else{
                    //if user2
                    self.BTLPeripheral=[[BTLEPeripheralViewController alloc] init];
                    [self.mainView addSubview:self.BTLPeripheral.view];
                    NSLog(@"launch BTLE Peripheral for user 2");

                }
        }
        
        }];
 
}



-(void)viewWillAppear:(BOOL)animated{
    [self loadLocation];

}

-(void)viewDidAppear:(BOOL)animated
{
    //[self spinArc];
    //CGRect screen = [[UIScreen mainScreen] bounds];
    //[self.arrow setHidden:FALSE];
    //[self.arrow setNeedsDisplay];
    //[self.arrow setAlpha:1.0f];
}

-(void)viewDidLayoutSubviews{

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrolling");
    
    CGPoint offset = scrollView.contentOffset;
    int minOffsetY=-100;
    int maxOffsetY=300;
    // Check if current offset is within limit and adjust if it is not
    if (offset.y < minOffsetY) offset.y = minOffsetY;
    if (offset.y > maxOffsetY) offset.y = maxOffsetY;
    
    // Set offset to adjusted value
    scrollView.contentOffset = offset;
    
    int pullUpTrigger=100;
    
    //pull down
    if( [[NSUserDefaults standardUserDefaults] boolForKey:@"pull_to_refresh"]){
        if(scrollView.contentOffset.y<minOffsetY){
            //animate scroll
            [self.refreshProgress inflate:25];
            [self.refreshProgress progress:360];
        }else{
            [self.refreshProgress inflate:25];
            [self.refreshProgress progress:scrollView.contentOffset.y/minOffsetY*360.0];
            
        }
    }
    
    //pull up
    if( [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_send_push_notifications"]){
        if(self.heart.selected==FALSE && ![self.mainMessage.text isEqualToString:@""] && self.hasAnother){
            if(scrollView.contentOffset.y>pullUpTrigger){
                [self.pushProgress progress:360];
            }else{
                [self.pushProgress progress:(scrollView.contentOffset.y-10)/(pullUpTrigger-10)*360.0];
            }
        }else{
            [self.pushProgress progress:0];
        }
    }
    //timer is showing so update it
    [self updateTimer];
    

}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    
    //pull down to refresh
    if(scrollView.contentOffset.y<=-100 && [[NSUserDefaults standardUserDefaults] boolForKey:@"pull_to_refresh"] ){
        self.mainMessage.center=CGPointMake(self.mainMessage.center.x,scrollView.frame.size.height+100);
        [self getFriendPosition:nil];
        [self.heart setSelected:NO];
        self.mainMessage.text=@"";
    }

    //pull up to send push notification
    else if(scrollView.contentOffset.y>=100 && self.heart.selected==FALSE && ![self.mainMessage.text isEqualToString:@""] &&                             self.hasAnother && [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_send_push_notifications"]
){
        // Create our Installation query
        NSLog(@"scrolled :%f ",scrollView.contentOffset.y);

        //reverse geocode location message
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        CLLocation *myLocation=[[CLLocation alloc] initWithLatitude:dele.myLat longitude:dele.myLng];
        [geocoder reverseGeocodeLocation:myLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           if (error){
                               NSLog(@"Geocode failed with error: %@", error);
                               return;
                           }
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           NSLog(@"placemark.%@",placemark);
                           //NSString*  pushMess = [NSString stringWithFormat:@"♥ %@ From %@.",self.mainMessage.text, placemark.thoroughfare];
                            NSString*  pushMess = [NSString stringWithFormat:@"♥ %@",self.mainMessage.text];
                           NSLog(@"pushMess %@",pushMess);
                           
                           PFQuery *pushQuery = [PFInstallation query];
                           [pushQuery whereKey:@"vendorUUID" equalTo:self.otherUserVendorIDString];
                           // Send push notification to query
                           PFPush *push = [[PFPush alloc] init];
                           [push setQuery:pushQuery]; // Set our Installation query
                           [push setMessage:pushMess];
                           [push sendPushInBackground];
                           
                           //[dele alert:@"Sent push notification to your other."];
                           //
                           [self.heart setSelected:YES];
                           
                       }];
    }
    

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if(self.mainMessage.center.y>scrollView.frame.size.height) {
        //[self.refreshProgress loadingAnimation:.5f delay:0.0f];
        [self.refreshProgress startSpin];
    }

}


-(void)loadLocation{
    //[self calculateMaxDist];
    [self getFriendPosition:nil];
    
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
            self.distanceText.text= [NSString stringWithFormat:@"%i FT",(int)(self.distance*3.28084)];
            self.unitText.text=@"FEET";
            
        }else{
            self.distanceText.text= [NSString stringWithFormat:@"%.0f MILES",self.distance*0.000621371];
            self.unitText.text=@"MILES";
        }
        
    }
    else {
        if(self.distance<1000){
            self.distanceText.text= [NSString stringWithFormat:@"%i METERS",(int)self.distance];
            self.unitText.text=@"METERS";
            
            
        }else{
            self.distanceText.text= [NSString stringWithFormat:@"%.0f KM",self.distance/1000];
            self.unitText.text=@"KM";
            
        }
    }
    
    
    //set label size to text
    CGSize textSize = [[self.distanceText text] sizeWithFont:[self.distanceText font]];
    CGRect newFrame =  self.distanceText.frame;
    newFrame.size = CGSizeMake(textSize.height, textSize.width+20);
    self.distanceText.frame=newFrame;

}


- (void)updateTimer {
    //NSDate date is in GMT
    NSDate *now = [NSDate date];
    //launch time pulled from parse is in GMT
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.launchTime];
    self.time.text=[self stringFromTimeInterval:timeInterval];
 }

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600) % 24;
    NSInteger days = (ti / 86400) ;
    //NSInteger years = (ti / 31556952) % 9999;//86400 * 365.2425

    //return [NSString stringWithFormat:@"%03i:%02i:%02i:%02i", days, hours, minutes, seconds];
    return [NSString stringWithFormat:@"%i days %i hours %i minutes %i seconds\nsince the two of you have been connected", days, hours, minutes, seconds];

}


-(void)getFriendPosition:(id)sender{
    
    //get connection data
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((user1 = %@) OR (user2 = %@))",[UIDevice currentDevice].identifierForVendor.UUIDString,[UIDevice currentDevice].identifierForVendor.UUIDString];
   
    
    //query connection database
    PFQuery *query = [PFQuery queryWithClassName:@"TIA_Connection" predicate:predicate];
    //based on last updated
    [query orderByDescending:@"updatedAt"];
    //exclude closed connections
    [query whereKeyDoesNotExist:@"completedAt"];
    
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
                    self.myUserNumber=1;

                }else{
                    self.otherUserVendorIDString=object[@"user1"];
                    self.myUserNumber=2;

                }
            
                NSLog(@"retrieving %@", self.otherUserVendorIDString);
            
                //query users database
                PFQuery *query = [PFQuery queryWithClassName:@"TIA_Users"];
                //find other's uuid
                [query whereKey:@"vendorUUID" equalTo:self.otherUserVendorIDString ];
                //get latest version in case there are more than one
                [query orderByDescending:@"updatedAt"];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
                {
                    
                    if (!object) {
                        NSLog(@"The getFirstObject request failed.");
                        self.mainMessage.text=@"Error getting your other's data. Please try again later.";
                        [self animateMainMessage];
                        [self.refreshProgress stopSpin];
                        self.hasAnother=false;

                    } else {
                        // The find succeeded.
                        self.dlat= [[object objectForKey:@"lat"] floatValue];
                        self.dlng= [[object objectForKey:@"lng"] floatValue];
                        
                        
                        if([[NSUserDefaults standardUserDefaults] boolForKey:@"fetch_flickr"])[self getFlickrImage];
                        else [self.backgroundImage setImage:nil];

                        
                        
                        self.otherUsername=[object objectForKey:@"name"];
                        self.hasAnother=true;

                        [self updateDistanceWithLatLng:0];

                        NSLog(@"pointing: %@",[object objectForKey:@"vendorUUID"] );
                        
                        //query for message based on another's data
                        
                        
                        //async url request for sentences
                        NSString *url = [NSString stringWithFormat:@"http://tia-poems.herokuapp.com/%f,%f,%i", self.dlat, self.dlng, self.numPhrases];
                        if(self.numPhrases>2) self.numPhrases--;

                        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                            
                            
                            
                            NSString *mainMess = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        
                        
                            
                            //set message
                            NSLog(@"mainMess:%@",mainMess);
                            self.mainMessage.text=[NSString stringWithFormat:@"%@",mainMess];

                            /*
                            //reverse geocode message
                            CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
                            CLLocation *theirLocation=[[CLLocation alloc] initWithLatitude:self.dlat longitude:self.dlng];
                            [geocoder reverseGeocodeLocation:theirLocation
                                       completionHandler:^(NSArray *placemarks, NSError *error) {

                                           if (error){
                                               NSLog(@"Geocode failed with error: %@", error);
                                               return;
                                           }
                                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                           NSLog(@"placemark.%@",placemark);
                                           
                                           
                                           NSInteger randomNumber = arc4random() % 4;
                                           NSString*  gpsMess;
                                           
                                           if(randomNumber==0)gpsMess = [NSString stringWithFormat:@"Near %@.",placemark.thoroughfare];
                                           else if (randomNumber==1) gpsMess = [NSString stringWithFormat:@"By %@.",placemark.thoroughfare];
                                           else if (randomNumber==2)gpsMess = [NSString stringWithFormat:@"Around %@.",placemark.thoroughfare];
                                           else if (randomNumber==3)gpsMess = [NSString stringWithFormat:@"Close to %@.",placemark.thoroughfare];

                                           
                                           NSLog(@"gpsMess %@",gpsMess);
                                           self.mainMessage.text=[NSString stringWithFormat:@"%@ %@",self.mainMessage.text,gpsMess];
                                           
                                           //end refresh animation
                                           //[(UIRefreshControl *)sender endRefreshing];


                                       }];
                             */
                            
                            
                            
                            //animate main message onto screen
                            [self animateMainMessage];
                            //[self.refreshProgress setAlpha:1];
                            
                            [self.refreshProgress stopSpin];

                          }];
                        
                    

                    }
                }];
            
        }
        else {
            // Log details of the failure
            NSLog(@"Connection Lookup Error: %@ %@", error, [error userInfo]);
            
            //No connection entry in database
            if (dele.hasInternet==FALSE) {
                self.mainMessage.text=@"Couldn't reach the internet.";

            }else self.mainMessage.text=@"You don't have another yet. Please try again later when we connect you to your other.";
            [self animateMainMessage];
            [self.refreshProgress stopSpin];
            self.hasAnother=false;
            //end refresh animation
            //[(UIRefreshControl *)sender endRefreshing];
        }

    }];



}


-(void)animateMainMessage{
    
    //animate main message onto screen
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect screen = [[UIScreen mainScreen] applicationFrame];
                         
                         [self.mainMessage setCenter:CGPointMake(self.mainMessage.center.x,  screen.size.height-40)];
                     }
                     completion:nil];
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
                         //self.arrowImage.transform = transform;
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
    
    //float dd=degrees-90.0f;
    //CGAffineTransform transformDistanceText = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(dd));

    [UIView animateWithDuration:duration
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^(void){
                         // The transform matrix
                         self.arrow.transform = transformRing;
                         //self.arrowImage.transform = transformRing;
                         //self.distanceText.transform = transformDistanceText;

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
            //[self rotateText:self.distanceText duration:0.1 degrees:DEGREES_TO_RADIANS(self.angle)];

        }

    }
    [self updateAccuracyText];
}


- (void)rotateCompass:(NSTimeInterval)duration  degrees:(CGFloat)degrees
{
    
    CGAffineTransform transformCompass = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^(void){
                         // The transform matrix
                         self.north.transform = transformCompass;
                     }
                     completion: ^(BOOL finished){
                     }
     ];
    
}




-(void)showHideInfo: (float)duration{
    BOOL info=[[NSUserDefaults standardUserDefaults] boolForKey:@"showInfo"];

    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(!info) {
                             [self.displayText setAlpha: 0.0f];
                             [self.accuracyText setAlpha: 0.0f];
                             //[self.arrow showExtras: FALSE];
                         }
                         else {
                             [self.displayText setAlpha: 1.0f];
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
                   "speed      : %@ \n"
                   "heading    : %i° ±%i°\n"
                   "bearing    : %i° ±%i°\n"
                   "altitude   : %@\n"
                   "current    : %@\n"
                   "myUUID     : %@\n"
                   "myuser#    : %i\n"
                   "target     : %f,%f \n"
                   "targetUUID : %@\n"
                   //"targetname : %@\n"

                   ,
                   speedString,
                   (int)dele.heading,(int)headingAccuracy,
                   (int)self.locBearing,(int)bearingAccuracy,
                   altitudeString,
                   currentString,
                   [UIDevice currentDevice].identifierForVendor.UUIDString,
                   self.myUserNumber,
                   self.dlat , self.dlng,
                   self.otherUserVendorIDString
                   ////self.otherUsername
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


- (void)rotateText:(UILabel *)label duration:(NSTimeInterval)duration degrees:(CGFloat)degrees {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path,nil, self.arrow.center.x , self.arrow.center.y, 20, DEGREES_TO_RADIANS(degrees-1), DEGREES_TO_RADIANS(degrees), YES);
    
    CAKeyframeAnimation *theAnimation;
    
    // animation object for the key path
    theAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    theAnimation.path=path;
    CGPathRelease(path);
    
    // set the animation properties
    theAnimation.duration=duration;
    theAnimation.removedOnCompletion = NO;
    theAnimation.autoreverses = NO;
    theAnimation.rotationMode = kCAAnimationRotateAutoReverse;
    theAnimation.fillMode = kCAFillModeForwards;
    
    [label.layer addAnimation:theAnimation forKey:@"position"];
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
