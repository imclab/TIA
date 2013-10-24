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
#import "CWTToolBar.h"
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
@property (nonatomic,strong)  CWTToolbar *toolBar;




//@property(nonatomic, strong, readonly) UISearchBar *searchBar;

@property (nonatomic,strong) IBOutlet UIImageView *compassImage;
@property (nonatomic,strong) IBOutlet UIImageView *compassN;
@property (nonatomic,assign) BOOL showInfo;
@property (nonatomic,assign) BOOL showMapBool;
@property (nonatomic,assign) BOOL showListBool;


@property (nonatomic, strong) NSArray *places;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userLocation;


@end

