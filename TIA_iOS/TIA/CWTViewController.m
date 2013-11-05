
//
//  CWTViewController.m
//  Crowsflight
//
//  Created by Che-Wei Wang on 5/4/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import "CWTViewController.h"
#import "CWTLocationViewController.h"

#import "QuartzCore/CALayer.h"


#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)


@interface CWTViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>


@end

@implementation CWTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dele = [[UIApplication sharedApplication] delegate];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithWhite:.95 alpha:1];
    
    CGRect screen = [[UIScreen mainScreen] applicationFrame];
    
    
    
    self.view.layer.masksToBounds=NO;
 
    self.pageView=[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageView.dataSource = self;
    self.pageView.delegate = self;
    self.pageView.view.layer.masksToBounds=FALSE;
    [self.view addSubview:self.pageView.view];
    self.pageView.view.frame=CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds)+40);

    
    self.locationViewController=[[CWTLocationViewController alloc] init];

    
    int iconWidth=44;
    


    //more info button
    iconWidth=50;
    moreInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    moreInfo.frame=CGRectMake(10-iconWidth*.5, screen.size.height-15, iconWidth,iconWidth);
    [moreInfo addTarget:self action:@selector(setShowInfo) forControlEvents:UIControlEventTouchUpInside];
    [moreInfo setImage:[UIImage imageNamed:@"more-info2.png"] forState:UIControlStateNormal];
    [moreInfo setImage:[UIImage imageNamed:@"less-info.png"] forState:UIControlStateSelected];
    
    [self.view addSubview:moreInfo];

  
    
}



-(void)viewDidUnload{
    AudioServicesDisposeSystemSoundID(audioCreate);
}


-(void)viewWillAppear:(BOOL)animated{
    
    if( [[NSUserDefaults standardUserDefaults] integerForKey:@"currentDestinationN"]>= [dele.locationDictionaryArray count] ) {
        [[NSUserDefaults standardUserDefaults] setInteger:[dele.locationDictionaryArray count]-1 forKey:@"currentDestinationN"];
    }
    
    self.locationViewController.page=[[NSUserDefaults standardUserDefaults] integerForKey:@"currentDestinationN"];
    
    
    [self.pageView setViewControllers:@[self.locationViewController] direction:UIPageViewControllerNavigationDirectionForward  animated:NO completion:^(BOOL finished) {
        //code
    }
     ];
    
    
    //hide or unhide info
    self.showInfo=[[NSUserDefaults standardUserDefaults] boolForKey:@"showInfo"];
    //NSLog(@"read show info %i",self.showInfo);
    
    [moreInfo setSelected:self.showInfo];
    
    if(self.showInfo==FALSE) {
        [self.compassImage setAlpha: 0.0f];
        [self.compassImage setHidden:YES];
    }
    else {
        [self.compassImage setAlpha: 1.0f];
        [self.compassImage setHidden:NO];
        
    }
    
    
    //NSLog(@"locationViewController show %i",[[NSUserDefaults standardUserDefaults] integerForKey:@"currentDestinationN"]);
    

    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    self.showMapBool=TRUE;
    self.showListBool=TRUE;

    [self checkGPS];
    

}


-(void)checkGPS{
    NSString *causeStr = nil;

    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
        
        
    }
    

}

-(void)viewDidLayoutSubviews{
    //CGRect screen = [[UIScreen mainScreen] applicationFrame];
    //self.compassImage.center=CGPointMake(screen.size.width*.5, screen.size.height*.5+22);
    
}


-(void)updateViewControllersWithName{
    
    NSArray* viewC = [self.pageView viewControllers];
    CWTLocationViewController * vc=[viewC objectAtIndex:0];

    [vc updateDestinationName];
}


-(void)updateViewControllersWithLatLng: (int)_page{
    NSArray* viewC = [self.pageView viewControllers];
    CWTLocationViewController * vc=[viewC objectAtIndex:0];
    [vc updateDistanceWithLatLng:.3];
    
}


-(void)updateViewControllersWithHeading: (int)_page{
    NSArray* viewC = [self.pageView viewControllers];
    [[viewC objectAtIndex:0] updateHeading];
    [self rotateCompass:.1 degrees:-dele.heading];
    
}


- (void)rotateCompass:(NSTimeInterval)duration  degrees:(CGFloat)degrees
{
    
    CGAffineTransform transformCompass = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^(void){
                         // The transform matrix
                         self.compassImage.transform = transformCompass;
                         self.compassN.transform = transformCompass;
                     }
                     completion: ^(BOOL finished){
                     }
     ];
    
}






-(void)setShowInfo{
    
    self.showInfo=!self.showInfo;
    [[NSUserDefaults standardUserDefaults] setBool:self.showInfo forKey:@"showInfo"];
    NSLog(@"set show info %i",self.showInfo);
    
    
    if(self.showInfo){
        //[self.audioMore play];
        [self.compassImage setHidden:FALSE];
        [self.compassImage setAlpha: 0.0f];
        
    }else{
        
        //[self.audioLess play];

    }
    
    [moreInfo setSelected:self.showInfo];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(!self.showInfo)[self.compassImage setAlpha: 0.0f];
                         else [self.compassImage setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){
                         [self.compassImage setHidden:!self.showInfo];
                     }];
    
    NSArray* viewC = [self.pageView viewControllers];
    [[viewC objectAtIndex:0] showHideInfo:.3f];
    

    //NSLog(@"switch showinfo");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewController Data Source

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    //disable pages
    return nil;
    
    
    NSInteger indx = [(CWTLocationViewController*)viewController page];
    indx++;
    
    if( indx>= [dele.locationDictionaryArray count] ) return nil;
    

    CWTLocationViewController* newLoc = [[CWTLocationViewController alloc] init];
    newLoc.page = indx;

    return newLoc;
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    //disable pages
    return nil;
    
    
    NSInteger indx = [(CWTLocationViewController*)viewController page];
    indx--;
    
    if( indx<0 ) return nil;
    
    CWTLocationViewController* newLoc = [[CWTLocationViewController alloc] init];
    newLoc.page = indx;
    

    return newLoc;
}




- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSArray* viewC = [self.pageView viewControllers];
    
    return   [viewC count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return   self.locationViewController.page;
    
}


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    
}





@end
